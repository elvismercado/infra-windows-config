---
description: "Review a Copilot prompt file for bugs, gaps, and improvements. Presents findings for approval before editing."
agent: "agent"
argument-hint: "Path to the prompt file to review (e.g., .github/prompts/scaffold-repo.prompt.md)"
---

Review the specified prompt file for correctness and completeness.

## 1. Ingest

Read the entire prompt file. If it references external files (seed data, conventions, copilot-instructions), read those too.

## 2. Analyze

Evaluate the prompt against these categories:

### A. Bugs — will cause runtime failures when the prompt is executed
- Code snippets that error on the target platform (e.g., PS 5.1 incompatibilities)
- Logic that contradicts itself across steps
- Missing data flow (value defined in one step but never passed to the step that needs it)
- Parameters/switches silently dropped during handoffs

### B. Gaps — scenarios the prompt hasn't considered
- Missing error handling or detection for operations that can fail
- Edge cases in user input (naming constraints, empty arrays, special characters)
- Ordering dependencies between steps
- Idempotency violations (running twice causes duplicates or errors)

### C. Design — correct but improvable
- Contradictions between steps (e.g., step 1 says X, step 10 says not-X)
- Redundant or dead instructions
- Missing DryRun/preview support for destructive operations
- Platform-specific assumptions that aren't documented

## 3. Present findings

For each finding:
- **ID** — category + number (e.g., A1, B3, C2)
- **Title** — one-line summary
- **Location** — which step(s) and what the current text says
- **Problem** — why it's wrong or missing
- **Fix** — specific change to make

Group by category. Skip anything that's already correct.

## 4. Wait for decisions

Present all findings and **stop**. Do not edit the file. Wait for the user to say which to adopt, modify, or skip.

## 5. Plan

After the user decides, write a numbered implementation plan listing every edit with its target location. Save to session memory.

## 6. Implement

Only after the plan is approved, apply all edits. Verify each change landed correctly.
