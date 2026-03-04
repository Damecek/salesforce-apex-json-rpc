/**
 * Transport-neutral JSON-RPC 2.0 runtime for single and batch payloads.
 */
public inherited sharing class JsonRpcServiceRuntime {
    /**
     * Wrapper exception used for parse errors.
     */
    public class ParseFailureException extends Exception {
    }

    /**
     * Wrapper exception used for invalid request envelope errors.
     */
    public class InvalidRequestException extends Exception {
    }

    /**
     * Wrapper exception used when no handler is registered for a method.
     */
    public class MethodNotFoundException extends Exception {
    }

    /**
     * Wrapper exception used for params/result conversion and validation errors.
     */
    public class InvalidParamsException extends Exception {
    }

    private class RequestEnvelope {
        public String method;
        public Object params;
        public Object id;
        public Boolean hasId;
    }

    /**
     * Executes a JSON-RPC request payload with default runtime options.
     *
     * @param requestJson Raw JSON-RPC payload (single object or batch array).
     * @param module Handler registry.
     * @return Execution result containing responses to emit.
     */
    public static JsonRpcExecutionResult execute(String requestJson, JsonRpcModule module) {
        return execute(requestJson, module, new JsonRpcServiceRuntimeOptions());
    }

    /**
     * Executes a JSON-RPC request payload with explicit runtime options.
     *
     * @param requestJson Raw JSON-RPC payload (single object or batch array).
     * @param module Handler registry.
     * @param options Runtime options including error mapper behavior.
     * @return Execution result containing responses to emit.
     */
    public static JsonRpcExecutionResult execute(String requestJson, JsonRpcModule module, JsonRpcServiceRuntimeOptions options) {
        if (module == null) {
            throw new JsonRpcException('module is required.');
        }

        JsonRpcServiceRuntimeOptions effectiveOptions = (options == null) ? new JsonRpcServiceRuntimeOptions() : options;
        JsonRpcExceptionMapper mapper = effectiveOptions.exceptionMapper;
        if (mapper == null) {
            mapper = new DefaultJsonRpcExceptionMapper(effectiveOptions.includeInternalErrorDetails);
        }

        JsonRpcExecutionResult result = new JsonRpcExecutionResult();

        if (String.isBlank(requestJson)) {
            result.responses.add(JsonRpcResponse.failure(null, JsonRpcError.parseError('Request JSON is empty.')));
            result.hasResponse = true;
            return result;
        }

        Object raw;
        try {
            raw = JSON.deserializeUntyped(requestJson);
        } catch (Exception ex) {
            result.responses.add(JsonRpcResponse.failure(null, mapper.mapException(new ParseFailureException(ex.getMessage()), null)));
            result.hasResponse = true;
            return result;
        }

        if (raw instanceof Map<String, Object>) {
            handleItem((Map<String, Object>) raw, 0, module, mapper, result);
            result.hasResponse = !result.responses.isEmpty();
            return result;
        }

        if (raw instanceof List<Object>) {
            result.isBatch = true;
            List<Object> items = (List<Object>) raw;

            if (items.isEmpty()) {
                result.responses.add(JsonRpcResponse.failure(null, mapper.mapException(new InvalidRequestException('Batch request must not be empty.'), null)));
                result.hasResponse = true;
                return result;
            }

            Integer index = 0;
            for (Object item : items) {
                if (!(item instanceof Map<String, Object>)) {
                    result.responses.add(JsonRpcResponse.failure(null, mapper.mapException(new InvalidRequestException('Each batch item must be an object.'), null)));
                    index++;
                    continue;
                }

                handleItem((Map<String, Object>) item, index, module, mapper, result);
                index++;
            }

            result.hasResponse = !result.responses.isEmpty();
            return result;
        }

        result.responses.add(JsonRpcResponse.failure(null, mapper.mapException(new InvalidRequestException('Request payload must be an object or an array.'), null)));
        result.hasResponse = true;
        return result;
    }

    private static void handleItem(
        Map<String, Object> requestMap,
        Integer batchIndex,
        JsonRpcModule module,
        JsonRpcExceptionMapper mapper,
        JsonRpcExecutionResult result
    ) {
        RequestEnvelope envelope;
        try {
            envelope = parseEnvelope(requestMap);
        } catch (Exception ex) {
            Object idForError = extractSupportedId(requestMap);
            result.responses.add(JsonRpcResponse.failure(idForError, mapper.mapException(ex, null)));
            return;
        }

        JsonRpcMethodHandler handler = module.resolve(envelope.method);
        if (handler == null) {
            if (envelope.hasId) {
                result.responses.add(JsonRpcResponse.failure(
                    envelope.id,
                    mapper.mapException(new MethodNotFoundException('Method not registered: ' + envelope.method), newContext(envelope, requestMap, batchIndex))
                ));
            }
            return;
        }

        JsonRpcInvocationContext context = newContext(envelope, requestMap, batchIndex);

        try {
            Object typedParams = deserializeParams(envelope.params, handler.paramsType());
            Object rawResult = handler.invoke(typedParams, context);
            Object typedResult = coerceResult(rawResult, handler.resultType());

            if (envelope.hasId) {
                result.responses.add(JsonRpcResponse.success(envelope.id, typedResult));
            }
        } catch (Exception ex) {
            if (envelope.hasId) {
                result.responses.add(JsonRpcResponse.failure(envelope.id, mapper.mapException(ex, context)));
            }
        }
    }

    private static RequestEnvelope parseEnvelope(Map<String, Object> requestMap) {
        if (requestMap == null) {
            throw new InvalidRequestException('JSON-RPC request payload must be an object.');
        }

        if (!(requestMap.get('jsonrpc') instanceof String) || (String) requestMap.get('jsonrpc') != JsonRpcConstants.VERSION) {
            throw new InvalidRequestException('jsonrpc must be exactly "2.0".');
        }

        if (!(requestMap.get('method') instanceof String) || String.isBlank((String) requestMap.get('method'))) {
            throw new InvalidRequestException('method is required and must be a non-empty string.');
        }

        String methodName = (String) requestMap.get('method');
        if (methodName.startsWith(JsonRpcConstants.RESERVED_METHOD_PREFIX)) {
            throw new InvalidRequestException('method names starting with "rpc." are reserved.');
        }

        if (requestMap.containsKey('params')) {
            Object params = requestMap.get('params');
            if (params != null && !(params instanceof List<Object>) && !(params instanceof Map<String, Object>)) {
                throw new InvalidRequestException('params must be either an array or an object.');
            }
        }

        RequestEnvelope envelope = new RequestEnvelope();
        envelope.method = methodName;
        envelope.params = requestMap.get('params');
        envelope.hasId = requestMap.containsKey('id');
        envelope.id = requestMap.get('id');

        if (envelope.hasId && !JsonRpcId.isSupported(envelope.id)) {
            throw new InvalidRequestException('id must be String, Integer, Long, Decimal, or null.');
        }

        return envelope;
    }

    private static JsonRpcInvocationContext newContext(RequestEnvelope envelope, Map<String, Object> requestMap, Integer batchIndex) {
        JsonRpcInvocationContext context = new JsonRpcInvocationContext();
        context.requestId = envelope.id;
        context.methodName = envelope.method;
        context.rawRequest = requestMap;
        context.batchIndex = batchIndex;
        return context;
    }

    private static Object deserializeParams(Object rawParams, Type paramsType) {
        if (paramsType == null) {
            throw new InvalidRequestException('handler paramsType() must return a type.');
        }

        Object typedParams;
        try {
            if (rawParams == null) {
                typedParams = paramsType.newInstance();
            } else {
                typedParams = JSON.deserialize(JSON.serialize(rawParams), paramsType);
            }
        } catch (Exception ex) {
            throw new InvalidParamsException('Unable to deserialize params for declared params type.');
        }

        if (!(typedParams instanceof JsonRpcParamsBase)) {
            throw new InvalidRequestException('Declared params type must extend JsonRpcParamsBase.');
        }

        ((JsonRpcParamsBase) typedParams).validate();
        return typedParams;
    }

    private static Object coerceResult(Object rawResult, Type resultType) {
        if (resultType == null) {
            throw new InvalidRequestException('handler resultType() must return a type.');
        }

        if (rawResult == null) {
            return null;
        }

        Object typedResult;
        try {
            typedResult = JSON.deserialize(JSON.serialize(rawResult), resultType);
        } catch (Exception ex) {
            throw new InvalidParamsException('Unable to serialize handler result into declared result type.');
        }

        if (!(typedResult instanceof JsonRpcResultBase)) {
            throw new InvalidRequestException('Declared result type must extend JsonRpcResultBase.');
        }

        ((JsonRpcResultBase) typedResult).validate();
        return typedResult;
    }

    private static Object extractSupportedId(Map<String, Object> requestMap) {
        if (requestMap == null || !requestMap.containsKey('id')) {
            return null;
        }

        return JsonRpcId.normalizedOrNull(requestMap.get('id'));
    }
}
