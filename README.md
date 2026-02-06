# Agent Skills

A collection of personal reusable agent skills following the [agentskills.io specification](https://agentskills.io/specification). Use at your own risk.

## Installation

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
          { programs.agent-skills.enable = true; }
        ];
      };
    };
}
```

Skills are installed to `~/.config/agents/skills/agent-skills/` where Kimi CLI automatically discovers them.

## Available Skills

See the `skills/` directory for all available skills.

## Development

### Adding a New Skill

1. Create a new skill from the template:
   ```bash
   mkdir -p skills/<skill-name>
   cp skill-template.md skills/<skill-name>/SKILL.md
   ```

2. Edit `skills/<skill-name>/SKILL.md` with your skill content.

3. Build and test:
   ```bash
   nix build              # Build all skills
   ```

## License

This repository is licensed under the [MIT License](LICENSE).

Individual skills may have their own licenses specified in their frontmatter.
