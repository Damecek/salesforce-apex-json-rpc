// Notification example
JsonRpcRequest notification = new JsonRpcRequest('status.update');
notification.params = new Map<String, Object>{ 'status' => 'ok' };
notification.validate();
System.assertEquals(true, notification.isNotification());

// Standard error response example
JsonRpcError notFound = JsonRpcError.methodNotFound('Unknown method: foo.bar');
JsonRpcResponse errorResponse = JsonRpcResponse.failure(42, notFound);
String rawError = JsonRpcProtocol.serializeResponse(errorResponse);
System.debug(rawError);
