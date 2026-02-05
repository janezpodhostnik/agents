---
name: git-staged-review
description: Helps review and analyze git staged changes (diff --cached) before committing. Use when the user wants to review what they're about to commit, check staged changes for issues, or needs assistance preparing a meaningful commit.
license: MIT
compatibility: Requires git and a repository with staged changes
metadata:
  author: agent-skills
  version: "1.0"
  category: development
---

# Git Staged Review Skill

This skill helps review staged changes before committing to ensure code quality and meaningful commits.

## When to Use

- Before committing changes to verify what's being committed
- When preparing commit messages and need to understand the scope of changes
- To catch accidental changes, debugging code, or sensitive data before commit
- To ensure consistent code style and best practices in staged changes

## Instructions

### Step 1: View Staged Changes

Show all staged changes with full context:

```bash
git diff --cached
```

For a compact summary:

```bash
git diff --cached --stat
```

### Step 2: Review Changed Files

List all files with staged changes:

```bash
git diff --cached --name-only
```

Check which files are staged vs unstaged:

```bash
git status
```

### Step 3: Analyze Specific Files

Review a specific file's staged changes:

```bash
git diff --cached -- path/to/file
```

Show the staged version of a file:

```bash
git show :path/to/file
```

### Step 4: Review Checklist

Before committing, verify:

- [ ] No accidental `console.log`, `debugger`, or print statements
- [ ] No sensitive data (passwords, API keys, tokens) in changes
- [ ] Code follows project style conventions
- [ ] Changes are focused on a single concern
- [ ] Commit message accurately describes the changes

## Common Patterns

### Review with Line Numbers

```bash
git diff --cached -U10
```

### Review Word-by-Word Diff

```bash
git diff --cached --word-diff
```

### Review with Color Highlighting

```bash
git diff --cached --color-words
```

### Compare Against Specific Branch

See what would be committed compared to main:

```bash
git diff main...HEAD --cached
```

## Edge Cases

### Partial Staging (git add -p)

When only parts of a file are staged:

```bash
# View staged portion only
git diff --cached -- path/to/partially-staged-file

# View unstaged portion
git diff -- path/to/partially-staged-file
```

### Binary Files

Binary files show as "Binary files differ". To see which binary files changed:

```bash
git diff --cached --name-only --diff-filter=ACM
```

### Empty Staging Area

If no changes are staged:

```bash
# This produces no output
git diff --cached

# Check status
git status
```

### Submodules

For repositories with submodules:

```bash
# Include submodule changes in diff
git diff --cached --submodule
```

## Related Commands

| Command | Purpose |
|---------|---------|
| `git diff --cached` | View staged changes |
| `git diff --cached --stat` | Summary statistics |
| `git diff --cached --name-only` | List changed files |
| `git diff HEAD` | View all changes (staged + unstaged) |
| `git status` | Check staging status |

## Best Practices

- Always review staged changes before committing
- Stage related changes together for logical commits
- Use `git add -p` for fine-grained control over what gets staged
- Keep commits focused on a single purpose
- Write commit messages that describe the "why" not just the "what"
