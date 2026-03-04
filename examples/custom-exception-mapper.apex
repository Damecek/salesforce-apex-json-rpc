public class DomainFailureException extends Exception {
}

public class ExampleFailParams extends JsonRpcParamsBase {
}

public class ExampleFailResult extends JsonRpcResultBase {
    public String status;
}

public class ExampleFailHandler implements JsonRpcMethodHandler {
    public String methodName() { return 'domain.fail'; }
    public Type paramsType() { return ExampleFailParams.class; }
    public Type resultType() { return ExampleFailResult.class; }

    public Object invoke(Object params, JsonRpcInvocationContext context) {
        throw new DomainFailureException('rule failed');
    }
}

public class ExampleMapper implements JsonRpcExceptionMapper {
    public JsonRpcError map(Exception ex, JsonRpcInvocationContext context) {
        if (ex instanceof DomainFailureException) {
            return new JsonRpcError(12001, 'Domain failure', new Map<String, Object>{
                'method' => context.methodName
            });
        }
        return JsonRpcError.internalError();
    }
}

JsonRpcServiceRuntimeOptions options = new JsonRpcServiceRuntimeOptions();
options.exceptionMapper = new ExampleMapper();

JsonRpcModule module = new JsonRpcModule().register(new ExampleFailHandler());
JsonRpcExecutionResult result = JsonRpcServiceRuntime.execute(
    '{"jsonrpc":"2.0","method":"domain.fail","params":{},"id":9}',
    module,
    options
);
System.debug(result.toJson());
