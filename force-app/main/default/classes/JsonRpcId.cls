/**
 * Utilities for JSON-RPC id type checks and normalization.
 */
public inherited sharing class JsonRpcId {
    /**
     * Checks whether a value is a valid JSON-RPC id type.
     *
     * @param value Candidate id value.
     * @return True when value is null, String, Integer, Long, or Decimal.
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
     * Returns the id when supported; otherwise returns null.
     *
     * @param value Candidate id value.
     * @return Supported id value, or null when unsupported.
     */
    public static Object normalizedOrNull(Object value) {
        return isSupported(value) ? value : null;
    }
}
