# Architecture

The reasoning behind how `jonathan-stack` is structured. Read this before extending the stack.

## The Three-Layer Model

Claude Code gives you three distinct primitives. Used correctly, they don't fight each other.

```
┌─────────────────────────────────────────────────────────────┐
│  LAYER 3: COMMANDS (the WHEN)                               │
│  Slash commands. Orchestration entry points.                │
│  /jonathan-spec, /jonathan-ship, /quickspike                │
│  ──────────────────────────────────────────────────────     │
│  Lives in: ~/.claude/commands/ or plugin /commands/         │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ commands invoke...
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 2: PERSONAS (the WHO)                                │
│  Subagents. Role identities with system prompts.            │
│  product-manager, senior-ios-engineer, security-analyst,    │
│  fintech-compliance-reviewer, ...                           │
│  ──────────────────────────────────────────────────────     │
│  Lives in: ~/.claude/agents/ or plugin /agents/             │
│  Each gets isolated context window + own tool permissions   │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ personas invoke...
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 1: SKILLS (the HOW)                                  │
│  Workflows. Steps, gates, exit criteria.                    │
│  superpowers:test-driven-development,                       │
│  superpowers:writing-plans, tech-snacks:prd-to-ux, ...      │
│  ──────────────────────────────────────────────────────     │
│  Lives in: external plugins (superpowers, tech-snacks)      │
└─────────────────────────────────────────────────────────────┘
```

Information flows down the stack: commands orchestrate personas, personas invoke skills, skills are stateless workflows.

Information does **not** flow back up (a skill cannot invoke a persona; a persona cannot invoke a command). This isn't a Claude Code restriction — it's a discipline that keeps the stack debuggable.

## The Composition Rule

Borrowed verbatim from Addy Osmani's `agent-skills`:

> **The user (or a slash command) is the orchestrator. Personas do not invoke other personas. A persona may invoke skills.**

This rule has one exception:

> The only multi-persona pattern this stack endorses is **parallel fan-out with a synthesizer**, used by `/jonathan-ship`.

Why this rule exists: the moment you let personas call other personas, you create a graph of possible interaction paths that grows combinatorially. At 5 personas you have 20 possible directed pairs. At 10, you have 90. Debugging becomes archaeology.

By forcing all multi-persona orchestration up to the command layer, the orchestration logic lives in *one* readable place per workflow (`/jonathan-spec`, `/jonathan-ship`), instead of spreading across persona files.

### What this looks like in practice

✅ **Allowed**:
- User invokes `/jonathan-ship`
- `/jonathan-ship` dispatches `senior-ios-engineer` + `qa-test-automation-engineer` + `security-analyst` in parallel via Task tool
- `senior-ios-engineer` invokes `superpowers:test-driven-development` skill while doing its work
- Each persona reports back to `/jonathan-ship` which synthesizes

❌ **Not allowed**:
- `senior-ios-engineer` decides mid-work to invoke `security-analyst` for a consultation
- `qa-test-automation-engineer` invokes `senior-frontend-engineer` to fix a test that fails
- `system-architect` invokes `product-manager` to clarify requirements (instead it should surface the ambiguity to the user)

If a persona feels like it needs to invoke another persona, that's a signal: either (a) the orchestration belongs in a slash command, or (b) the gap should be filled by a skill the persona can invoke instead.

## Why Personas + Skills Both Exist

You might ask: why not just use skills? Or just use personas?

### Skills alone (the superpowers approach)
- ✅ Easier to compose — workflows are stateless
- ✅ Clear "this skill triggered because of this description match"
- ❌ Hard to maintain consistent perspective across a long task
- ❌ No way to give different parts of work different tool permissions

### Personas alone (the gstack approach)
- ✅ Strong role identity, easy to reason about
- ✅ Per-persona tool restrictions
- ❌ Easy to drift into "kitchen sink" personas that try to do everything
- ❌ Re-implementing the same workflow across multiple personas creates inconsistency
- ❌ Larger context per invocation (full system prompt loaded each time)

### Both layered (this stack's approach)
- ✅ Personas hold *perspective* and *role-specific context* (HIG knowledge for iOS, ERISA framing for compliance)
- ✅ Skills hold *discipline* and *workflow* (TDD, debugging, planning)
- ✅ Updating a skill once benefits every persona that delegates to it
- ✅ Smaller, focused personas because they don't reimplement workflows
- ⚠️ Requires the discipline to actually delegate rather than inline workflow content

The Delegated Skills section of each engineer persona is what enforces the layering. If you ever find yourself writing TDD instructions inline in a persona, stop — that content belongs in (or already exists in) a skill.

## Trigger Precision

Personas auto-load when their `description` field matches the user's intent. This means description writing is not optional polish — it's load-bearing.

### Good description (specific, includes "Use when", includes negative exclusions)

```yaml
description: Build production iOS applications from technical specifications.
  Specializes in Swift, SwiftUI, UIKit, AVFoundation/AVAudioEngine, AUv3 audio
  units, ARKit, CoreMotion, and Apple platform conventions. Use when the project
  is iOS native. NOT for Android or web frontend work.
```

### Bad description (vague, no triggers)

```yaml
description: Implements iOS code.
```

The bad one will fire only when the user types something like "implement iOS code." The good one will fire on "build the AVAudioEngine pipeline for the new pedal" because the description already mentions AVAudioEngine.

When you add a new persona or modify an existing one, write the description as if you're writing the search index for that persona's invocation. The trigger phrases are the search keys.

## Avoiding Conflict With Companion Plugins

`jonathan-stack` is designed to coexist with `superpowers`, `tech-snacks`, and (optionally) `addyosmani/agent-skills`. Three mechanisms keep the peace:

### 1. Plugin namespacing
When installed via the plugin path, every component is namespaced. `jonathan-stack:product-manager` cannot collide with anything from another plugin, even if the name is identical.

### 2. Domain non-overlap
Each layer in this stack covers domains the companion plugins don't:
- **superpowers** owns: TDD, debugging, planning, brainstorming, code review (skills)
- **tech-snacks** owns: PRD-to-UX-prompt translation, site replication (skills)
- **jonathan-stack** owns: role personas (PM, architect, engineers, QA, security, compliance) and orchestration commands

If you ever feel like adding a TDD skill to jonathan-stack, that's a signal you should be invoking superpowers' instead.

### 3. The Delegated Skills section
Each engineer persona has an explicit table mapping tasks to companion-plugin skills. This is the contract that says "I will not reimplement this; I will invoke the skill." Without it, personas drift into duplicating workflow content over time.

## When This Architecture Breaks Down

This stack assumes you have time to write a PRD before code, time to run parallel review before merge, and time for the personas to do their full structured output. That's appropriate for production work — Human Interest features that real users depend on, Ampz releases going to TestFlight, the youth-vetting app.

It is **not** appropriate for:
- 30-minute curiosity spikes (use `/quickspike`, which deliberately bypasses the structure)
- Throwaway one-line scripts
- Pair-programming or live coding sessions where the conversation IS the spec

If you find yourself fighting the structure on small work, that's correct — the structure is for non-small work. Use the right tool for the size.

## Extending Without Breaking

If you want to add functionality, the decision tree is:

1. **Is this a workflow that any role would follow?** (e.g., "always run linters before commit") → It's a **skill**. Either find an existing one in superpowers or write your own under `~/.claude/skills/<name>/SKILL.md`.

2. **Is this a perspective or specialized role identity?** (e.g., "Android engineer who knows Compose and Jetpack") → It's a **persona**. Add it under `agents/`.

3. **Is this a multi-step orchestration of existing personas?** (e.g., "review for accessibility specifically") → It's a **command**. Add it under `commands/`.

4. **Is this a tool integration?** (e.g., "talk to Salesforce") → It's an **MCP server**, not part of this stack. Configure it separately and grant the appropriate personas access.

If you can't tell which layer a new addition belongs in, that's usually a sign the addition isn't well-scoped yet. Define the use case more precisely first.

## A Note on AI-Generated Code That Wrote Itself

Most of the personas in this stack will, at some point, suggest writing code that *they themselves* don't understand the consequences of. That's the failure mode the multi-layer architecture is designed to catch:

- The `senior-ios-engineer` persona delegates to `superpowers:test-driven-development`, which forces a failing test before any implementation
- `superpowers:verification-before-completion` forces an explicit pass/fail check before any "done" claim
- `/jonathan-ship` runs a parallel security/QA/compliance review before any merge
- `fintech-compliance-reviewer` flags items that need legal review rather than auto-resolving them

The architecture only works if you let those gates do their job. Skipping the verification step because "this change is small" is the most common way the discipline collapses. The same is true for `/jonathan-ship` — running it on small changes feels like ceremony, but it catches the surprises.

If you start finding the gates excessive, the right move is to use `/quickspike` (which deliberately omits them), not to disable them in the production flow.
