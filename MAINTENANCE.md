# Maintenance Guide

Operational guide for keeping `jonathan-stack` healthy, current, and conflict-free.

## Routine

### Weekly (5 min)
- Glance at the conversation history. Are any personas not getting auto-triggered when you'd expect? If so, either the description isn't precise enough or another skill/persona is winning the trigger competition. Note it for the quarterly review.

### Monthly (15 min)
- `cd` into the cloned `superpowers` repo (or wherever you have it) and `git pull`. Look at the changelog. If new skills landed, update the "Delegated Skills" tables in your engineer personas to reference them.
- Same for `tech-snacks` and any other plugins you have installed.

### Quarterly (60 min)
- Run the [Quarterly Review Checklist](#quarterly-review-checklist) below.
- Decide whether to add, remove, or refactor any persona.
- Sanity-check that the `/jonathan-spec` and `/jonathan-ship` flows still match how you actually work. If you've drifted, edit the commands.

---

## Adding a New Persona

Six is the soft ceiling I gave you in the planning conversation. You're at 10 now (8 lifecycle + 1 specialty + 1 compliance). Be ruthless about adding more — every additional persona dilutes auto-trigger precision and adds maintenance load.

### Hard rules before adding a new persona

1. **You will use it weekly.** If it's "I might use this someday," skip it.
2. **It doesn't overlap an existing persona.** If 80% of its system prompt would mirror `senior-backend-engineer`, just add a context note to that persona instead.
3. **It has a clear distinct perspective.** "Engineer who is also good at design" is not a perspective. "Compliance reviewer with ERISA framework lens" is.
4. **It has at least one concrete trigger phrase the existing personas don't match.** Document this in the description field.

### Procedure

1. Copy `senior-backend-engineer.md` (or the closest existing persona) as a template.
2. Edit the YAML frontmatter — `name` and `description`. The description is the trigger text Claude reads to decide when to auto-load. Make it specific and include "Use when..." trigger phrases.
3. Replace the body with the new persona's system prompt.
4. Update the Delegated Skills section. Don't reimplement skills inline.
5. Add a Composition section verbatim from another persona ("This persona may invoke skills. This persona does NOT invoke other personas.")
6. Add the persona to the table in `README.md`.
7. If `/jonathan-ship` should fan it out conditionally, update that command file too.
8. If using the plugin path: commit, push, run `/plugin update jonathan-stack` in Claude Code.
9. If using direct-copy: re-run `scripts/install.sh`.

---

## Adding a New Slash Command

Slash commands are orchestration, not roles. Add one when:
- You find yourself manually dispatching the same set of subagents repeatedly
- A specific kind of work (e.g., "review a PR I'm reviewing for someone else") has a different shape than the existing commands cover

### Procedure

1. Copy `jonathan-ship.md` as a template (it's the most fan-out-shaped).
2. Edit the YAML frontmatter — `description` is what shows in `/help`.
3. Write the orchestration logic. Keep these rules:
   - One question at a time during pre-flight
   - User gates between phases
   - Parallel fan-out is the only multi-persona pattern
   - Don't have personas invoke other personas
   - End with a synthesizer or a clear hand-off
4. Add to `README.md` slash commands table.
5. Update / re-install.

---

## Detecting Conflicts

Conflicts come from three places:

### 1. Trigger overlap (auto-load fights)

Symptom: You write a request that should fire persona A, but persona B fires instead, or both fire and the response is muddy.

Diagnosis: Look at the `description` fields of A and B. If they share trigger keywords, that's the conflict.

Fix: Tighten one description with negative exclusions. Example:
```yaml
description: Implement web frontend (React/Vue/Angular). NOT for iOS native apps - use senior-ios-engineer for that.
```

### 2. Slash command name collisions

Symptom: `/help` shows `/foo` from two different plugins, or your command isn't being recognized.

Diagnosis: Plugin-namespaced commands (`jonathan-stack:foo`) can't collide with each other. But user-scope commands installed via direct-copy can overlap with plugin-namespaced ones from a different plugin.

Fix: Prefix your custom commands with `jonathan-` so they're distinct. The three current ones already do this.

### 3. Skill content overlap

Symptom: Your `senior-backend-engineer` reimplements TDD instructions inline AND superpowers' `test-driven-development` skill activates. Claude tries to follow both, gets contradictory guidance, picks one arbitrarily.

Diagnosis: Open the persona file. Check whether the Delegated Skills section is correctly forwarding to the superpowers skill. Check whether the persona body is duplicating that skill's content.

Fix: Strip the duplicated content. The Delegated Skills table should be the *only* mention of TDD, debugging, planning, etc., in the persona file.

---

## Updating From Upstream

When superpowers / tech-snacks / agent-skills ship new skills:

1. Read the new skill's `SKILL.md` to understand what it does.
2. Determine which of your personas should now delegate to it.
3. Add a row to the Delegated Skills table in those persona files.
4. Don't auto-add to every persona — only the ones where the trigger genuinely fits. Adding it everywhere dilutes signal.

When superpowers / tech-snacks deprecate a skill:

1. Remove rows from your Delegated Skills tables that reference the deprecated skill.
2. If a persona depended heavily on the deprecated skill, you may need to add inline guidance to fill the gap, or wait for the upstream replacement.

---

## Quarterly Review Checklist

Run every 3 months. Block 60 minutes for it.

### Personas
- [ ] Is each persona getting invoked at least monthly? If not, it's a candidate for removal.
- [ ] Does any persona need a description tweak based on observed mis-fires?
- [ ] Is the Delegated Skills table on each engineer persona current with upstream skill releases?
- [ ] Are there gaps where I keep manually inlining instructions that should be a new persona or skill?

### Commands
- [ ] Do `/jonathan-spec` and `/jonathan-ship` still match how I actually work?
- [ ] Has `/quickspike` been useful, or am I just running the full flow anyway?
- [ ] Is the regulated-context detection in `/jonathan-ship` catching the cases that matter?

### Companion plugins
- [ ] Is superpowers up to date? `git pull` if cloned, `/plugin update` if installed as plugin.
- [ ] Is tech-snacks up to date?
- [ ] Are there new community skill packs worth evaluating? (Check `awesome-claude-code` repo or similar.)

### Personal context
- [ ] Has my work shifted in ways the personas don't reflect anymore? (e.g., if you stop doing iOS work for 6 months, `senior-ios-engineer` becomes dead weight; if you start doing Android, you need a new persona.)
- [ ] Any compliance frameworks I should be tracking that aren't yet in `fintech-compliance-reviewer`?

### Hygiene
- [ ] Are there backup files in `~/.claude/backups/` more than 6 months old that can be deleted?
- [ ] Are there agents in `~/.claude/agents/` that aren't in the `jonathan-stack` repo? (Possible drift; reconcile.)

---

## Emergency Recovery

If everything breaks:

1. The install script always backs up before overwriting. Look in `~/.claude/backups/<latest-timestamp>/`.
2. Plugin path: `/plugin uninstall jonathan-stack@jonathan-stack` removes everything cleanly.
3. Direct-copy path: the uninstall commands in `INSTALL.md` will remove all this stack's files, leaving any other stuff in `~/.claude/` alone.
4. Worst case, `mv ~/.claude ~/.claude.broken && mkdir ~/.claude` resets you to a fresh state. You'll lose other plugins too — only do this if you're prepared to reinstall everything.

---

## When to Stop

This stack is supposed to make work easier, not become its own job. If you're spending more than 30 minutes per week maintaining it, you've over-engineered something. Cut a persona, simplify a command, defer to superpowers more.

The discipline is: every persona must earn its keep weekly, every command must reflect actual workflow, every Delegated Skill must point to a skill that actually exists. Anything that fails those tests gets removed at quarterly review.
