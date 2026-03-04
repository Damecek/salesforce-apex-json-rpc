/**
 * Contract for a single JSON-RPC method handler.
 */
public interface JsonRpcMethodHandler {
    /**
     * Returns method name handled by this handler.
     *
     * @return JSON-RPC method name.
     */
    String methodName();

    /**
     * Returns declared params DTO type.
     *
     * @return Params type extending JsonRpcParamsBase.
     */
    Type paramsType();

    /**
     * Returns declared result DTO type.
     *
     * @return Result type extending JsonRpcResultBase.
     */
    Type resultType();

    /**
     * Executes the method logic.
     *
     * @param params Deserialized typed params object.
     * @param context Invocation context for this call.
     * @return Method result object compatible with resultType().
     */
    Object invoke(Object params, JsonRpcInvocationContext context);
}
