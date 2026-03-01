@IsTest
private class JsonRpcParsingTest {
    @IsTest
    static void testMalformedJsonParseError() {
        JsonRpcProtocol.ParseResult parsed = JsonRpcProtocol.parseRequest('{"jsonrpc":"2.0",');

        System.assertEquals(true, parsed.hasProtocolError());
        System.assertEquals(JsonRpcConstants.PARSE_ERROR_CODE, parsed.protocolError.error.code);
        System.assertEquals(null, parsed.protocolError.id);
    }

    @IsTest
    static void testNonObjectOrArrayIsInvalidRequest() {
        JsonRpcProtocol.ParseResult parsed = JsonRpcProtocol.parseRequest('1');

        System.assertEquals(true, parsed.hasProtocolError());
        System.assertEquals(JsonRpcConstants.INVALID_REQUEST_CODE, parsed.protocolError.error.code);
    }

    @IsTest
    static void testReservedMethodPrefixRejected() {
        String payload = '{"jsonrpc":"2.0","method":"rpc.test","id":1}';
        JsonRpcProtocol.ParseResult parsed = JsonRpcProtocol.parseRequest(payload);

        System.assertEquals(true, parsed.hasProtocolError());
        System.assertEquals(JsonRpcConstants.INVALID_REQUEST_CODE, parsed.protocolError.error.code);
    }

    @IsTest
    static void testResponseFromMapValidation() {
        Map<String, Object> raw = new Map<String, Object>{
            'jsonrpc' => '2.0',
            'id' => 1,
            'result' => null
        };

        JsonRpcResponse parsed = JsonRpcResponse.fromMap(raw);
        System.assertEquals(true, parsed.hasResult);
        System.assertEquals(false, parsed.hasError);
    }
}
