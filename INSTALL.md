# Installation

Two paths. Pick one based on whether you want plugin-managed updates or direct file copy.

## Path 1 — Plugin Install (recommended for long-term use)

This is cleaner because it gives you `/plugin update` later, namespaces your skills as `jonathan-stack:product-manager` so they can't collide with anything, and lets you eventually share a sanitized version with your Human Interest team without fuss.

### One-time setup

1. **Push this directory to a private GitHub repo.** Name it `jonathan-stack`.
   ```bash
   cd jonathan-stack/
   git init
   git add .
   git commit -m "Initial jonathan-stack"
   gh repo create jonathan-stack --private --source=. --push
   ```

2. **In Claude Code, add the marketplace and install** (run these as **separate** submissions, one at a time — submitting both at once will break the parser, as you've already seen):
   ```
   /plugin marketplace add jonathancalpin/jonathan-stack
   ```
   Wait for that to complete, then:
   ```
   /plugin install jonathan-stack@jonathan-stack
   ```

3. **Choose "Install for you (user scope)"** when prompted. That puts it under `~/.claude/plugins/` and makes it available in every project.

4. **Quit and restart Claude Code.** The plugin's agents and commands won't activate until a fresh session.

### Required companion plugins

Make sure you have these installed first (or install them now in the same session):

```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```
(Submit each line separately, restart after.)

```
/plugin marketplace add ragnar-pwninskjold/tech-snacks
/plugin install tech-snacks@tech-snacks
```

### Verify install

In a fresh Claude Code session:

```
/help
```

You should see `/jonathan-spec`, `/jonathan-ship`, and `/quickspike` in the slash command list.

To test a persona:
```
"Use the product-manager subagent to draft a one-paragraph PRD for a hello-world feature."
```

If Claude dispatches to the `product-manager` subagent and produces something resembling the output format, you're installed.

---

## Path 2 — Direct Copy (quick start, no GitHub repo needed)

This skips the plugin system and copies files directly into `~/.claude/`. Faster to start, but you lose plugin namespacing and `/plugin update`.

### Run the install script

From the root of this directory:

```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

The script will:
1. Back up any existing `~/.claude/agents/<name>.md` and `~/.claude/commands/<name>.md` files that would be overwritten (with a timestamp)
2. Copy all 10 persona files to `~/.claude/agents/`
3. Copy all 3 slash command files to `~/.claude/commands/`
4. Print a verification summary

### Required companion plugins

Even with the direct-copy path, you still need superpowers installed (the personas reference superpowers skills in their Delegated Skills sections). Install superpowers as a plugin via Path 1, or clone its repo into `~/.claude/skills/`. See https://github.com/obra/superpowers for direct-clone instructions.

### Verify install

```bash
ls -la ~/.claude/agents/
ls -la ~/.claude/commands/
```

You should see the 10 agent files and 3 command files. Restart Claude Code, then:

```
/help
```

---

## Conflict Resolution

If you already have agents or commands with the same names installed (e.g., from gstack, agent-skills, compound-engineering), the plugin install path namespaces everything as `jonathan-stack:product-manager`, which avoids conflict.

The direct-copy path will conflict on identical filenames. The install script backs up the old files with timestamps before overwriting, so nothing is lost — you can review and restore.

If there's a conflict you actually want to resolve (e.g., addy's `code-reviewer` persona conflicts with this stack's reviewer logic), the precedence in Claude Code is:

```
enterprise > personal > project (with plugin namespacing escaping all of these)
```

Plugin-namespaced agents (e.g., `jonathan-stack:product-manager`) are always callable and never collide. So if you keep both, prefer the plugin path.

---

## Uninstall

**Plugin path:**
```
/plugin uninstall jonathan-stack@jonathan-stack
```

**Direct-copy path:**
```bash
rm ~/.claude/agents/{product-manager,ux-ui-designer,system-architect,senior-backend-engineer,senior-frontend-engineer,senior-ios-engineer,qa-test-automation-engineer,devops-deployment-engineer,security-analyst,fintech-compliance-reviewer}.md
rm ~/.claude/commands/{jonathan-spec,jonathan-ship,quickspike}.md
```

Backups from the install script live in `~/.claude/backups/<timestamp>/` if you need to restore.
