# Apex JSON-RPC Framework (Salesforce 2GP)

Feature-full Apex framework for JSON-RPC 2.0 service execution with explicit method registration and typed DTO contracts.

## Scope
- JSON-RPC 2.0 runtime execution for single requests, notifications, and batches.
- Typed params/result pipeline using base DTO classes.
- Built-in error mapping with extension point.
- Transport-neutral API (no HTTP endpoint implementation in this package).

Out of scope: `@RestResource` endpoints, auth, UI, business domain logic.

## Quick Start
```bash
npm run org:fresh
npm run org:deploy
npm run org:test
```

Default Dev Hub alias is `apex-json-rpc-devhub` (override via `DEVHUB_ALIAS`).

## Usage (Apex)
```apex
public class SumParams extends JsonRpcParamsBase {
    public Integer a;
    public Integer b;

    public override void validate() {
        if (a == null || b == null) {
            throw new JsonRpcException('a and b are required.');
        }
    }
}

public class SumResult extends JsonRpcResultBase {
    public Integer sum;
}

public class SumHandler implements JsonRpcMethodHandler {
    public String methodName() { return 'math.sum'; }
    public Type paramsType() { return SumParams.class; }
    public Type resultType() { return SumResult.class; }

    public Object invoke(Object params, JsonRpcInvocationContext context) {
        SumParams typed = (SumParams) params;
        SumResult result = new SumResult();
        result.sum = typed.a + typed.b;
        return result;
    }
}

JsonRpcModule module = new JsonRpcModule().register(new SumHandler());
JsonRpcExecutionResult execResult = JsonRpcServiceRuntime.execute(
    '{"jsonrpc":"2.0","method":"math.sum","params":{"a":1,"b":2},"id":1}',
    module
);

String responseJson = execResult.toJson();
```

## Examples
See the [`examples/`](examples) folder for practical snippets:
- `minimal-module.apex`
- `batch-mixed.apex`
- `custom-exception-mapper.apex`
- `method-not-found-and-invalid-request.apex`
- `testing-handler.apex`

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
- Package version line: `1.0.0`
