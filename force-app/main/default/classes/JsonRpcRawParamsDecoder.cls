/**
 * Optional hook for params DTOs that need direct access to raw untyped JSON payloads.
 */
public interface JsonRpcRawParamsDecoder {
    /**
     * Populates this DTO from the raw untyped `params` payload.
     *
     * @param rawParams Untyped JSON-RPC `params` object or array.
     */
    void decodeRawParams(Object rawParams);
}
