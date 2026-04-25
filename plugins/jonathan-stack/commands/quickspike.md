---
description: Bypass the full PRD pipeline for quick experiments and spikes. Goes straight from idea to brainstorm to implementation. For work under ~4 hours.
---

You are handling a quick spike — short experimental work where the full PRD → architect → engineer pipeline would be overkill.

## When This Is Right

Use `/quickspike` when:
- The work is timeboxed at a few hours
- The output is a prototype, not a production feature
- The goal is "does this even work" or "what does this feel like"
- The user explicitly says "quick experiment" or "spike" or "throwaway"

## When This Is Wrong

Reroute to `/jonathan-spec` when:
- The work will ship to production
- Multiple people will rely on the output
- The change touches regulated data (Human Interest, payments, minor users) — those always go through full review regardless of size
- The user asks for documentation or specs

If in doubt, ask: "This sounds bigger than a spike — should I run `/jonathan-spec` instead?"

## Process

1. **Brief brainstorm** — invoke `superpowers:brainstorming` skill (if installed) or do a 1-question scope check inline. Goal: get to "I'm going to try X to see if Y" in under 60 seconds of conversation.

2. **Skip PM, UX, Architect phases entirely.**

3. **Implement directly.** Use the appropriate engineer persona (iOS / web / backend) for code style and discipline, but don't do the full TDD ceremony unless the user asks. For spikes, invoke `superpowers:writing-plans` only if the work is genuinely multi-step; for a single experiment, just write the code.

4. **End with a decision artifact.** A 3-sentence note — what did we learn, what should we do next, is this worth promoting to a real PRD?

## What to Skip

- `project-documentation/product-manager-output.md` — skip
- `architecture-output.md` — skip
- `/design-documentation/` — skip
- Comprehensive test coverage — skip (smoke tests fine)
- Security review — skip UNLESS the spike touches secrets, auth, or regulated data
- `/jonathan-ship` afterward — skip

## What Not to Skip Even In a Spike

- Don't commit secrets or API keys, even temporarily
- Don't paste production data into a spike
- Don't deploy a spike to a production environment

## Output

A working (or notably-broken-and-instructive) prototype, plus a 3-sentence learning note. That's it.

If the spike succeeds and the user wants to promote it to a real feature, suggest they run `/jonathan-spec` to backfill the proper documentation pipeline. Don't try to retrofit the spike — start the real work fresh.
