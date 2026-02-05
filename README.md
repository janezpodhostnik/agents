# Agent Skills

A collection of reusable agent skills following the [agentskills.io specification](https://agentskills.io/specification).

## Installation

This repository is designed to be used with [Home Manager](https://github.com/nix-community/home-manager).

### Using with Home Manager

Add the flake input:

```nix
{
  inputs.agent-skills.url = "github:yourusername/agent-skills";

  outputs = { self, nixpkgs, home-manager, agent-skills, ... }:
    let
      system = "x86_64-linux"; # or your system
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations.username = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          agent-skills.homeManagerModules.default
          {
            programs.agent-skills = {
              enable = true;
              skills = [ "git-workflow" ];
            };
          }
        ];
      };
    };
}
```

### Install All Skills

```nix
programs.agent-skills = {
  enable = true;
  allSkills = true;
};
```

Skills are installed to `~/.config/agents/skills/` where Kimi CLI automatically discovers them.

## Available Skills

| Skill | Description |
|-------|-------------|
| [git-workflow](skills/development/git-workflow/) | Git workflow assistance (branching, committing, rebasing, PRs) |

## Development

### Adding a New Skill

1. Create a new skill from the template:
   ```bash
   mkdir -p skills/<category>/<skill-name>
   cp templates/skill/SKILL.md skills/<category>/<skill-name>/
   ```
   
   Or create manually:
   ```
   skills/<category>/<skill-name>/SKILL.md
   ```

2. Add your skill to `default.nix`:
   ```nix
   <category> = {
     <skill-name> = loadSkillFromDir "<category>" "<skill-name>";
   };
   ```

3. Validate and test:
   ```bash
   nix run .#validate    # Validate skill format
   nix flake check       # Full CI checks
   ```

## Skill Format

Skills follow the [agentskills.io specification](https://agentskills.io/specification):

```markdown
---
name: skill-name
description: Description of what this skill does
---

# Skill Title

Instructions here...
```

## License

Individual skills may have their own licenses specified in their frontmatter.
