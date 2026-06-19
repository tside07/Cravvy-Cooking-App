---
description: Build incrementally — spec → slice → test → commit
---

Follow .cursor/rules/03-build.md (incremental-implementation) + .cursor/rules/04-test.md (TDD).

Workflow:
1. Đọc spec và acceptance criteria của task hiện tại
2. Load relevant context (existing code, patterns, types)
3. Viết failing test trước (RED)
4. Implement minimum code để pass test (GREEN)
5. Run full test suite — check regression
6. Run build — verify compilation
7. Commit với message mô tả rõ
8. Mark task done, move to next

Nếu bất kỳ step nào fail → follow .cursor/rules/05-debug.md

Nếu logic phức tạp hoặc production-critical → ALSO load .cursor/rules/99-doubt.md
