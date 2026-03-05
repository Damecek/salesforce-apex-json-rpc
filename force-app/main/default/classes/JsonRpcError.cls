/**
 * JSON-RPC error object (`code`, `message`, optional `data`).
 */
public inherited sharing class JsonRpcError {
    /** JSON-RPC error code. */
    public Integer code;
    /** Human-readable JSON-RPC error message. */
    public String message;
    /** Optional additional error payload. */
    public Object data;

    /**
     * Creates an empty error object.
     */
    public JsonRpcError() {
    }

    /**
     * Creates an error object with required fields.
     *
     * @param errorCode JSON-RPC error code.
     * @param errorMessage JSON-RPC error message.
     */
    public JsonRpcError(Integer errorCode, String errorMessage) {
        this.code = errorCode;
        this.message = errorMessage;
    }

    /**
     * Creates an error object with optional `data`.
     *
     * @param errorCode JSON-RPC error code.
     * @param errorMessage JSON-RPC error message.
     * @param errorData Additional error payload.
     */
    public JsonRpcError(Integer errorCode, String errorMessage, Object errorData) {
        this.code = errorCode;
        this.message = errorMessage;
        this.data = errorData;
    }

    /**
     * Creates standard parse error (`-32700`).
     *
     * @return Parse error object.
     */
    public static JsonRpcError parseError() {
        return new JsonRpcError(JsonRpcConstants.PARSE_ERROR_CODE, JsonRpcConstants.PARSE_ERROR_MESSAGE);
    }

    /**
     * Creates standard parse error (`-32700`) with data.
     *
     * @param data Additional error payload.
     * @return Parse error object.
     */
    public static JsonRpcError parseError(Object data) {
        return new JsonRpcError(JsonRpcConstants.PARSE_ERROR_CODE, JsonRpcConstants.PARSE_ERROR_MESSAGE, data);
    }

    /**
     * Creates standard invalid request error (`-32600`).
     *
     * @return Invalid request error object.
     */
    public static JsonRpcError invalidRequest() {
        return new JsonRpcError(JsonRpcConstants.INVALID_REQUEST_CODE, JsonRpcConstants.INVALID_REQUEST_MESSAGE);
    }

    /**
     * Creates standard invalid request error (`-32600`) with data.
     *
     * @param data Additional error payload.
     * @return Invalid request error object.
     */
    public static JsonRpcError invalidRequest(Object data) {
        return new JsonRpcError(JsonRpcConstants.INVALID_REQUEST_CODE, JsonRpcConstants.INVALID_REQUEST_MESSAGE, data);
    }

    /**
     * Creates standard method not found error (`-32601`).
     *
     * @return Method not found error object.
     */
    public static JsonRpcError methodNotFound() {
        return new JsonRpcError(JsonRpcConstants.METHOD_NOT_FOUND_CODE, JsonRpcConstants.METHOD_NOT_FOUND_MESSAGE);
    }

    /**
     * Creates standard method not found error (`-32601`) with data.
     *
     * @param data Additional error payload.
     * @return Method not found error object.
     */
    public static JsonRpcError methodNotFound(Object data) {
        return new JsonRpcError(JsonRpcConstants.METHOD_NOT_FOUND_CODE, JsonRpcConstants.METHOD_NOT_FOUND_MESSAGE, data);
    }

    /**
     * Creates standard invalid params error (`-32602`).
     *
     * @return Invalid params error object.
     */
    public static JsonRpcError invalidParams() {
        return new JsonRpcError(JsonRpcConstants.INVALID_PARAMS_CODE, JsonRpcConstants.INVALID_PARAMS_MESSAGE);
    }

    /**
     * Creates standard invalid params error (`-32602`) with data.
     *
     * @param data Additional error payload.
     * @return Invalid params error object.
     */
    public static JsonRpcError invalidParams(Object data) {
        return new JsonRpcError(JsonRpcConstants.INVALID_PARAMS_CODE, JsonRpcConstants.INVALID_PARAMS_MESSAGE, data);
    }

    /**
     * Creates standard internal error (`-32603`).
     *
     * @return Internal error object.
     */
    public static JsonRpcError internalError() {
        return new JsonRpcError(JsonRpcConstants.INTERNAL_ERROR_CODE, JsonRpcConstants.INTERNAL_ERROR_MESSAGE);
    }

    /**
     * Creates standard internal error (`-32603`) with data.
     *
     * @param data Additional error payload.
     * @return Internal error object.
     */
    public static JsonRpcError internalError(Object data) {
        return new JsonRpcError(JsonRpcConstants.INTERNAL_ERROR_CODE, JsonRpcConstants.INTERNAL_ERROR_MESSAGE, data);
    }

    /**
     * Validates required JSON-RPC error fields.
     */
    public void validate() {
        if (this.code == null) {
            throw new JsonRpcException('JSON-RPC error code is required.');
        }

        if (String.isBlank(this.message)) {
            throw new JsonRpcException('JSON-RPC error message is required.');
        }
    }

    /**
     * Converts this error into an untyped map for JSON serialization.
     *
     * @return Serializable error map.
     */
    public Map<String, Object> toMap() {
        this.validate();

        Map<String, Object> raw = new Map<String, Object>{
            'code' => this.code,
            'message' => this.message
        };

        if (this.data != null) {
            raw.put('data', this.data);
        }

        return raw;
    }
}
