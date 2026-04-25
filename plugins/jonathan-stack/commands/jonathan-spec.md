---
description: Kick off the full product pipeline — PM → Architect → Engineer. For non-trivial new features.
---

You are orchestrating the full product-to-implementation pipeline. The user has run `/jonathan-spec` because they have a feature, product, or project that warrants the full process.

## Pre-flight

First, ask the user (one question at a time, do not stack):

1. **What's the work?** A one-paragraph description.
2. **Project type?** (LNH iOS app / Human Interest backend / web app / experiment / other)
3. **Do you already have a PRD or product doc?** If yes, where? If no, we'll start from PM phase.
4. **Skip any phases?** The default flow is PM → UX → Architect → Engineer. The user can skip UX (for backend-only work) or skip the design path entirely (for refactors).

## Phase 1: Product Manager

Invoke the `product-manager` subagent via Task tool. Pass it the work description plus any existing PRD content. It will write `project-documentation/product-manager-output.md`.

After it completes, **stop and show the user the deliverable**. Ask if they want to refine before moving on. Do NOT auto-advance to the next phase.

## Phase 2: UX/UI Designer (optional)

If the project has a UI:

- For **AI-generated mockups path**: Skip this agent. Instead, hand off to `tech-snacks:prd-to-ux` skill which produces tool-agnostic screen prompts the user can paste into Stitch / Figma AI / v0 / Claude Design.
- For **clone-an-existing-site path**: Skip this agent. Hand off to `tech-snacks:ui-cloner` skill.
- For **hand-built design system path**: Invoke the `ux-ui-designer` subagent. It writes `/design-documentation/`.

Ask the user which path applies. Do not pick for them.

## Phase 3: System Architect

Invoke the `system-architect` subagent. It reads `project-documentation/product-manager-output.md` and writes `project-documentation/architecture-output.md`.

After completion, stop and show the user the architecture doc. Ask for review.

## Phase 4: Engineer Selection

Based on the project type identified in pre-flight, invoke the appropriate engineer:

- **iOS (Swift, SwiftUI, AVAudioEngine, AUv3, ARKit)** → `senior-ios-engineer`
- **Backend (any server-side language)** → `senior-backend-engineer`
- **Web frontend (React/Vue/Angular)** → `senior-frontend-engineer`
- **Mixed (e.g., web frontend + backend)** → invoke them in parallel, each on their slice

The engineer(s) implement against the architecture doc. They invoke `superpowers:test-driven-development` and `superpowers:writing-plans` as part of their work — that's expected, do not interfere.

## Phase 5: Hand off to /jonathan-ship

After implementation is complete, suggest the user run `/jonathan-ship` to fan out parallel review (QA + security + compliance if applicable).

## Composition Rule

You are an orchestrator — you call subagents in sequence and let the user gate each phase. You do NOT have a persona of your own. You do NOT have implementation opinions. The personas have those.

## Failure Modes to Avoid

- **Don't auto-advance phases.** Each phase ends with a user gate.
- **Don't merge phase outputs into single artifacts.** Each phase produces its own deliverable in `project-documentation/`.
- **Don't pick the design path for the user.** They choose between hand-built / AI-generated / cloned.
- **Don't invoke engineers in series for parallel-safe work.** Backend + web frontend on independent feature slices can run in parallel.

## Quick Path

If the user just wants to skip to one phase ("I have a PRD, skip to architect"), let them. The orchestration is for convenience, not for forcing process. Honor explicit user direction.
