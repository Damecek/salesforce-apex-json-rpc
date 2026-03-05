/**
 * Invocation metadata passed to method handlers and error mappers.
 */
public inherited sharing class JsonRpcInvocationContext {
    /** Request id from incoming payload. */
    public Object requestId;
    /** JSON-RPC method name. */
    public String methodName;
    /** Raw untyped request envelope map. */
    public Map<String, Object> rawRequest;
    /** Zero-based item index in batch payload. */
    public Integer batchIndex;
    /** Optional correlation metadata populated by callers. */
    public Map<String, Object> correlationMetadata = new Map<String, Object>();
}
