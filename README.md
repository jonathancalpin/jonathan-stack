# jonathan-stack

> Personal Claude Code environment: role-based personas + orchestration commands, designed to compose with `superpowers` and `tech-snacks`.

## What This Is

A Claude Code plugin that gives you a personified engineering team — Product Manager, UX Designer, System Architect, three engineer specialists (Backend / Frontend Web / iOS), QA, DevOps, Security Analyst, and a Fintech Compliance Reviewer — plus three orchestration slash commands.

This stack is **persona-first** but **delegates execution discipline to skills**. The personas tell each agent *what perspective to bring*; superpowers' skills tell them *what discipline to follow when actually doing the work*. They compose; they don't fight.

## Architecture

```
Layer 1: Skills (the HOW)        ← lives in superpowers, tech-snacks, etc.
                                    Workflows: TDD, debugging, planning, brainstorming, etc.

Layer 2: Personas (the WHO)      ← lives HERE in jonathan-stack/agents/
                                    Roles: PM, Architect, iOS Engineer, Security, etc.

Layer 3: Commands (the WHEN)     ← lives HERE in jonathan-stack/commands/
                                    Orchestration: /jonathan-spec, /jonathan-ship, /quickspike
```

**Composition rule** (borrowed from Addy Osmani's `agent-skills`):
> The user (or a slash command) is the orchestrator. Personas do not invoke other personas. A persona may invoke skills.

The only multi-persona pattern this stack endorses is **parallel fan-out with a synthesizer**, used by `/jonathan-ship`.

## Companion Plugins

This stack assumes you also have:

- **`superpowers`** (`obra/superpowers-marketplace`) — provides the workflow skills (TDD, planning, debugging, brainstorming, code review). Required for the "Delegated Skills" sections of each persona to work.
- **`tech-snacks`** (`ragnar-pwninskjold/tech-snacks`) — provides `prd-to-ux` and `ui-cloner` skills. Used as alternative paths in the design phase.

Install those first if you haven't already. See [INSTALL.md](INSTALL.md).

## Personas (10)

### Lifecycle (Phase 1–5)
| Persona | Role | Output |
|---|---|---|
| `product-manager` | PRD authoring, user stories, acceptance criteria | `project-documentation/product-manager-output.md` |
| `ux-ui-designer` | Hand-built design system + screen specs | `/design-documentation/` tree |
| `system-architect` | Tech stack decisions, API contracts, data models | `project-documentation/architecture-output.md` |
| `senior-backend-engineer` | Server-side implementation (any language) | Production code + migrations |
| `senior-frontend-engineer` | Web UI implementation (React/Vue/Angular) | Production code |
| `senior-ios-engineer` | iOS implementation (Swift, SwiftUI, AVAudioEngine, AUv3, ARKit) | Production code |
| `qa-test-automation-engineer` | Test strategy + coverage planning | Test plans + test code |
| `devops-deployment-engineer` | Local Docker / production IaC | Dockerfiles, Terraform, CI/CD |
| `security-analyst` | Vulnerability assessment, threat modeling | Security findings reports |

### Specialized (regulated industries)
| Persona | Role | Output |
|---|---|---|
| `fintech-compliance-reviewer` | ERISA / SOC 2 / COPPA / FCRA compliance gap analysis | Compliance findings reports |

## Slash Commands (3)

| Command | Use When |
|---|---|
| `/jonathan-spec` | Starting a non-trivial feature. Walks PM → UX → Architect → Engineer. |
| `/jonathan-ship` | After implementation, before merge. Parallel fan-out: engineer review + QA + security + (compliance if regulated). |
| `/quickspike` | Short experiments. Skips PRD/UX/Architect. For work under ~4 hours. |

## Installation

See [INSTALL.md](INSTALL.md). Two paths:

1. **Plugin install** (recommended) — push this repo to GitHub, register the marketplace.
2. **Direct copy** (quick start) — run `scripts/install.sh` to copy files into `~/.claude/`.

## Maintenance

See [MAINTENANCE.md](MAINTENANCE.md). Covers when to add a persona, how to detect conflicts, quarterly review checklist, and how to update from upstream when superpowers / tech-snacks ship new skills.

## Architecture Deep Dive

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the reasoning behind the layer separation, why personas don't invoke personas, and how to extend the stack without breaking it.

## Bootstrap Prompt for a New Claude Code Project

See [docs/STARTER-PROMPT.md](docs/STARTER-PROMPT.md). Paste this into a fresh Claude Code session in this directory and it will install, verify, and run a smoke test.

## License

MIT — your personal stack, do what you want with it. Sanitize before sharing publicly.
