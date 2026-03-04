/**
 * Execution output for a JSON-RPC request or batch.
 */
public inherited sharing class JsonRpcExecutionResult {
    /** True when response payload should be emitted. */
    public Boolean hasResponse = false;
    /** True when input payload was a batch array. */
    public Boolean isBatch = false;
    /** Collected JSON-RPC responses in output order. */
    public List<JsonRpcResponse> responses = new List<JsonRpcResponse>();

    /**
     * Serializes response payload according to JSON-RPC single/batch rules.
     *
     * @return JSON response payload or null when no response should be emitted.
     */
    public String toJson() {
        if (!this.hasResponse || this.responses == null || this.responses.isEmpty()) {
            return null;
        }

        if (!this.isBatch && this.responses.size() == 1) {
            return JSON.serialize(this.responses[0].toMap());
        }

        List<Object> payload = new List<Object>();
        for (JsonRpcResponse response : this.responses) {
            payload.add(response.toMap());
        }

        return JSON.serialize(payload);
    }
}
