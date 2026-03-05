// Batch request with mixed outcomes.
JsonRpcModule module = new JsonRpcModule().register(new ExampleSumHandler());

String batchPayload = '[{"jsonrpc":"2.0","method":"math.sum","params":{"a":1,"b":2},"id":1},' +
    '{"jsonrpc":"2.0","method":"math.sum","params":{"a":1},"id":2},' +
    '{"jsonrpc":"2.0","method":"math.sum","params":{"a":5,"b":6}},' +
    '7]';

JsonRpcExecutionResult batchResult = JsonRpcServiceRuntime.execute(batchPayload, module);

// Response includes success + invalid params + invalid request.
// Notification item (without id) is intentionally omitted.
System.debug(batchResult.toJson());
