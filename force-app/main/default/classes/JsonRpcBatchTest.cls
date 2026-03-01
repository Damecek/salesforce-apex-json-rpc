@IsTest
private class JsonRpcBatchTest {
    @IsTest
    static void testBatchWithMixedEntries() {
        String payload = '[{"jsonrpc":"2.0","method":"sum","id":1}, {"jsonrpc":"2.0","method":"notify"}, {"jsonrpc":"2.0"}, 7]';
        JsonRpcProtocol.ParseResult parsed = JsonRpcProtocol.parseRequest(payload);

        System.assertEquals(true, parsed.isBatch);
        System.assertEquals(false, parsed.hasProtocolError());
        System.assertEquals(2, parsed.requests.size());
        System.assertEquals(2, parsed.itemErrors.size());
        System.assertEquals(JsonRpcConstants.INVALID_REQUEST_CODE, parsed.itemErrors[0].error.code);
        System.assertEquals(JsonRpcConstants.INVALID_REQUEST_CODE, parsed.itemErrors[1].error.code);
    }

    @IsTest
    static void testEmptyBatchInvalidRequest() {
        JsonRpcProtocol.ParseResult parsed = JsonRpcProtocol.parseRequest('[]');

        System.assertEquals(true, parsed.isBatch);
        System.assertEquals(true, parsed.hasProtocolError());
        System.assertEquals(JsonRpcConstants.INVALID_REQUEST_CODE, parsed.protocolError.error.code);
        System.assertEquals(null, parsed.protocolError.id);
    }

    @IsTest
    static void testSerializeBatchResponses() {
        List<JsonRpcResponse> responses = new List<JsonRpcResponse>{
            JsonRpcResponse.success(1, 3),
            JsonRpcResponse.failure(2, JsonRpcError.methodNotFound())
        };

        String payload = JsonRpcProtocol.serializeResponses(responses);
        List<Object> parsed = (List<Object>) JSON.deserializeUntyped(payload);

        System.assertEquals(2, parsed.size());
    }

    @IsTest
    static void testAllNotificationsProduceNoPayload() {
        String payload = JsonRpcProtocol.serializeResponses(new List<JsonRpcResponse>());
        System.assertEquals(null, payload);
    }
}
