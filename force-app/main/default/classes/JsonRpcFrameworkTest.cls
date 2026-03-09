@IsTest
private class JsonRpcFrameworkTest {
    private class SumParams extends JsonRpcParamsBase {
        public Integer a;
        public Integer b;

        public override void validate() {
            if (a == null || b == null) {
                throw new JsonRpcException('a and b are required.');
            }
        }
    }

    private class SumResult extends JsonRpcResultBase {
        public Integer sum;

        public override void validate() {
            if (sum == null) {
                throw new JsonRpcException('sum is required.');
            }
        }
    }

    private class PingParams extends JsonRpcParamsBase {
    }

    private class PingResult extends JsonRpcResultBase {
        public String status;

        public override void validate() {
            if (String.isBlank(status)) {
                throw new JsonRpcException('status is required.');
            }
        }
    }

    private class NestedDynamicParams extends JsonRpcParamsBase implements JsonRpcRawParamsDecoder {
        public Map<String, Object> arguments;

        public void decodeRawParams(Object rawParams) {
            if (!(rawParams instanceof Map<String, Object>)) {
                throw new JsonRpcException('params must be an object.');
            }

            Map<String, Object> rawMap = (Map<String, Object>) rawParams;
            Object rawArguments = rawMap.get('arguments');
            if (rawArguments != null && !(rawArguments instanceof Map<String, Object>)) {
                throw new JsonRpcException('arguments must be an object.');
            }

            this.arguments = (Map<String, Object>) rawArguments;
        }

        public override void validate() {
            if (this.arguments == null || !this.arguments.containsKey('value')) {
                throw new JsonRpcException('arguments.value is required.');
            }
        }
    }

    private class NestedDynamicResult extends JsonRpcResultBase {
        public List<Object> items = new List<Object>();
        public Map<String, Object> meta = new Map<String, Object>();

        public override void validate() {
            if (this.items == null || this.items.isEmpty()) {
                throw new JsonRpcException('items must not be empty.');
            }
            if (this.meta == null || !this.meta.containsKey('ok')) {
                throw new JsonRpcException('meta.ok is required.');
            }
        }
    }

    private class SumHandler implements JsonRpcMethodHandler {
        public String methodName() {
            return 'math.sum';
        }

        public Type paramsType() {
            return SumParams.class;
        }

        public Type resultType() {
            return SumResult.class;
        }

        public Object invoke(Object params, JsonRpcInvocationContext context) {
            SumParams typed = (SumParams) params;
            SumResult result = new SumResult();
            result.sum = typed.a + typed.b;
            return result;
        }
    }

    private class PingHandler implements JsonRpcMethodHandler {
        public String methodName() {
            return 'system.ping';
        }

        public Type paramsType() {
            return PingParams.class;
        }

        public Type resultType() {
            return PingResult.class;
        }

        public Object invoke(Object params, JsonRpcInvocationContext context) {
            PingResult result = new PingResult();
            result.status = 'ok';
            return result;
        }
    }

    private class NestedDynamicHandler implements JsonRpcMethodHandler {
        public String methodName() {
            return 'debug.nested';
        }

        public Type paramsType() {
            return NestedDynamicParams.class;
        }

        public Type resultType() {
            return NestedDynamicResult.class;
        }

        public Object invoke(Object params, JsonRpcInvocationContext context) {
            NestedDynamicParams typed = (NestedDynamicParams) params;
            NestedDynamicResult result = new NestedDynamicResult();
            result.items.add(new Map<String, Object>{
                'type' => 'text',
                'text' => 'value=' + String.valueOf(typed.arguments.get('value'))
            });
            result.meta.put('ok', true);
            result.meta.put('method', context.methodName);
            return result;
        }
    }

    private class ThrowingHandler implements JsonRpcMethodHandler {
        public String methodName() {
            return 'system.explode';
        }

        public Type paramsType() {
            return PingParams.class;
        }

        public Type resultType() {
            return PingResult.class;
        }

        public Object invoke(Object params, JsonRpcInvocationContext context) {
            Integer x = 1 / 0;
            return null;
        }
    }

    private class BadResultHandler implements JsonRpcMethodHandler {
        public String methodName() {
            return 'system.badResult';
        }

        public Type paramsType() {
            return PingParams.class;
        }

        public Type resultType() {
            return SumResult.class;
        }

        public Object invoke(Object params, JsonRpcInvocationContext context) {
            return new Map<String, Object>{ 'unexpected' => true };
        }
    }

    private class JsonRpcExceptionThrowingHandler implements JsonRpcMethodHandler {
        public String methodName() {
            return 'system.throwJsonRpc';
        }

        public Type paramsType() {
            return PingParams.class;
        }

        public Type resultType() {
            return PingResult.class;
        }

        public Object invoke(Object params, JsonRpcInvocationContext context) {
            throw new JsonRpcException('handler-signaled-error');
        }
    }

    private class DomainException extends Exception {
    }

    private class DomainThrowingHandler implements JsonRpcMethodHandler {
        public String methodName() {
            return 'domain.fail';
        }

        public Type paramsType() {
            return PingParams.class;
        }

        public Type resultType() {
            return PingResult.class;
        }

        public Object invoke(Object params, JsonRpcInvocationContext context) {
            throw new DomainException('domain-fail');
        }
    }

    private class CustomMapper implements JsonRpcExceptionMapper {
        public JsonRpcError mapException(Exception ex, JsonRpcInvocationContext context) {
            if (ex instanceof DomainException) {
                return new JsonRpcError(10010, 'Domain failure', new Map<String, Object>{
                    'method' => context == null ? null : context.methodName
                });
            }
            return JsonRpcError.internalError('fallback');
        }
    }

    private class TestModuleBuilder extends JsonRpcModuleBuilder {
        public override void configure(JsonRpcModule module) {
            module.register(new SumHandler());
            module.register(new PingHandler());
            module.register(new NestedDynamicHandler());
            module.register(new ThrowingHandler());
            module.register(new BadResultHandler());
            module.register(new DomainThrowingHandler());
        }
    }

    @IsTest
    static void testSingleRequestSuccessAndTypedResultSerialization() {
        JsonRpcModule module = new TestModuleBuilder().build();
        String requestJson = '{"jsonrpc":"2.0","method":"math.sum","params":{"a":2,"b":3},"id":1}';

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(requestJson, module);

        System.assertEquals(true, execResult.hasResponse);
        System.assertEquals(false, execResult.isBatch);
        System.assertEquals(1, execResult.responses.size());
        System.assertEquals(false, execResult.responses[0].hasError);

        SumResult typedResult = (SumResult) execResult.responses[0].result;
        System.assertEquals(5, typedResult.sum);

        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(execResult.toJson());
        Map<String, Object> parsedResult = (Map<String, Object>) parsed.get('result');
        System.assertEquals(5, ((Decimal) parsedResult.get('sum')).intValue());
    }

    @IsTest
    static void testNotificationReturnsNoResponse() {
        JsonRpcModule module = new TestModuleBuilder().build();
        String requestJson = '{"jsonrpc":"2.0","method":"system.ping","params":{}}';

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(requestJson, module);

        System.assertEquals(false, execResult.hasResponse);
        System.assertEquals(0, execResult.responses.size());
        System.assertEquals(null, execResult.toJson());
    }

    @IsTest
    static void testInvalidJsonProducesParseError() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute('{"jsonrpc":"2.0",', module);

        System.assertEquals(true, execResult.hasResponse);
        System.assertEquals(JsonRpcConstants.PARSE_ERROR_CODE, execResult.responses[0].error.code);
    }

    @IsTest
    static void testInvalidRequestEnvelopeProducesInvalidRequest() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute('{"jsonrpc":"2.0","id":1}', module);

        System.assertEquals(true, execResult.hasResponse);
        System.assertEquals(JsonRpcConstants.INVALID_REQUEST_CODE, execResult.responses[0].error.code);
    }

    @IsTest
    static void testReservedMethodPrefixRejected() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute('{"jsonrpc":"2.0","method":"rpc.test","id":1}', module);

        System.assertEquals(JsonRpcConstants.INVALID_REQUEST_CODE, execResult.responses[0].error.code);
    }

    @IsTest
    static void testMethodNotFoundMapped() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute('{"jsonrpc":"2.0","method":"math.unknown","id":9}', module);

        System.assertEquals(JsonRpcConstants.METHOD_NOT_FOUND_CODE, execResult.responses[0].error.code);
        System.assertEquals(9, execResult.responses[0].id);
    }

    @IsTest
    static void testInvalidParamsShapeAndValidationMapped() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult badShape = JsonRpcServiceRuntime.execute('{"jsonrpc":"2.0","method":"math.sum","params":[1,2],"id":1}', module);
        System.assertEquals(JsonRpcConstants.INVALID_PARAMS_CODE, badShape.responses[0].error.code);

        JsonRpcExecutionResult badDto = JsonRpcServiceRuntime.execute('{"jsonrpc":"2.0","method":"math.sum","params":{"a":1},"id":2}', module);
        System.assertEquals(JsonRpcConstants.INVALID_PARAMS_CODE, badDto.responses[0].error.code);
    }

    @IsTest
    static void testNestedDynamicParamsAndResultSingleRequest() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(
            '{"jsonrpc":"2.0","method":"debug.nested","params":{"arguments":{"value":"abc"}},"id":1}',
            module
        );

        System.assertEquals(true, execResult.hasResponse);
        System.assertEquals(false, execResult.responses[0].hasError);
        NestedDynamicResult typedResult = (NestedDynamicResult) execResult.responses[0].result;
        System.assertEquals(true, typedResult.meta.get('ok'));

        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(execResult.toJson());
        Map<String, Object> parsedResult = (Map<String, Object>) parsed.get('result');
        List<Object> items = (List<Object>) parsedResult.get('items');
        Map<String, Object> firstItem = (Map<String, Object>) items[0];
        Map<String, Object> meta = (Map<String, Object>) parsedResult.get('meta');
        System.assertEquals('value=abc', firstItem.get('text'));
        System.assertEquals(true, meta.get('ok'));
        System.assertEquals('debug.nested', meta.get('method'));
    }

    @IsTest
    static void testNestedDynamicParamsAndResultBatchRequest() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(
            '[{"jsonrpc":"2.0","method":"debug.nested","params":{"arguments":{"value":"batch"}},"id":2}]',
            module
        );

        System.assertEquals(true, execResult.isBatch);
        System.assertEquals(true, execResult.hasResponse);
        System.assertEquals(1, execResult.responses.size());

        List<Object> parsed = (List<Object>) JSON.deserializeUntyped(execResult.toJson());
        Map<String, Object> response = (Map<String, Object>) parsed[0];
        Map<String, Object> result = (Map<String, Object>) response.get('result');
        List<Object> items = (List<Object>) result.get('items');
        Map<String, Object> firstItem = (Map<String, Object>) items[0];
        System.assertEquals('value=batch', firstItem.get('text'));
    }

    @IsTest
    static void testNestedDynamicParamsValidationMapsToInvalidParams() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(
            '{"jsonrpc":"2.0","method":"debug.nested","params":{"arguments":{}},"id":3}',
            module
        );

        System.assertEquals(JsonRpcConstants.INVALID_PARAMS_CODE, execResult.responses[0].error.code);
    }

    @IsTest
    static void testUnhandledExceptionMappedToInternalError() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute('{"jsonrpc":"2.0","method":"system.explode","params":{},"id":7}', module);

        System.assertEquals(JsonRpcConstants.INTERNAL_ERROR_CODE, execResult.responses[0].error.code);
    }

    @IsTest
    static void testBatchMixedAndNotificationsOmitted() {
        JsonRpcModule module = new TestModuleBuilder().build();
        String batch = '[{"jsonrpc":"2.0","method":"math.sum","params":{"a":1,"b":2},"id":1},' +
            '{"jsonrpc":"2.0","method":"math.sum","params":{"a":1},"id":2},' +
            '{"jsonrpc":"2.0","method":"system.ping","params":{}},' +
            '{"jsonrpc":"2.0","id":3},' +
            '9]';

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(batch, module);

        System.assertEquals(true, execResult.isBatch);
        System.assertEquals(true, execResult.hasResponse);
        System.assertEquals(4, execResult.responses.size());

        List<Object> serialized = (List<Object>) JSON.deserializeUntyped(execResult.toJson());
        System.assertEquals(4, serialized.size());
    }

    @IsTest
    static void testEmptyBatchInvalidRequest() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute('[]', module);

        System.assertEquals(true, execResult.isBatch);
        System.assertEquals(JsonRpcConstants.INVALID_REQUEST_CODE, execResult.responses[0].error.code);
    }

    @IsTest
    static void testAllNotificationsProduceNoResponse() {
        JsonRpcModule module = new TestModuleBuilder().build();
        String batch = '[{"jsonrpc":"2.0","method":"system.ping","params":{}},' +
            '{"jsonrpc":"2.0","method":"system.ping","params":{}}]';

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(batch, module);

        System.assertEquals(true, execResult.isBatch);
        System.assertEquals(false, execResult.hasResponse);
        System.assertEquals(null, execResult.toJson());
    }

    @IsTest
    static void testDuplicateRegistrationRejected() {
        JsonRpcModule module = new JsonRpcModule();
        module.register(new SumHandler());

        try {
            module.register(new SumHandler());
            System.assert(false, 'Expected duplicate registration to throw.');
        } catch (JsonRpcException ex) {
            System.assert(ex.getMessage().contains('Duplicate handler registration'));
        }
    }

    @IsTest
    static void testCustomMapperOverride() {
        JsonRpcModule module = new JsonRpcModule().register(new DomainThrowingHandler());
        JsonRpcServiceRuntimeOptions options = new JsonRpcServiceRuntimeOptions();
        options.exceptionMapper = new CustomMapper();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute('{"jsonrpc":"2.0","method":"domain.fail","params":{},"id":22}', module, options);

        System.assertEquals(10010, execResult.responses[0].error.code);
        System.assertEquals('Domain failure', execResult.responses[0].error.message);
    }

    @IsTest
    static void testInvalidIdTypeIsRejectedWithNullId() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute('{"jsonrpc":"2.0","method":"math.sum","params":{"a":1,"b":2},"id":true}', module);

        System.assertEquals(JsonRpcConstants.INVALID_REQUEST_CODE, execResult.responses[0].error.code);
        System.assertEquals(null, execResult.responses[0].id);
    }

    @IsTest
    static void testResponseValidationExactlyOneOfResultOrError() {
        JsonRpcResponse response = new JsonRpcResponse();
        response.id = 1;
        response.hasResult = true;
        response.result = 'ok';
        response.hasError = true;
        response.error = JsonRpcError.internalError();

        try {
            response.validate();
            System.assert(false, 'Expected response validation failure.');
        } catch (JsonRpcException ex) {
            System.assert(ex.getMessage().contains('exactly one'));
        }
    }

    @IsTest
    static void testBadResultTypeMappingFailsDeterministically() {
        JsonRpcModule module = new JsonRpcModule().register(new BadResultHandler());

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute('{"jsonrpc":"2.0","method":"system.badResult","params":{},"id":5}', module);

        System.assertEquals(JsonRpcConstants.INTERNAL_ERROR_CODE, execResult.responses[0].error.code);
    }

    @IsTest
    static void testHandlerJsonRpcExceptionMapsToInternalError() {
        JsonRpcModule module = new JsonRpcModule().register(new JsonRpcExceptionThrowingHandler());

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(
            '{"jsonrpc":"2.0","method":"system.throwJsonRpc","params":{},"id":6}',
            module
        );

        System.assertEquals(JsonRpcConstants.INTERNAL_ERROR_CODE, execResult.responses[0].error.code);
    }
}
