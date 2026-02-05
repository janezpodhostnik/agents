# Agent Skills Repository

This repository manages agent skills for installation via Home Manager.

## Repository Structure

- **Skills**: `skills/<category>/<skill-name>/SKILL.md`
- **Registration**: Add to `default.nix`
- **Installation**: Via `homeManagerModules.default`

## Installation

Skills are installed to `~/.config/agents/skills/`:

```nix
programs.agent-skills = {
  enable = true;
  skills = [ "git-workflow" ];
};
```

## Adding a Skill

1. Create: `skills/<category>/<skill-name>/SKILL.md`
2. Register in `default.nix`
3. Validate: `nix run .#validate`

## Current Skills

- `skills/development/git-workflow/` - Git workflow assistance
