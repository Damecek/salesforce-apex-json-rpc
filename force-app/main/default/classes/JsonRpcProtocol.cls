public inherited sharing class JsonRpcProtocol {
    public class ParseResult {
        public Boolean isBatch = false;
        public List<JsonRpcRequest> requests = new List<JsonRpcRequest>();
        public List<JsonRpcResponse> itemErrors = new List<JsonRpcResponse>();
        public JsonRpcResponse protocolError;

        /**
         * Indicates whether a protocol-level parse/validation error occurred.
         *
         * @return True when protocolError is set.
         */
        public Boolean hasProtocolError() {
            return this.protocolError != null;
        }
    }

    /**
     * Parses a JSON-RPC request payload (single object or batch array).
     *
     * @param requestJson Raw JSON-RPC request payload.
     * @return Parse result containing valid requests and/or protocol/item errors.
     */
    public static ParseResult parseRequest(String requestJson) {
        ParseResult result = new ParseResult();

        if (String.isBlank(requestJson)) {
            result.protocolError = JsonRpcResponse.failure(null, JsonRpcError.parseError('Request JSON is empty.'));
            return result;
        }

        Object raw;
        try {
            raw = JSON.deserializeUntyped(requestJson);
        } catch (Exception ex) {
            result.protocolError = JsonRpcResponse.failure(null, JsonRpcError.parseError(ex.getMessage()));
            return result;
        }

        if (raw instanceof Map<String, Object>) {
            Map<String, Object> requestMap = (Map<String, Object>) raw;
            try {
                result.requests.add(JsonRpcRequest.fromMap(requestMap));
            } catch (Exception ex) {
                result.protocolError = JsonRpcResponse.failure(extractId(requestMap), JsonRpcError.invalidRequest(ex.getMessage()));
            }
            return result;
        }

        if (raw instanceof List<Object>) {
            result.isBatch = true;
            List<Object> batchItems = (List<Object>) raw;

            if (batchItems.isEmpty()) {
                result.protocolError = JsonRpcResponse.failure(null, JsonRpcError.invalidRequest('Batch request must not be empty.'));
                return result;
            }

            for (Object batchItem : batchItems) {
                if (!(batchItem instanceof Map<String, Object>)) {
                    result.itemErrors.add(JsonRpcResponse.failure(null, JsonRpcError.invalidRequest('Each batch item must be an object.')));
                    continue;
                }

                Map<String, Object> requestMap = (Map<String, Object>) batchItem;
                try {
                    result.requests.add(JsonRpcRequest.fromMap(requestMap));
                } catch (Exception ex) {
                    result.itemErrors.add(JsonRpcResponse.failure(extractId(requestMap), JsonRpcError.invalidRequest(ex.getMessage())));
                }
            }

            return result;
        }

        result.protocolError = JsonRpcResponse.failure(null, JsonRpcError.invalidRequest('Request payload must be an object or an array.'));
        return result;
    }

    /**
     * Serializes a single JSON-RPC response object.
     *
     * @param response JSON-RPC response.
     * @return Serialized response JSON string.
     */
    public static String serializeResponse(JsonRpcResponse response) {
        if (response == null) {
            throw new JsonRpcException('response is required.');
        }

        return JSON.serialize(response.toMap());
    }

    /**
     * Serializes one or more JSON-RPC responses.
     *
     * @param responses List of response objects.
     * @return Serialized JSON string, or null when no response should be emitted.
     */
    public static String serializeResponses(List<JsonRpcResponse> responses) {
        if (responses == null || responses.isEmpty()) {
            return null;
        }

        if (responses.size() == 1) {
            return serializeResponse(responses[0]);
        }

        List<Object> payload = new List<Object>();
        for (JsonRpcResponse response : responses) {
            payload.add(response.toMap());
        }

        return JSON.serialize(payload);
    }

    private static Object extractId(Map<String, Object> requestMap) {
        if (requestMap == null || !requestMap.containsKey('id')) {
            return null;
        }

        Object rawId = requestMap.get('id');
        return JsonRpcId.normalizedOrNull(rawId);
    }
}
