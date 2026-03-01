public inherited sharing class JsonRpcId {
    /**
     * Returns true when the supplied value is a JSON-RPC 2.0 supported id type.
     *
     * @param value Candidate id value.
     * @return True when value is String, Integer, Long, Decimal, or null.
     */
    public static Boolean isSupported(Object value) {
        if (value == null) {
            return true;
        }

        return value instanceof String ||
            value instanceof Integer ||
            value instanceof Long ||
            value instanceof Decimal;
    }

    /**
     * Returns the value when it is a supported id type, otherwise returns null.
     *
     * @param value Candidate id value.
     * @return Normalized id value or null for unsupported types.
     */
    public static Object normalizedOrNull(Object value) {
        return isSupported(value) ? value : null;
    }
}
