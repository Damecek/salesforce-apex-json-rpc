// Minimal module with typed request/response DTOs.
public class ExampleSumParams extends JsonRpcParamsBase {
    public Integer a;
    public Integer b;

    public override void validate() {
        if (a == null || b == null) {
            throw new JsonRpcException('a and b are required.');
        }
    }
}

public class ExampleSumResult extends JsonRpcResultBase {
    public Integer sum;
}

public class ExampleSumHandler implements JsonRpcMethodHandler {
    public String methodName() { return 'math.sum'; }
    public Type paramsType() { return ExampleSumParams.class; }
    public Type resultType() { return ExampleSumResult.class; }

    public Object invoke(Object params, JsonRpcInvocationContext context) {
        ExampleSumParams p = (ExampleSumParams) params;
        ExampleSumResult r = new ExampleSumResult();
        r.sum = p.a + p.b;
        return r;
    }
}

JsonRpcModule module = new JsonRpcModule().register(new ExampleSumHandler());
JsonRpcExecutionResult result = JsonRpcServiceRuntime.execute(
    '{"jsonrpc":"2.0","method":"math.sum","params":{"a":2,"b":3},"id":1}',
    module
);
System.debug(result.toJson());
