/**
 * JSON-RPC 2.0 protocol constants used by the framework runtime.
 */
public inherited sharing class JsonRpcConstants {
    /** JSON-RPC protocol version. */
    public static final String VERSION = '2.0';

    /** Standard parse error code (`-32700`). */
    public static final Integer PARSE_ERROR_CODE = -32700;
    /** Standard invalid request error code (`-32600`). */
    public static final Integer INVALID_REQUEST_CODE = -32600;
    /** Standard method not found error code (`-32601`). */
    public static final Integer METHOD_NOT_FOUND_CODE = -32601;
    /** Standard invalid params error code (`-32602`). */
    public static final Integer INVALID_PARAMS_CODE = -32602;
    /** Standard internal error code (`-32603`). */
    public static final Integer INTERNAL_ERROR_CODE = -32603;

    /** Standard parse error message. */
    public static final String PARSE_ERROR_MESSAGE = 'Parse error';
    /** Standard invalid request message. */
    public static final String INVALID_REQUEST_MESSAGE = 'Invalid Request';
    /** Standard method not found message. */
    public static final String METHOD_NOT_FOUND_MESSAGE = 'Method not found';
    /** Standard invalid params message. */
    public static final String INVALID_PARAMS_MESSAGE = 'Invalid params';
    /** Standard internal error message. */
    public static final String INTERNAL_ERROR_MESSAGE = 'Internal error';

    /** Reserved JSON-RPC method prefix. */
    public static final String RESERVED_METHOD_PREFIX = 'rpc.';
}
