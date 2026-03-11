# Usage Examples

This folder contains copy-paste friendly examples for the class-first JSON-RPC API.

Examples in this folder use typed params/result DTOs, handler base classes, and `JsonRpcIdValue`-backed ids.
Dynamic raw params decoding is no longer part of the supported public API.

## Files
- `minimal-module.apex`: One DTO pair, one handler, one module registration, one execution call.
- `batch-mixed.apex`: Batch with success, invalid params, notification, and malformed item.
- `custom-exception-mapper.apex`: Runtime options with custom exception mapper.
- `method-not-found-and-invalid-request.apex`: Standard method-not-found and invalid request behavior.
- `testing-handler.apex`: Unit and integration testing pattern for handlers/runtime.
