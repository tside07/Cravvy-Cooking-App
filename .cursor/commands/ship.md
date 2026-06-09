---
description: Pre-launch checklist, monitoring, rollback plan
---

Follow .cursor/rules/08-ship.md (shipping-and-launch).

Trước khi deploy, chạy qua checklist này theo thứ tự:

**PRE-LAUNCH:**
- [ ] All tests passing (unit, integration, e2e)
- [ ] Build clean, no warnings
- [ ] Security review done (.cursor/rules/06-security.md)
- [ ] Performance baseline recorded
- [ ] Feature flags set correctly
- [ ] Migrations tested on staging
- [ ] Rollback plan documented

**MONITORING:**
- [ ] Error tracking configured
- [ ] Key metrics defined (latency, error rate, throughput)
- [ ] Alerts set for anomalies
- [ ] Logs structured và searchable

**ROLLBACK:**
- [ ] Rollback procedure documented và tested
- [ ] Database migration is reversible (hoặc có plan)
- [ ] Feature flag có thể disable immediately

**STAGED ROLLOUT:**
- [ ] 5% → monitor 15 min → 25% → monitor → 100%
- [ ] Stop criteria được define rõ

Nếu bất kỳ item nào fail → STOP, fix trước khi deploy.
