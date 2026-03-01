// Single request -> parse -> success response
String rawRequest = '{"jsonrpc":"2.0","method":"sum","params":[1,2],"id":1}';

JsonRpcProtocol.ParseResult parsed = JsonRpcProtocol.parseRequest(rawRequest);
if (parsed.hasProtocolError()) {
    String errorJson = JsonRpcProtocol.serializeResponse(parsed.protocolError);
    System.debug(errorJson);
} else {
    JsonRpcRequest request = parsed.requests[0];
    // Your method execution is intentionally outside this library.
    JsonRpcResponse response = JsonRpcResponse.success(request.id, 3);
    String responseJson = JsonRpcProtocol.serializeResponse(response);
    System.debug(responseJson);
}
