# AGENTS.md

## Mission
Maintain a clean, protocol-only Apex JSON-RPC 2.0 library for Salesforce 2GP.

## Hard Scope Boundaries
Allowed:
- JSON-RPC 2.0 request/response/error/batch protocol logic.
- Validation, serialization, and protocol-compliance tests.
- Packaging and CI/pipeline scripts.

Not allowed:
- Transport APIs (REST, HTTP handlers), authentication, UI, domain business logic.

## Default Task Workflow
1. Create a fresh scratch org (`npm run org:fresh`).
2. Deploy full source (`npm run org:deploy`).
3. Run tests (`npm run org:test`).
4. Implement the task only after steps 1-3 pass.

Override is explicit: `npm run task:prepare:skip-org`.

## Engineering Rules
- Keep public API minimal and intuitive.
- Follow JSON-RPC 2.0 spec strictly.
- Add/update tests with every behavior change.
- Keep docs concise and executable.
- Use script-first operations for consistency.

## Release Hygiene
- Initialize/check package with `npm run package:init` (Dev Hub: `apex-json-rpc-devhub`).
- Version with `npm run release:version`.
- Promote/install only with explicit `PACKAGE_VERSION_ID`.
