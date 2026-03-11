@IsTest
private class JsonRpcSpecificationExamplesTest {
    private class SubtractParams extends JsonRpcParamsBase {
        public Integer minuend;
        public Integer subtrahend;

        public override void validate() {
            if (minuend == null || subtrahend == null) {
                throw new JsonRpcException('minuend and subtrahend are required.');
            }
        }
    }

    private class ScalarResult extends JsonRpcResultBase {
        public Integer value;

        public override void validate() {
            if (value == null) {
                throw new JsonRpcException('value is required.');
            }
        }
    }

    private class EmptyParams extends JsonRpcParamsBase {
    }

    private class EmptyResult extends JsonRpcResultBase {
        public override void validate() {
        }
    }

    private class SubtractHandler extends JsonRpcMethodHandler {
        public SubtractHandler() {
            super('subtract', SubtractParams.class, ScalarResult.class);
        }

        public override JsonRpcResultBase invoke(JsonRpcParamsBase params, JsonRpcInvocationContext context) {
            SubtractParams typed = (SubtractParams) params;
            ScalarResult result = new ScalarResult();
            result.value = typed.minuend - typed.subtrahend;
            return result;
        }
    }

    private class FoobarHandler extends JsonRpcMethodHandler {
        public FoobarHandler() {
            super('foobar', EmptyParams.class, EmptyResult.class);
        }

        public override JsonRpcResultBase invoke(JsonRpcParamsBase params, JsonRpcInvocationContext context) {
            return new EmptyResult();
        }
    }

    private class SpecificationExamplesModuleBuilder extends JsonRpcModuleBuilder {
        public override void configure(JsonRpcModule module) {
            module.register(new SubtractHandler());
            module.register(new FoobarHandler());
        }
    }

    @IsTest
    static void testSpecificationExampleNamedParamsRequest() {
        JsonRpcModule module = new SpecificationExamplesModuleBuilder().build();
        String requestJson = '{"jsonrpc":"2.0","method":"subtract","params":{"subtrahend":23,"minuend":42},"id":3}';

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(requestJson, module);

        System.assertEquals(true, execResult.hasResponse);
        System.assertEquals(false, execResult.isBatch);
        System.assertEquals(1, execResult.responses.size());
        System.assertEquals(false, execResult.responses[0].hasError);
        System.assertEquals('3', String.valueOf(execResult.responses[0].id.toRaw()));

        ScalarResult typedResult = (ScalarResult) execResult.responses[0].result;
        System.assertEquals(19, typedResult.value);
    }

    @IsTest
    static void testSpecificationExampleNotificationWithoutParams() {
        JsonRpcModule module = new SpecificationExamplesModuleBuilder().build();
        String requestJson = '{"jsonrpc":"2.0","method":"foobar"}';

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(requestJson, module);

        System.assertEquals(false, execResult.hasResponse);
        System.assertEquals(0, execResult.responses.size());
        System.assertEquals(null, execResult.toJson());
    }

    @IsTest
    static void testSpecificationExampleInvalidRequestBatchPayload() {
        JsonRpcModule module = new SpecificationExamplesModuleBuilder().build();

        JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute('[1]', module);

        System.assertEquals(true, execResult.isBatch);
        System.assertEquals(true, execResult.hasResponse);
        System.assertEquals(1, execResult.responses.size());
        System.assertEquals(JsonRpcConstants.INVALID_REQUEST_CODE, execResult.responses[0].error.code);
        System.assertEquals(true, execResult.responses[0].id.isNull());
    }

    @IsTest
    static void testSpecificationExampleSuccessResponsePayload() {
        JsonRpcResponse response = JsonRpcResponse.fromMap(
            (Map<String, Object>) JSON.deserializeUntyped('{"jsonrpc":"2.0","result":19,"id":1}')
        );

        System.assertEquals(false, response.hasError);
        System.assertEquals(true, response.hasResult);
        System.assertEquals(19, ((Decimal) response.result).intValue());
        System.assertEquals('1', String.valueOf(response.id.toRaw()));
    }

    @IsTest
    static void testSpecificationExampleMethodNotFoundResponsePayload() {
        JsonRpcResponse response = JsonRpcResponse.fromMap(
            (Map<String, Object>) JSON.deserializeUntyped(
                '{"jsonrpc":"2.0","error":{"code":-32601,"message":"Method not found"},"id":"1"}'
            )
        );

        System.assertEquals(true, response.hasError);
        System.assertEquals(false, response.hasResult);
        System.assertEquals(JsonRpcConstants.METHOD_NOT_FOUND_CODE, response.error.code);
        System.assertEquals(JsonRpcConstants.METHOD_NOT_FOUND_MESSAGE, response.error.message);
        System.assertEquals('1', response.id.asString());
    }

    @IsTest
    static void testSpecificationExampleParseErrorResponsePayload() {
        JsonRpcResponse response = JsonRpcResponse.fromMap(
            (Map<String, Object>) JSON.deserializeUntyped(
                '{"jsonrpc":"2.0","error":{"code":-32700,"message":"Parse error"},"id":null}'
            )
        );

        System.assertEquals(true, response.hasError);
        System.assertEquals(false, response.hasResult);
        System.assertEquals(JsonRpcConstants.PARSE_ERROR_CODE, response.error.code);
        System.assertEquals(JsonRpcConstants.PARSE_ERROR_MESSAGE, response.error.message);
        System.assertEquals(true, response.id.isNull());
    }
}
