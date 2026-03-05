/**
 * Base class for typed JSON-RPC result DTOs.
 */
public virtual class JsonRpcResultBase {
    /**
     * Hook for DTO-level validation.
     */
    public virtual void validate() {
    }
}
