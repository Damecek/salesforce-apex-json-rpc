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

    private class NestedArguments {
        public String value;
    }

    private class NestedTypedParams extends JsonRpcParamsBase {
        public NestedArguments arguments;

        public override void validate() {
            if (this.arguments == null || String.isBlank(this.arguments.value)) {
                throw new JsonRpcException('arguments.value is required.');
            }
        }
    }

    private class NestedTypedResult extends JsonRpcResultBase {
        public String text;
        public Boolean ok;
        public String method;

        public override void validate() {
            if (String.isBlank(this.text)) {
                throw new JsonRpcException('text is required.');
            }
            if (this.ok == null) {
                throw new JsonRpcException('ok is required.');
            }
            if (String.isBlank(this.method)) {
                throw new JsonRpcException('method is required.');
            }
        }
    }

    private class IdEchoResult extends JsonRpcResultBase {
        public Boolean hadId;
        public Boolean idWasNull;
        public String idString;

        public override void validate() {
            if (this.hadId == null || this.idWasNull == null) {
                throw new JsonRpcException('id flags are required.');
            }
        }
    }

    private class SumHandler extends JsonRpcMethodHandler {
        public SumHandler() {
            super('math.sum', SumParams.class, SumResult.class);
        }

        public override JsonRpcResultBase invoke(JsonRpcParamsBase params, JsonRpcInvocationContext context) {
            SumParams typed = (SumParams) params;
            SumResult result = new SumResult();
            result.sum = typed.a + typed.b;
            return result;
        }
    }

    private class PingHandler extends JsonRpcMethodHandler {
        public PingHandler() {
            super('system.ping', PingParams.class, PingResult.class);
        }

        public override JsonRpcResultBase invoke(JsonRpcParamsBase params, JsonRpcInvocationContext context) {
            PingResult result = new PingResult();
            result.status = 'ok';
            return result;
        }
    }

    private class NestedTypedHandler extends JsonRpcMethodHandler {
        public NestedTypedHandler() {
            super('debug.nested', NestedTypedParams.class, NestedTypedResult.class);
        }

        public override JsonRpcResultBase invoke(JsonRpcParamsBase params, JsonRpcInvocationContext context) {
            NestedTypedParams typed = (NestedTypedParams) params;
            NestedTypedResult result = new NestedTypedResult();
            result.text = 'value=' + typed.arguments.value;
            result.ok = true;
            result.method = context.methodName;
            return result;
        }
    }

    private class IdEchoHandler extends JsonRpcMethodHandler {
        public IdEchoHandler() {
            super('debug.idEcho', PingParams.class, IdEchoResult.class);
        }

        public override JsonRpcResultBase invoke(JsonRpcParamsBase params, JsonRpcInvocationContext context) {
            IdEchoResult result = new IdEchoResult();
            result.hadId = context.hasRequestId;
            result.idWasNull = context.requestId.isNull();
            result.idString = context.requestId.isNull() ? null : String.valueOf(context.requestId.toRaw());
            return result;
        }
    }

    private class ThrowingHandler extends JsonRpcMethodHandler {
        public ThrowingHandler() {
            super('system.explode', PingParams.class, PingResult.class);
        }

        public override JsonRpcResultBase invoke(JsonRpcParamsBase params, JsonRpcInvocationContext context) {
            Integer x = 1 / 0;
            return null;
        }
    }

    private class BadResultHandler extends JsonRpcMethodHandler {
        public BadResultHandler() {
            super('system.badResult', PingParams.class, SumResult.class);
        }

        public override JsonRpcResultBase invoke(JsonRpcParamsBase params, JsonRpcInvocationContext context) {
            PingResult result = new PingResult();
            result.status = 'unexpected';
            return result;
        }
    }

    private class JsonRpcExceptionThrowingHandler extends JsonRpcMethodHandler {
        public JsonRpcExceptionThrowingHandler() {
            super('system.throwJsonRpc', PingParams.class, PingResult.class);
        }

        public override JsonRpcResultBase invoke(JsonRpcParamsBase params, JsonRpcInvocationContext context) {
            throw new JsonRpcException('handler-signaled-error');
        }
    }

    private class DomainException extends Exception {
    }

    private class DomainThrowingHandler extends JsonRpcMethodHandler {
        public DomainThrowingHandler() {
            super('domain.fail', PingParams.class, PingResult.class);
        }

        public override JsonRpcResultBase invoke(JsonRpcParamsBase params, JsonRpcInvocationContext context) {
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
            module.register(new NestedTypedHandler());
            module.register(new IdEchoHandler());
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
        System.assertEquals('1', String.valueOf(execResult.responses[0].id.toRaw()));

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
    static void testExplicitNullIdProducesResponse() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(
            '{"jsonrpc":"2.0","method":"system.ping","params":{},"id":null}',
            module
        );

        System.assertEquals(true, execResult.hasResponse);
        System.assertEquals(true, execResult.responses[0].id.isNull());
    }

    @IsTest
    static void testIdEchoTracksNullIdInContext() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(
            '{"jsonrpc":"2.0","method":"debug.idEcho","params":{},"id":null}',
            module
        );

        IdEchoResult typedResult = (IdEchoResult) execResult.responses[0].result;
        System.assertEquals(true, typedResult.hadId);
        System.assertEquals(true, typedResult.idWasNull);
        System.assertEquals(null, typedResult.idString);
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
        System.assertEquals('9', String.valueOf(execResult.responses[0].id.toRaw()));
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
    static void testTypedNestedParamsAndResultSingleRequest() {
        JsonRpcModule module = new TestModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(
            '{"jsonrpc":"2.0","method":"debug.nested","params":{"arguments":{"value":"abc"}},"id":1}',
            module
        );

        System.assertEquals(true, execResult.hasResponse);
        System.assertEquals(false, execResult.responses[0].hasError);
        NestedTypedResult typedResult = (NestedTypedResult) execResult.responses[0].result;
        System.assertEquals(true, typedResult.ok);
        System.assertEquals('value=abc', typedResult.text);

        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(execResult.toJson());
        Map<String, Object> parsedResult = (Map<String, Object>) parsed.get('result');
        System.assertEquals('value=abc', parsedResult.get('text'));
        System.assertEquals(true, parsedResult.get('ok'));
        System.assertEquals('debug.nested', parsedResult.get('method'));
    }

    @IsTest
    static void testTypedNestedParamsAndResultBatchRequest() {
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
        System.assertEquals('value=batch', result.get('text'));
    }

    @IsTest
    static void testTypedNestedParamsValidationMapsToInvalidParams() {
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
    static void testBatchMcpLikePayloadProducesMethodNotFoundPerItem() {
        JsonRpcModule module = new TestModuleBuilder().build();
        String batch = '[' +
            '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}},' +
            '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}},' +
            '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"opportunity.fetch_with_assets","arguments":{"opportunityId":"006AP00000StfLlYAJ"}}},' +
            '{"jsonrpc":"2.0","id":4,"method":"resources/read","params":{"uri":"mcp://opportunity-assets/schema"}},' +
            '{"jsonrpc":"2.0","id":5,"method":"prompts/get","params":{"name":"opportunity.customer_reply_draft","arguments":{"opportunityId":"006AP00000StfLlYAJ","tone":"friendly"}}}' +
            ']';

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(batch, module);

        System.assertEquals(true, execResult.isBatch);
        System.assertEquals(true, execResult.hasResponse);
        System.assertEquals(5, execResult.responses.size());

        for (Integer i = 0; i < execResult.responses.size(); i++) {
            JsonRpcResponse response = execResult.responses[i];
            Integer expectedId = i + 1;

            System.assertEquals(true, response.hasError);
            System.assertEquals(false, response.hasResult);
            System.assertEquals(String.valueOf(expectedId), String.valueOf(response.id.toRaw()));
            System.assertEquals(JsonRpcConstants.METHOD_NOT_FOUND_CODE, response.error.code);
        }

        List<Object> serialized = (List<Object>) JSON.deserializeUntyped(execResult.toJson());
        System.assertEquals(5, serialized.size());

        for (Integer i = 0; i < serialized.size(); i++) {
            Map<String, Object> response = (Map<String, Object>) serialized[i];
            Map<String, Object> error = (Map<String, Object>) response.get('error');
            Integer expectedId = i + 1;

            System.assertEquals(expectedId, ((Decimal) response.get('id')).intValue());
            System.assertEquals(JsonRpcConstants.METHOD_NOT_FOUND_CODE, ((Decimal) error.get('code')).intValue());
        }
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
        System.assertEquals(true, execResult.responses[0].id.isNull());
    }

    @IsTest
    static void testResponseValidationExactlyOneOfResultOrError() {
        JsonRpcResponse response = new JsonRpcResponse();
        response.id = JsonRpcIdValue.fromRaw(1);
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
