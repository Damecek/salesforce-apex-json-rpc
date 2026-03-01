@IsTest
private class JsonRpcCoreTest {
    @IsTest
    static void testRequestSerializationAndParsing() {
        JsonRpcRequest request = new JsonRpcRequest('sum', 1);
        request.params = new List<Object>{1, 2};
        request.validate();

        String payload = JSON.serialize(request.toMap());
        JsonRpcProtocol.ParseResult parsed = JsonRpcProtocol.parseRequest(payload);

        System.assertEquals(false, parsed.hasProtocolError());
        System.assertEquals(1, parsed.requests.size());
        System.assertEquals('sum', parsed.requests[0].method);
        System.assertEquals(true, parsed.requests[0].hasId);
        System.assertEquals(0, parsed.itemErrors.size());
    }

    @IsTest
    static void testInvalidJsonrpcRejected() {
        String payload = '{"jsonrpc":"1.0","method":"sum","id":1}';
        JsonRpcProtocol.ParseResult parsed = JsonRpcProtocol.parseRequest(payload);

        System.assertEquals(true, parsed.hasProtocolError());
        System.assertEquals(JsonRpcConstants.INVALID_REQUEST_CODE, parsed.protocolError.error.code);
        System.assertEquals(1, parsed.protocolError.id);
    }

    @IsTest
    static void testMissingMethodRejected() {
        String payload = '{"jsonrpc":"2.0","id":1}';
        JsonRpcProtocol.ParseResult parsed = JsonRpcProtocol.parseRequest(payload);

        System.assertEquals(true, parsed.hasProtocolError());
        System.assertEquals(JsonRpcConstants.INVALID_REQUEST_CODE, parsed.protocolError.error.code);
    }

    @IsTest
    static void testInvalidIdTypeRejected() {
        String payload = '{"jsonrpc":"2.0","method":"sum","id":true}';
        JsonRpcProtocol.ParseResult parsed = JsonRpcProtocol.parseRequest(payload);

        System.assertEquals(true, parsed.hasProtocolError());
        System.assertEquals(JsonRpcConstants.INVALID_REQUEST_CODE, parsed.protocolError.error.code);
        System.assertEquals(null, parsed.protocolError.id);
    }

    @IsTest
    static void testNotificationHasNoId() {
        JsonRpcRequest notification = new JsonRpcRequest('update');
        notification.params = new Map<String, Object>{'status' => 'ok'};
        notification.validate();

        System.assertEquals(true, notification.isNotification());

        String payload = JSON.serialize(notification.toMap());
        JsonRpcProtocol.ParseResult parsed = JsonRpcProtocol.parseRequest(payload);

        System.assertEquals(false, parsed.hasProtocolError());
        System.assertEquals(true, parsed.requests[0].isNotification());
    }

    @IsTest
    static void testSuccessResponse() {
        JsonRpcResponse response = JsonRpcResponse.success(5, 'done');
        response.validate();

        String payload = JsonRpcProtocol.serializeResponse(response);
        Map<String, Object> raw = (Map<String, Object>) JSON.deserializeUntyped(payload);

        System.assertEquals('2.0', (String) raw.get('jsonrpc'));
        System.assertEquals('done', (String) raw.get('result'));
        System.assertEquals(5, (Integer) raw.get('id'));
    }

    @IsTest
    static void testErrorResponse() {
        JsonRpcResponse response = JsonRpcResponse.failure(9, JsonRpcError.methodNotFound());
        response.validate();

        String payload = JsonRpcProtocol.serializeResponse(response);
        Map<String, Object> raw = (Map<String, Object>) JSON.deserializeUntyped(payload);
        Map<String, Object> error = (Map<String, Object>) raw.get('error');

        System.assertEquals(JsonRpcConstants.METHOD_NOT_FOUND_CODE, ((Decimal) error.get('code')).intValue());
    }

    @IsTest
    static void testInvalidResponseResultAndError() {
        JsonRpcResponse response = new JsonRpcResponse();
        response.id = 1;
        response.result = 'ok';
        response.error = JsonRpcError.internalError();
        response.hasResult = true;
        response.hasError = true;

        try {
            response.validate();
            System.assert(false, 'Expected exception for invalid response payload.');
        } catch (JsonRpcException ex) {
            System.assert(ex.getMessage().contains('exactly one'));
        }
    }

    @IsTest
    static void testStandardErrorsFactories() {
        System.assertEquals(-32700, JsonRpcError.parseError().code);
        System.assertEquals(-32600, JsonRpcError.invalidRequest().code);
        System.assertEquals(-32601, JsonRpcError.methodNotFound().code);
        System.assertEquals(-32602, JsonRpcError.invalidParams().code);
        System.assertEquals(-32603, JsonRpcError.internalError().code);
    }
}
