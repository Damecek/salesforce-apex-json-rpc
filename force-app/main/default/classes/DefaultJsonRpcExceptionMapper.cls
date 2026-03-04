/**
 * Default exception mapper translating framework exceptions to standard
 * JSON-RPC error codes.
 */
public inherited sharing class DefaultJsonRpcExceptionMapper implements JsonRpcExceptionMapper {
    private Boolean includeInternalErrorDetails;

    /**
     * Creates mapper with internal error details disabled.
     */
    public DefaultJsonRpcExceptionMapper() {
        this(false);
    }

    /**
     * Creates mapper and controls whether internal error details are exposed.
     *
     * @param includeDetails True to include exception message in internal errors.
     */
    public DefaultJsonRpcExceptionMapper(Boolean includeDetails) {
        this.includeInternalErrorDetails = includeDetails == true;
    }

    /**
     * Maps framework and user exceptions into JSON-RPC error objects.
     *
     * @param ex Thrown exception.
     * @param context Invocation context for the current request item.
     * @return JSON-RPC error object.
     */
    public JsonRpcError mapException(Exception ex, JsonRpcInvocationContext context) {
        if (ex instanceof JsonRpcServiceRuntime.ParseFailureException) {
            return JsonRpcError.parseError(ex.getMessage());
        }

        if (ex instanceof JsonRpcServiceRuntime.InvalidRequestException) {
            return JsonRpcError.invalidRequest(ex.getMessage());
        }

        if (ex instanceof JsonRpcServiceRuntime.MethodNotFoundException) {
            return JsonRpcError.methodNotFound(ex.getMessage());
        }

        if (ex instanceof JsonRpcServiceRuntime.InvalidParamsException) {
            return JsonRpcError.invalidParams(ex.getMessage());
        }

        if (ex instanceof JsonRpcException) {
            return JsonRpcError.invalidParams(ex.getMessage());
        }

        if (this.includeInternalErrorDetails) {
            return JsonRpcError.internalError(ex.getMessage());
        }

        return JsonRpcError.internalError();
    }
}
