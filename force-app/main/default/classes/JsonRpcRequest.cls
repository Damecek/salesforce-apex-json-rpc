public inherited sharing class JsonRpcRequest {
    public String jsonrpc = JsonRpcConstants.VERSION;
    public String method;
    public Object params;
    public Object id;
    public Boolean hasId = false;

    /**
     * Creates an empty JSON-RPC request.
     */
    public JsonRpcRequest() {
    }

    /**
     * Creates a JSON-RPC notification-style request (without id).
     *
     * @param methodName JSON-RPC method name.
     */
    public JsonRpcRequest(String methodName) {
        this.method = methodName;
        this.hasId = false;
    }

    /**
     * Creates a JSON-RPC request with an explicit id.
     *
     * @param methodName JSON-RPC method name.
     * @param requestId JSON-RPC request id.
     */
    public JsonRpcRequest(String methodName, Object requestId) {
        this.method = methodName;
        this.id = requestId;
        this.hasId = true;
    }

    /**
     * Indicates whether the request is a notification.
     *
     * @return True when id is omitted.
     */
    public Boolean isNotification() {
        return !this.hasId;
    }

    /**
     * Validates this request against JSON-RPC 2.0 constraints.
     */
    public void validate() {
        if (this.jsonrpc != JsonRpcConstants.VERSION) {
            throw new JsonRpcException('jsonrpc must be exactly "2.0".');
        }

        if (String.isBlank(this.method)) {
            throw new JsonRpcException('method is required and must be a non-empty string.');
        }

        if (this.method.startsWith(JsonRpcConstants.RESERVED_METHOD_PREFIX)) {
            throw new JsonRpcException('method names starting with "rpc." are reserved.');
        }

        if (this.params != null && !(this.params instanceof List<Object>) && !(this.params instanceof Map<String, Object>)) {
            throw new JsonRpcException('params must be either an array or an object.');
        }

        if (this.hasId) {
            if (!JsonRpcId.isSupported(this.id)) {
                throw new JsonRpcException('id must be String, Integer, Long, Decimal, or null.');
            }
        } else if (this.id != null) {
            throw new JsonRpcException('id value cannot be set when hasId is false.');
        }
    }

    /**
     * Converts this request into a serializable map.
     *
     * @return Map representation of the request object.
     */
    public Map<String, Object> toMap() {
        this.validate();

        Map<String, Object> raw = new Map<String, Object>{
            'jsonrpc' => this.jsonrpc,
            'method' => this.method
        };

        if (this.params != null) {
            raw.put('params', this.params);
        }

        if (this.hasId) {
            raw.put('id', this.id);
        }

        return raw;
    }

    /**
     * Builds a JSON-RPC request from an untyped map payload.
     *
     * @param raw Untyped request object map.
     * @return Parsed and validated request.
     */
    public static JsonRpcRequest fromMap(Map<String, Object> raw) {
        if (raw == null) {
            throw new JsonRpcException('JSON-RPC request payload must be an object.');
        }

        JsonRpcRequest parsed = new JsonRpcRequest();

        if (!(raw.get('jsonrpc') instanceof String)) {
            throw new JsonRpcException('jsonrpc must be a string.');
        }

        parsed.jsonrpc = (String) raw.get('jsonrpc');

        if (!(raw.get('method') instanceof String)) {
            throw new JsonRpcException('method must be a string.');
        }

        parsed.method = (String) raw.get('method');
        parsed.params = raw.get('params');
        parsed.hasId = raw.containsKey('id');
        parsed.id = raw.get('id');
        parsed.validate();
        return parsed;
    }
}
