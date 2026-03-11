/**
 * Contract for a single JSON-RPC method handler.
 */
public abstract inherited sharing class JsonRpcMethodHandler {
    private String declaredMethodName;
    private Type declaredParamsType;
    private Type declaredResultType;

    /**
     * Creates a handler with declared method, params type, and result type.
     *
     * @param methodName JSON-RPC method name.
     * @param paramsType Params type extending JsonRpcParamsBase.
     * @param resultType Result type extending JsonRpcResultBase.
     */
    public JsonRpcMethodHandler(String methodName, Type paramsType, Type resultType) {
        if (String.isBlank(methodName)) {
            throw new JsonRpcException('methodName is required.');
        }
        if (paramsType == null) {
            throw new JsonRpcException('paramsType is required.');
        }
        if (resultType == null) {
            throw new JsonRpcException('resultType is required.');
        }

        this.declaredMethodName = methodName;
        this.declaredParamsType = paramsType;
        this.declaredResultType = resultType;
    }

    /**
     * Returns method name handled by this handler.
     *
     * @return JSON-RPC method name.
     */
    public String methodName() {
        return this.declaredMethodName;
    }

    /**
     * Returns declared params DTO type.
     *
     * @return Params type extending JsonRpcParamsBase.
     */
    public Type paramsType() {
        return this.declaredParamsType;
    }

    /**
     * Returns declared result DTO type.
     *
     * @return Result type extending JsonRpcResultBase.
     */
    public Type resultType() {
        return this.declaredResultType;
    }

    /**
     * Executes the method logic.
     *
     * @param params Deserialized typed params object.
     * @param context Invocation context for this call.
     * @return Method result object compatible with resultType().
     */
    public abstract JsonRpcResultBase invoke(JsonRpcParamsBase params, JsonRpcInvocationContext context);
}
