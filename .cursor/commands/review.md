---
description: Five-axis code review trước khi merge
---

Follow .cursor/rules/06-review.md (code-review-and-quality).

Review staged changes hoặc recent commits qua 5 axes:

1. **Correctness** — Có match spec không? Edge cases? Tests đủ chưa?
2. **Readability** — Tên biến rõ? Logic thẳng? Tổ chức hợp lý?
3. **Architecture** — Follow existing patterns? Abstraction đúng level?
4. **Security** — Input validated? Secrets safe? Auth checked? → load .cursor/rules/06-security.md
5. **Performance** — N+1 queries? Unbounded ops? → load .cursor/rules/06-perf.md

Phân loại findings:
- 🔴 **Critical** — Block merge, phải fix
- 🟡 **Important** — Nên fix trước merge
- 🟢 **Suggestion** — Nice-to-have

Output: structured review với file:line references và fix recommendations cụ thể.
