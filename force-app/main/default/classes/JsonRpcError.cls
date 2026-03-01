public inherited sharing class JsonRpcError {
    public Integer code;
    public String message;
    public Object data;

    /**
     * Creates an empty JSON-RPC error instance.
     */
    public JsonRpcError() {
    }

    /**
     * Creates a JSON-RPC error with required fields.
     *
     * @param errorCode JSON-RPC error code.
     * @param errorMessage JSON-RPC error message.
     */
    public JsonRpcError(Integer errorCode, String errorMessage) {
        this.code = errorCode;
        this.message = errorMessage;
    }

    /**
     * Creates a JSON-RPC error with optional error data.
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
     * Creates standard parse error (-32700).
     *
     * @return JSON-RPC parse error.
     */
    public static JsonRpcError parseError() {
        return new JsonRpcError(JsonRpcConstants.PARSE_ERROR_CODE, JsonRpcConstants.PARSE_ERROR_MESSAGE);
    }

    /**
     * Creates standard parse error (-32700) with data payload.
     *
     * @param data Additional error payload.
     * @return JSON-RPC parse error.
     */
    public static JsonRpcError parseError(Object data) {
        return new JsonRpcError(JsonRpcConstants.PARSE_ERROR_CODE, JsonRpcConstants.PARSE_ERROR_MESSAGE, data);
    }

    /**
     * Creates standard invalid request error (-32600).
     *
     * @return JSON-RPC invalid request error.
     */
    public static JsonRpcError invalidRequest() {
        return new JsonRpcError(JsonRpcConstants.INVALID_REQUEST_CODE, JsonRpcConstants.INVALID_REQUEST_MESSAGE);
    }

    /**
     * Creates standard invalid request error (-32600) with data payload.
     *
     * @param data Additional error payload.
     * @return JSON-RPC invalid request error.
     */
    public static JsonRpcError invalidRequest(Object data) {
        return new JsonRpcError(JsonRpcConstants.INVALID_REQUEST_CODE, JsonRpcConstants.INVALID_REQUEST_MESSAGE, data);
    }

    /**
     * Creates standard method not found error (-32601).
     *
     * @return JSON-RPC method not found error.
     */
    public static JsonRpcError methodNotFound() {
        return new JsonRpcError(JsonRpcConstants.METHOD_NOT_FOUND_CODE, JsonRpcConstants.METHOD_NOT_FOUND_MESSAGE);
    }

    /**
     * Creates standard method not found error (-32601) with data payload.
     *
     * @param data Additional error payload.
     * @return JSON-RPC method not found error.
     */
    public static JsonRpcError methodNotFound(Object data) {
        return new JsonRpcError(JsonRpcConstants.METHOD_NOT_FOUND_CODE, JsonRpcConstants.METHOD_NOT_FOUND_MESSAGE, data);
    }

    /**
     * Creates standard invalid params error (-32602).
     *
     * @return JSON-RPC invalid params error.
     */
    public static JsonRpcError invalidParams() {
        return new JsonRpcError(JsonRpcConstants.INVALID_PARAMS_CODE, JsonRpcConstants.INVALID_PARAMS_MESSAGE);
    }

    /**
     * Creates standard invalid params error (-32602) with data payload.
     *
     * @param data Additional error payload.
     * @return JSON-RPC invalid params error.
     */
    public static JsonRpcError invalidParams(Object data) {
        return new JsonRpcError(JsonRpcConstants.INVALID_PARAMS_CODE, JsonRpcConstants.INVALID_PARAMS_MESSAGE, data);
    }

    /**
     * Creates standard internal error (-32603).
     *
     * @return JSON-RPC internal error.
     */
    public static JsonRpcError internalError() {
        return new JsonRpcError(JsonRpcConstants.INTERNAL_ERROR_CODE, JsonRpcConstants.INTERNAL_ERROR_MESSAGE);
    }

    /**
     * Creates standard internal error (-32603) with data payload.
     *
     * @param data Additional error payload.
     * @return JSON-RPC internal error.
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
     * Converts this JSON-RPC error into a serializable map.
     *
     * @return Map representation of the error object.
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

    /**
     * Builds a JSON-RPC error from an untyped map payload.
     *
     * @param raw Untyped error object map.
     * @return Parsed and validated JSON-RPC error.
     */
    public static JsonRpcError fromMap(Map<String, Object> raw) {
        if (raw == null) {
            throw new JsonRpcException('JSON-RPC error payload must be an object.');
        }

        JsonRpcError parsed = new JsonRpcError();
        Object codeRaw = raw.get('code');

        if (codeRaw instanceof Integer) {
            parsed.code = (Integer) codeRaw;
        } else if (codeRaw instanceof Long) {
            parsed.code = Integer.valueOf(String.valueOf(codeRaw));
        } else if (codeRaw instanceof Decimal) {
            parsed.code = ((Decimal) codeRaw).intValue();
        } else {
            throw new JsonRpcException('JSON-RPC error code must be a number.');
        }

        if (!(raw.get('message') instanceof String)) {
            throw new JsonRpcException('JSON-RPC error message must be a string.');
        }

        parsed.message = (String) raw.get('message');
        parsed.data = raw.get('data');
        parsed.validate();
        return parsed;
    }
}
