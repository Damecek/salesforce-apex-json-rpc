public class DomainFailureException extends Exception {
}

public class ExampleFailParams extends JsonRpcParamsBase {
}

public class ExampleFailResult extends JsonRpcResultBase {
    public String status;
}

public class ExampleFailHandler extends JsonRpcMethodHandler {
    public ExampleFailHandler() {
        super('domain.fail', ExampleFailParams.class, ExampleFailResult.class);
    }

    public override JsonRpcResultBase invoke(JsonRpcParamsBase params, JsonRpcInvocationContext context) {
        throw new DomainFailureException('rule failed');
    }
}

public class ExampleMapper implements JsonRpcExceptionMapper {
    public JsonRpcError mapException(Exception ex, JsonRpcInvocationContext context) {
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
