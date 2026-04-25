# Starter Prompt for a New Claude Code Project

Use this prompt when you've cloned/extracted `jonathan-stack` into a directory and want Claude Code to handle the install and verification for you.

## How to use

1. Open a terminal, `cd` into the `jonathan-stack/` directory.
2. Run `claude` to start a Claude Code session in that directory.
3. Paste the prompt below as your first message.
4. Claude Code will read the repo, propose an install plan, and execute it after your approval.

---

## Paste this:

```
You are operating inside the jonathan-stack repository — my personal Claude Code
environment for managing role-based personas, slash commands, and workflow
discipline across all my projects (Human Interest engineering management work,
LNH iOS apps like Ampz/GolfStarz/TossAR, and side experiments).

Your job in this session is to install and verify this stack into my global
Claude Code environment, then run a smoke test.

## Step 1: Read the repo

Read these files in order so you understand what you're installing:

1. README.md — overview of the stack and its philosophy
2. docs/ARCHITECTURE.md — the layer model and composition rules (CRITICAL)
3. INSTALL.md — both install paths (plugin and direct-copy)
4. MAINTENANCE.md — how I'll maintain this over time

After reading, give me a 5-bullet summary of what you're about to install so I
can confirm we're aligned. Wait for my approval before proceeding.

## Step 2: Verify prerequisites

Check whether the following companion plugins are installed (look in
~/.claude/plugins/ and run `/plugin marketplace list` style introspection if
available):

- obra/superpowers (REQUIRED — personas delegate workflow to its skills)
- ragnar-pwninskjold/tech-snacks (RECOMMENDED — provides prd-to-ux and ui-cloner
  as alternatives to ux-ui-designer for design-tool paths)

If superpowers is NOT installed, STOP and tell me. Don't proceed with this
install until superpowers is present, because half the personas reference its
skills in their Delegated Skills sections and will be partially broken without
it. Give me the exact commands to install superpowers first.

If tech-snacks is NOT installed, just note it and continue — the stack will
work without it, the user just won't have the alternative design paths.

## Step 3: Choose install path

Ask me whether I want:

A) Plugin path — push this repo to GitHub as a private repo, register marketplace,
   install via /plugin commands. Cleanest for long-term, gives me /plugin update.

B) Direct-copy path — run scripts/install.sh to copy files into ~/.claude/.
   Faster start, no GitHub repo needed, but no plugin namespacing or auto-update.

Wait for my choice.

## Step 4: Execute the chosen path

For Path A: walk me through `gh repo create`, `git push`, then the two
sequential /plugin commands. Remind me they have to be submitted as separate
inputs (not pasted together) because that's the bug I hit before.

For Path B: review scripts/install.sh with me first so I see what it will do.
Then run it. Show me the output, including any backups it made of conflicting
existing files.

## Step 5: Verify

After install, confirm:

1. `ls ~/.claude/plugins/jonathan-stack/` (Path A) or `ls ~/.claude/agents/`
   (Path B) shows the expected files.
2. Restart Claude Code (you'll instruct me to do this manually since you can't
   restart yourself).
3. After my restart, I'll confirm `/jonathan-spec`, `/jonathan-ship`, and
   `/quickspike` appear in `/help`.

## Step 6: Smoke test

Once verified, run this smoke test:

   "Use the product-manager subagent to draft a one-paragraph PRD for a
    feature where users can mark a guitar pedal preset as a favorite."

If the product-manager subagent dispatches and produces something resembling
the structured output format from its system prompt, the install works.

Then run:

   "Use the senior-ios-engineer subagent to outline (don't implement, just
    outline) how it would approach building a SwiftUI favorites list view
    for the same feature."

If the senior-ios-engineer dispatches and outlines using SwiftUI/UIKit/HIG
language and references the Delegated Skills (TDD, planning), the persona is
loaded correctly.

## Step 7: Hand off

After both smoke tests pass, give me a one-paragraph summary of what's
installed, what's still pending (e.g., "tech-snacks is recommended but not
yet installed"), and what to do next ("read MAINTENANCE.md when you have
15 minutes; schedule a quarterly review reminder for [date]").

## Constraints

- Do NOT proceed past Step 1 without my explicit approval of the summary.
- Do NOT modify files in this repo unless I ask. The repo is the source of
  truth for what gets installed; if it needs changes, I'll edit and re-run.
- Do NOT install superpowers or tech-snacks for me. Just check whether they're
  present and tell me what to do if they're not.
- Do NOT auto-restart Claude Code or assume restart happened. Pause for my
  confirmation between steps that require restart.
- If anything fails, STOP and tell me. Don't try to recover by inventing fixes.
  This is global environment configuration; bad recovery is worse than no
  recovery.
```

---

## What to do if something goes wrong during install

If Claude Code makes a wrong move during the install:

1. Stop the session.
2. Look in `~/.claude/backups/<timestamp>/` for backups the install script made before overwriting anything.
3. If backups exist, restore the conflicting files from there.
4. If the plugin install path went wrong, run `/plugin uninstall jonathan-stack@jonathan-stack` to cleanly back out.
5. Re-run the starter prompt above. The script and prompts are idempotent — re-running them is safe.

## After install: a note on the auto-trigger feel

For the first few days, the personas may feel "louder" than you're used to — they have detailed system prompts and produce structured output by default. That's intentional for production work. For experiments, use `/quickspike` to opt out.

If a specific persona is over- or under-triggering compared to your expectations, edit its `description` field (in `~/.claude/agents/<n>.md` if direct-copy, or in the plugin source if plugin path) to tighten the trigger. The MAINTENANCE.md "Detecting Conflicts" section walks through this.
