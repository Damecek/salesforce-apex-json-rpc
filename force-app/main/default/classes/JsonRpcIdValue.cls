/**
 * Wrapper value object for JSON-RPC ids.
 */
public inherited sharing class JsonRpcIdValue {
    private Object rawValue;

    private JsonRpcIdValue(Object value) {
        this.rawValue = value;
    }

    /**
     * Creates a validated wrapper from a raw id value.
     *
     * @param raw Raw candidate id value.
     * @return Wrapped id value.
     */
    public static JsonRpcIdValue fromRaw(Object raw) {
        JsonRpcIdValue parsed = tryFromRaw(raw);
        if (parsed == null) {
            throw new JsonRpcException('id must be String, Integer, Long, Decimal, or null.');
        }
        return parsed;
    }

    /**
     * Creates a wrapper when the raw value is supported; otherwise returns null.
     *
     * @param raw Raw candidate id value.
     * @return Wrapped id value or null when unsupported.
     */
    public static JsonRpcIdValue tryFromRaw(Object raw) {
        if (!isSupportedRaw(raw)) {
            return null;
        }
        return new JsonRpcIdValue(raw);
    }

    /**
     * Creates a wrapper for the explicit JSON null id.
     *
     * @return Null id wrapper.
     */
    public static JsonRpcIdValue nullId() {
        return new JsonRpcIdValue(null);
    }

    /**
     * Returns the raw scalar value for JSON serialization.
     *
     * @return Wrapped raw id value.
     */
    public Object toRaw() {
        return this.rawValue;
    }

    /**
     * Returns true when the id value is explicit null.
     *
     * @return True when null.
     */
    public Boolean isNull() {
        return this.rawValue == null;
    }

    /**
     * Returns true when the wrapped value is a String.
     *
     * @return True when String.
     */
    public Boolean isString() {
        return this.rawValue instanceof String;
    }

    /**
     * Returns true when the wrapped value is an Integer.
     *
     * @return True when Integer.
     */
    public Boolean isInteger() {
        return this.rawValue instanceof Integer;
    }

    /**
     * Returns true when the wrapped value is a Long.
     *
     * @return True when Long.
     */
    public Boolean isLong() {
        return this.rawValue instanceof Long;
    }

    /**
     * Returns true when the wrapped value is a Decimal.
     *
     * @return True when Decimal.
     */
    public Boolean isDecimal() {
        return this.rawValue instanceof Decimal;
    }

    /**
     * Returns the wrapped String value.
     *
     * @return Wrapped String.
     */
    public String asString() {
        if (!isString()) {
            throw new JsonRpcException(wrongTypeMessage('String'));
        }
        return (String) this.rawValue;
    }

    /**
     * Returns the wrapped Integer value.
     *
     * @return Wrapped Integer.
     */
    public Integer asInteger() {
        if (!isInteger()) {
            throw new JsonRpcException(wrongTypeMessage('Integer'));
        }
        return (Integer) this.rawValue;
    }

    /**
     * Returns the wrapped Long value.
     *
     * @return Wrapped Long.
     */
    public Long asLong() {
        if (!isLong()) {
            throw new JsonRpcException(wrongTypeMessage('Long'));
        }
        return (Long) this.rawValue;
    }

    /**
     * Returns the wrapped Decimal value.
     *
     * @return Wrapped Decimal.
     */
    public Decimal asDecimal() {
        if (!isDecimal()) {
            throw new JsonRpcException(wrongTypeMessage('Decimal'));
        }
        return (Decimal) this.rawValue;
    }

    private static Boolean isSupportedRaw(Object raw) {
        return raw == null ||
            raw instanceof String ||
            raw instanceof Integer ||
            raw instanceof Long ||
            raw instanceof Decimal;
    }

    private static String wrongTypeMessage(String expectedType) {
        return 'JSON-RPC id is not a ' + expectedType + '.';
    }
}
