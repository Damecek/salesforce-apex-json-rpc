public inherited sharing class JsonRpcResponse {
    public String jsonrpc = JsonRpcConstants.VERSION;
    public Object result;
    public JsonRpcError error;
    public Object id;

    public Boolean hasResult = false;
    public Boolean hasError = false;

    /**
     * Creates a successful JSON-RPC response.
     *
     * @param requestId Request id to correlate response.
     * @param responseResult Method execution result.
     * @return JSON-RPC success response.
     */
    public static JsonRpcResponse success(Object requestId, Object responseResult) {
        JsonRpcResponse response = new JsonRpcResponse();
        response.id = requestId;
        response.result = responseResult;
        response.hasResult = true;
        response.hasError = false;
        return response;
    }

    /**
     * Creates an error JSON-RPC response.
     *
     * @param requestId Request id to correlate response.
     * @param responseError JSON-RPC error payload.
     * @return JSON-RPC failure response.
     */
    public static JsonRpcResponse failure(Object requestId, JsonRpcError responseError) {
        JsonRpcResponse response = new JsonRpcResponse();
        response.id = requestId;
        response.error = responseError;
        response.hasResult = false;
        response.hasError = true;
        return response;
    }

    /**
     * Validates this response against JSON-RPC 2.0 constraints.
     */
    public void validate() {
        if (this.jsonrpc != JsonRpcConstants.VERSION) {
            throw new JsonRpcException('jsonrpc must be exactly "2.0".');
        }

        if (this.hasResult == this.hasError) {
            throw new JsonRpcException('response must include exactly one of result or error.');
        }

        if (!JsonRpcId.isSupported(this.id)) {
            throw new JsonRpcException('response id must be String, Integer, Long, Decimal, or null.');
        }

        if (this.hasError) {
            if (this.error == null) {
                throw new JsonRpcException('error object is required when hasError is true.');
            }
            this.error.validate();
        }
    }

    /**
     * Converts this response into a serializable map.
     *
     * @return Map representation of the response object.
     */
    public Map<String, Object> toMap() {
        this.validate();

        Map<String, Object> raw = new Map<String, Object>{
            'jsonrpc' => this.jsonrpc,
            'id' => this.id
        };

        if (this.hasResult) {
            raw.put('result', this.result);
        }

        if (this.hasError) {
            raw.put('error', this.error.toMap());
        }

        return raw;
    }

    /**
     * Builds a JSON-RPC response from an untyped map payload.
     *
     * @param raw Untyped response object map.
     * @return Parsed and validated response.
     */
    public static JsonRpcResponse fromMap(Map<String, Object> raw) {
        if (raw == null) {
            throw new JsonRpcException('JSON-RPC response payload must be an object.');
        }

        JsonRpcResponse parsed = new JsonRpcResponse();

        if (!(raw.get('jsonrpc') instanceof String)) {
            throw new JsonRpcException('jsonrpc must be a string.');
        }

        parsed.jsonrpc = (String) raw.get('jsonrpc');
        parsed.id = raw.get('id');

        parsed.hasResult = raw.containsKey('result');
        parsed.result = raw.get('result');

        parsed.hasError = raw.containsKey('error');
        if (parsed.hasError) {
            if (!(raw.get('error') instanceof Map<String, Object>)) {
                throw new JsonRpcException('error must be an object.');
            }
            parsed.error = JsonRpcError.fromMap((Map<String, Object>) raw.get('error'));
        }

        parsed.validate();
        return parsed;
    }
}
