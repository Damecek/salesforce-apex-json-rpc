public inherited sharing class JsonRpcConstants {
    public static final String VERSION = '2.0';

    public static final Integer PARSE_ERROR_CODE = -32700;
    public static final Integer INVALID_REQUEST_CODE = -32600;
    public static final Integer METHOD_NOT_FOUND_CODE = -32601;
    public static final Integer INVALID_PARAMS_CODE = -32602;
    public static final Integer INTERNAL_ERROR_CODE = -32603;

    public static final String PARSE_ERROR_MESSAGE = 'Parse error';
    public static final String INVALID_REQUEST_MESSAGE = 'Invalid Request';
    public static final String METHOD_NOT_FOUND_MESSAGE = 'Method not found';
    public static final String INVALID_PARAMS_MESSAGE = 'Invalid params';
    public static final String INTERNAL_ERROR_MESSAGE = 'Internal error';

    public static final String RESERVED_METHOD_PREFIX = 'rpc.';
}
