---
description: Viết spec trước khi code bất cứ thứ gì
---

Follow .cursor/rules/01-spec.md (spec-driven-development).

Gated workflow — KHÔNG advance sang phase tiếp theo khi chưa được confirm:

```
SPECIFY → PLAN → TASKS → IMPLEMENT
   ↓         ↓      ↓        ↓
 Human    Human  Human    Human
reviews  reviews reviews  reviews
```

Phase 1 — SPECIFY:
- List assumptions ngay lập tức
- Hỏi clarifying questions đến khi requirements concrete
- Viết: Problem Statement, Goals, Non-Goals, Constraints, Acceptance Criteria

Phase 2 — PLAN:
- High-level approach
- Components cần thay đổi
- Risks và unknowns

Phase 3 — TASKS:
- Break thành tasks nhỏ có acceptance criteria
- Dependency ordering
- Save vào SPEC.md (hoặc docs/specs/feature-name.md)

CHỜ human approve spec trước khi code.
