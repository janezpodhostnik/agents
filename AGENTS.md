# Agent Skills - Project Guide for AI Agents

## Project Overview

This is a **collection of reusable agent skills** following the [agentskills.io specification](https://agentskills.io/specification). Skills are modular capabilities that enhance AI agents (like Kimi CLI) with specialized knowledge, workflows, or tool integrations.

Each skill is a self-contained directory with a `SKILL.md` file containing instructions, examples, and reference material that helps AI agents perform specific tasks.

## Technology Stack

| Component | Technology |
|-----------|------------|
| Build System | Nix (flakes) |
| Flake Framework | flake-parts |
| Supported Platforms | x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin |
| YAML Processing | yq |
| Validation | Bash |
| CI/CD | GitHub Actions |
| Environment Management | direnv |

## Project Structure

```
.
├── skills/                    # Individual skill directories
│   └── <skill-name>/          # Each skill has its own directory
│       └── SKILL.md           # Skill definition with YAML frontmatter
├── skill-template.md          # Template for creating new skills
├── validate-skills.sh         # Validation script for skill format
├── flake.nix                  # Nix flake definition (build, packages, modules)
├── flake.lock                 # Nix dependency lock file
├── .envrc                     # direnv configuration (use flake)
├── .github/
│   └── workflows/
│       └── validate-skills.yml  # CI workflow
├── README.md                  # Human-facing documentation
├── LICENSE                    # MIT License
└── AGENTS.md                  # This file (AI agent documentation)
```

## Build System Architecture

### Nix Flake Structure

The project uses **flake-parts** for modular flake composition:

**Per-System Outputs** (`perSystem`):
- `packages.agent-skills`: Symlinks all skills from `./skills/` to `$out/share/agent-skills/`
- `packages.default`: Alias for `agent-skills`
- `checks.validate-skills`: Runs `validate-skills.sh` on the skills directory
- `devShells.default`: Provides `yq` for YAML processing

**Flake-Wide Outputs** (`flake`):
- `overlays.default`: Makes `agent-skills` available via Nix overlay
- `homeManagerModules.default`: Home Manager module that installs skills to `~/.config/agents/skills/`

### Build Outputs

After `nix build`, the result contains:
```
result/
└── share/
    └── agent-skills/
        └── <skill-name>/
            └── SKILL.md
```

## Skill Format Specification

Each skill is a directory under `skills/` containing a `SKILL.md` file with:

### YAML Frontmatter (Required)

```yaml
---
name: skill-name              # Must match directory name, kebab-case, 1-64 chars
                             # Format: ^[a-z0-9]+(-[a-z0-9]+)*$
description: Brief description of what this skill does  # 1-1024 characters
license: MIT                  # License for this skill (optional)
compatibility: Optional requirements  # Max 500 characters if present (optional)
metadata:                     # Optional metadata
  author: your-name
  version: "1.0"
  category: development       # e.g., development, data-analysis, devops
---
```

### Content Structure

The markdown content should include:
- `# Title` - Skill title
- `## When to Use` - Activation criteria
- `## Instructions` - Step-by-step guidance with code examples
- `## Common Patterns` - Reusable patterns
- `## Edge Cases` - Special handling scenarios
- `## References` - External links and documentation

See `skill-template.md` for a complete template.

## Build and Development Commands

```bash
# Build all skills
nix build

# Build and output to specific directory
nix build .#default --out-link ./result

# Validate all skills (runs automatically during build)
bash validate-skills.sh ./skills

# Enter development shell with required tools (yq, etc.)
nix develop

# Check flake configuration
nix flake check
```

## Testing and Validation

The `validate-skills.sh` script enforces:

| Check | Rule |
|-------|------|
| SKILL.md exists | Required file in each skill directory |
| YAML frontmatter | Must start with `---` |
| name field | Required, 1-64 chars, kebab-case (`^[a-z0-9]+(-[a-z0-9]+)*$`) |
| description field | Required, 1-1024 characters |
| compatibility field | Optional, max 500 characters if present |
| name consistency | Should match directory name (warning if different) |

Validation is automatic via:

1. **Local validation**:
   ```bash
   bash validate-skills.sh ./skills
   ```

2. **Nix flake check**:
   ```bash
   nix flake check
   ```

3. **CI/CD (GitHub Actions)**:
   - Runs on push to `main` branch
   - Runs on pull requests to `main`
   - Uses `nix flake check` for flake validation
   - Uses `nix build` to ensure skills compile correctly

## Adding a New Skill

1. Create skill directory:
   ```bash
   mkdir -p skills/<skill-name>
   ```

2. Copy template:
   ```bash
   cp skill-template.md skills/<skill-name>/SKILL.md
   ```

3. Edit `SKILL.md` with appropriate content ensuring:
   - `name` matches the directory name
   - `description` is 1-1024 characters
   - Name uses only lowercase alphanumeric and hyphens (kebab-case)

4. Validate:
   ```bash
   bash validate-skills.sh ./skills
   ```

5. Build:
   ```bash
   nix build
   ```

## Deployment & Distribution

### Home Manager Module

The project provides a Home Manager module for Nix users:

```nix
{
  inputs.agent-skills.url = "github:yourusername/agent-skills";

  outputs = { self, nixpkgs, home-manager, agent-skills, ... }:
    {
      homeConfigurations.username = home-manager.lib.homeManagerConfiguration {
        modules = [
          agent-skills.homeManagerModules.default
          { programs.agent-skills.enable = true; }
        ];
      };
    };
}
```

Skills are installed to `~/.config/agents/skills/agent-skills/` where Kimi CLI automatically discovers them.

### Nix Overlay

```nix
{
  pkgs = import nixpkgs {
    overlays = [ agent-skills.overlays.default ];
  };
  
  # Now pkgs.agent-skills is available
}
```

## Development Environment

This project uses **direnv** for automatic environment setup:

```bash
# Ensure direnv is installed and allowed
direnv allow

# Now nix develop runs automatically when entering the directory
```

Required development tools (provided by Nix shell):
- `yq` - YAML processing for validation

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/validate-skills.yml`):

1. Triggers on push/PR to `main`
2. Installs Nix using DeterminateSystems installer
3. Runs `nix flake check --print-build-logs`
4. Runs `nix build .#default --print-build-logs`

## Code Style Guidelines

### Skill Naming
- Use kebab-case (lowercase with hyphens)
- Be descriptive but concise
- Examples: `git-staged-review`, `docker-compose-debug`, `python-profiling`

### YAML Frontmatter
- Use double quotes for string values when needed
- Keep description under 1024 characters
- Include license field (MIT by default)

### Markdown Content
- Use proper heading hierarchy (#, ##, ###)
- Include code blocks with language specification
- Provide practical, runnable examples
- Document edge cases and common patterns

## Security Considerations

- Skills are distributed as read-only markdown files
- No executable code is included in skills
- Validation script checks file structure but does not execute skill content
- Individual skills may specify compatibility requirements for safety
- Each skill can have its own license specified in frontmatter

## License

The project is licensed under MIT License. Individual skills may have their own licenses specified in their YAML frontmatter.

## References

- [agentskills.io specification](https://agentskills.io/specification)
- [Nix flakes documentation](https://nixos.wiki/wiki/Flakes)
- [flake-parts documentation](https://flake.parts/)
