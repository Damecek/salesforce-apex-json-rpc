/**
 * JSON-RPC response envelope for success or failure outcomes.
 */
public inherited sharing class JsonRpcResponse {
    /** JSON-RPC protocol version, fixed to "2.0". */
    public String jsonrpc = JsonRpcConstants.VERSION;
    /** Result payload for successful responses. */
    public Object result;
    /** Error payload for failed responses. */
    public JsonRpcError error;
    /** Request id correlated to this response. */
    public Object id;

    /** True when result is present in this response. */
    public Boolean hasResult = false;
    /** True when error is present in this response. */
    public Boolean hasError = false;

    /**
     * Creates a successful response.
     *
     * @param requestId Request id to correlate with the call.
     * @param responseResult Method result payload.
     * @return Successful JSON-RPC response.
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
     * Creates a failed response.
     *
     * @param requestId Request id to correlate with the call.
     * @param responseError JSON-RPC error object.
     * @return Failed JSON-RPC response.
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
     * Validates protocol-level response constraints.
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
     * Converts this response into an untyped map for JSON serialization.
     *
     * @return Serializable response map.
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
     * Parses an untyped map into a validated JSON-RPC response.
     *
     * @param raw Untyped response map.
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

            Map<String, Object> errorRaw = (Map<String, Object>) raw.get('error');
            parsed.error = new JsonRpcError();
            Object errorCode = errorRaw.get('code');

            if (errorCode instanceof Integer) {
                parsed.error.code = (Integer) errorCode;
            } else if (errorCode instanceof Long) {
                parsed.error.code = Integer.valueOf(String.valueOf(errorCode));
            } else if (errorCode instanceof Decimal) {
                parsed.error.code = ((Decimal) errorCode).intValue();
            } else {
                throw new JsonRpcException('JSON-RPC error code must be a number.');
            }

            if (!(errorRaw.get('message') instanceof String)) {
                throw new JsonRpcException('JSON-RPC error message must be a string.');
            }

            parsed.error.message = (String) errorRaw.get('message');
            parsed.error.data = errorRaw.get('data');
        }

        parsed.validate();
        return parsed;
    }
}
