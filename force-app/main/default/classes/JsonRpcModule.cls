/**
 * Registry of JSON-RPC method handlers.
 */
public inherited sharing class JsonRpcModule {
    private Map<String, JsonRpcMethodHandler> handlersByMethod = new Map<String, JsonRpcMethodHandler>();

    /**
     * Registers a handler by method name.
     *
     * @param handler Method handler instance.
     * @return Current module for fluent chaining.
     */
    public JsonRpcModule register(JsonRpcMethodHandler handler) {
        if (handler == null) {
            throw new JsonRpcException('handler is required.');
        }

        String method = handler.methodName();
        if (String.isBlank(method)) {
            throw new JsonRpcException('handler methodName() must return a non-empty string.');
        }

        if (method.startsWith(JsonRpcConstants.RESERVED_METHOD_PREFIX)) {
            throw new JsonRpcException('method names starting with "rpc." are reserved.');
        }

        if (this.handlersByMethod.containsKey(method)) {
            throw new JsonRpcException('Duplicate handler registration for method: ' + method);
        }

        this.handlersByMethod.put(method, handler);
        return this;
    }

    /**
     * Resolves a handler by method name.
     *
     * @param method JSON-RPC method name.
     * @return Registered handler or null when not found.
     */
    public JsonRpcMethodHandler resolve(String method) {
        return this.handlersByMethod.get(method);
    }
}
