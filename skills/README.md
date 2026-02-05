# Skills Index

This directory contains all agent skills organized by category.

## Categories

### development
Skills for software development tasks.

- **git-workflow** - Git workflow assistance (branching, committing, rebasing, PRs)

---

## Adding a New Skill

1. Create a new directory under the appropriate category (or create a new category):
   ```
   skills/<category>/<skill-name>/
   ```

2. Create a `SKILL.md` file with YAML frontmatter:
   ```yaml
   ---
   name: skill-name
   description: Description of what this skill does
   ---
   ```

3. Validate your skill:
   ```bash
   nix run .#validate
   ```

4. Or use the Nix flake for full checks:
   ```bash
   nix flake check
   ```

## Skill Naming Conventions

- Use lowercase letters, numbers, and hyphens only
- Must not start or end with a hyphen
- Maximum 64 characters
- Must match the directory name

Examples:
- ✅ `git-workflow`
- ✅ `json-processing`
- ❌ `Git-Workflow` (uppercase not allowed)
- ❌ `-workflow` (cannot start with hyphen)
- ❌ `git--workflow` (no consecutive hyphens)
