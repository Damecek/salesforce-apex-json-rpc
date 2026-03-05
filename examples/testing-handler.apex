// Unit-style pattern for a single handler.
ExampleSumParams p = new ExampleSumParams();
p.a = 4;
p.b = 8;
ExampleSumHandler h = new ExampleSumHandler();
ExampleSumResult r = (ExampleSumResult) h.invoke(p, new JsonRpcInvocationContext());
System.assertEquals(12, r.sum);

// Integration-style pattern for runtime + module.
JsonRpcModule module = new JsonRpcModule().register(new ExampleSumHandler());
JsonRpcExecutionResult execution = JsonRpcServiceRuntime.execute(
    '{"jsonrpc":"2.0","method":"math.sum","params":{"a":10,"b":20},"id":77}',
    module
);
System.assertEquals(true, execution.hasResponse);
System.assert(execution.toJson().contains('"sum":30'));
