# Apex JSON-RPC 2.0 (Salesforce 2GP)

Minimal Apex library implementing **JSON-RPC 2.0 protocol semantics only**.

## Scope
- Request/notification parsing and validation.
- Response/error modeling and serialization.
- Batch parsing behavior, including empty-batch invalid request handling.
- Standard JSON-RPC error codes (`-32700`, `-32600`, `-32601`, `-32602`, `-32603`).

Out of scope: HTTP endpoints, auth, transport adapters, business method handlers.

## Quick Start
```bash
npm run org:fresh
npm run org:deploy
npm run org:test
```

Default Dev Hub alias is `apex-json-rpc-devhub` (override via `DEVHUB_ALIAS`).

## Usage (Apex)
```apex
JsonRpcRequest req = new JsonRpcRequest('sum', 1);
req.params = new List<Object>{1, 2};
req.validate();

String requestJson = JSON.serialize(req.toMap());
JsonRpcProtocol.ParseResult parsed = JsonRpcProtocol.parseRequest(requestJson);

JsonRpcResponse ok = JsonRpcResponse.success(1, 3);
String responseJson = JsonRpcProtocol.serializeResponse(ok);
```

Notification example:
```apex
JsonRpcRequest notification = new JsonRpcRequest('updateStatus');
notification.params = new Map<String, Object>{ 'status' => 'ok' };
System.assert(notification.isNotification());
```

## Scratch-Org-First Policy
Each new task should start with a fresh scratch org by default:
```bash
npm run task:prepare
```

Explicit local override:
```bash
npm run task:prepare:skip-org
```

## 2GP Packaging
Create package in Dev Hub (idempotent):
```bash
npm run package:init
```

Create version:
```bash
npm run release:version
```

Promote/install (requires `PACKAGE_VERSION_ID`):
```bash
npm run release:promote
npm run release:install
```

## Compatibility
- Salesforce API version: `65.0`
- Namespace: empty (no-namespace start)
