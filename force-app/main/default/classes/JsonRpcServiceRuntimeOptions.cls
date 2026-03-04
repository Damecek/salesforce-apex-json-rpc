/**
 * Runtime options for JSON-RPC execution.
 */
public inherited sharing class JsonRpcServiceRuntimeOptions {
    /** Custom exception mapper. When null, DefaultJsonRpcExceptionMapper is used. */
    public JsonRpcExceptionMapper exceptionMapper;
    /** Controls inclusion of internal exception message in internal errors. */
    public Boolean includeInternalErrorDetails = false;

    /**
     * Creates runtime options with default values.
     */
    public JsonRpcServiceRuntimeOptions() {
    }
}
