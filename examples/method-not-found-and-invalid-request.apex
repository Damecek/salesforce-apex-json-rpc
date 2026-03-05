JsonRpcModule module = new JsonRpcModule();

// Method not found -> -32601
JsonRpcExecutionResult notFound = JsonRpcServiceRuntime.execute(
    '{"jsonrpc":"2.0","method":"missing.method","id":1}',
    module
);
System.debug(notFound.toJson());

// Invalid request (missing method) -> -32600
JsonRpcExecutionResult invalidRequest = JsonRpcServiceRuntime.execute(
    '{"jsonrpc":"2.0","id":2}',
    module
);
System.debug(invalidRequest.toJson());
