// Batch parse with valid requests, notifications, and invalid elements
String rawBatch =
    '[' +
    '{"jsonrpc":"2.0","method":"sum","params":[2,3],"id":1},' +
    '{"jsonrpc":"2.0","method":"notify","params":{"x":1}},' +
    '7' +
    ']';

JsonRpcProtocol.ParseResult parsed = JsonRpcProtocol.parseRequest(rawBatch);

List<JsonRpcResponse> responses = new List<JsonRpcResponse>();
responses.addAll(parsed.itemErrors); // Invalid items in batch.

for (JsonRpcRequest request : parsed.requests) {
    if (request.isNotification()) {
        continue; // Notifications must not produce responses.
    }
    responses.add(JsonRpcResponse.success(request.id, 'ok'));
}

String rawResponse = JsonRpcProtocol.serializeResponses(responses);
System.debug(rawResponse);
