/**
 * Strategy for mapping runtime exceptions to JSON-RPC error objects.
 */
public interface JsonRpcExceptionMapper {
    /**
     * Maps an exception to a JSON-RPC error.
     *
     * @param ex Thrown exception.
     * @param context Invocation context for the current request item.
     * @return JSON-RPC error to emit.
     */
    JsonRpcError mapException(Exception ex, JsonRpcInvocationContext context);
}
