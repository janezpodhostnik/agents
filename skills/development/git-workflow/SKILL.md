---
name: git-workflow
description: Helps with common Git workflows including branching, committing, rebasing, and pull requests. Use when the user mentions git operations, version control tasks, or needs help with repository management.
license: MIT
compatibility: Requires git and access to the repository
metadata:
  author: agent-skills
  version: "1.0"
  category: development
---

# Git Workflow Skill

This skill assists with Git operations and workflows to help maintain a clean repository history.

## Common Workflows

### Feature Branch Workflow

1. Create a new feature branch from the main branch:
   ```bash
   git checkout -b feature/my-feature
   ```

2. Make changes and commit regularly:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

3. Keep your branch updated with main:
   ```bash
   git fetch origin
   git rebase origin/main
   ```

4. Push your branch and create a pull request:
   ```bash
   git push -u origin feature/my-feature
   ```

### Commit Message Conventions

Follow conventional commits format:

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Test changes
- `chore:` - Build/tooling changes

Example:
```
feat: add user authentication

- Implement JWT token validation
- Add login/logout endpoints
- Update user model
```

### Safe Operations

Before running destructive commands:

1. Check current status: `git status`
2. Create a backup branch: `git branch backup/my-branch`
3. Use `--dry-run` flags when available

### Resolving Common Issues

**Merge conflicts:**
1. Identify conflicted files: `git status`
2. Open and edit files to resolve conflicts
3. Mark as resolved: `git add <file>`
4. Complete merge: `git commit`

**Undoing commits:**
- Undo last commit (keep changes): `git reset --soft HEAD~1`
- Undo last commit (discard changes): `git reset --hard HEAD~1`
- Amend last commit: `git commit --amend`

## Best Practices

- Commit early, commit often
- Write descriptive commit messages
- Keep commits focused on single concerns
- Rebase feature branches before merging
- Delete merged branches
