{
  description = "Agent Skills - A collection of reusable agent capabilities";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { config, pkgs, system, ... }:
        let
          lib = pkgs.lib.extend (final: prev: {
            agent-skills = import ./lib { inherit pkgs; lib = final; };
          });

          # Import the skill set
          skillSet = import ./default.nix { inherit pkgs lib; };

          # Flatten all skills into a single attrset
          allSkills = lib.agent-skills.flattenSkillSet skillSet;

          # Validation package
          validateAllSkills = pkgs.writeShellApplication {
            name = "validate-all-skills";
            runtimeInputs = [ pkgs.yq ];
            text = ''
              SKILLS_DIR="''${1:-${./skills}}"
              exec ${./lib/validate-script.sh} "$SKILLS_DIR"
            '';
          };
        in
        {
          # Individual skill packages
          packages = allSkills;

          # Validation (for CI)
          checks.skill-validation = pkgs.runCommand "skill-validation-check" {
            nativeBuildInputs = [ validateAllSkills ];
          } ''
            echo "Running comprehensive skill validation..."
            validate-all-skills
            touch $out
          '';

          # Manual validation
          apps.validate = {
            type = "app";
            program = "${validateAllSkills}/bin/validate-all-skills";
            meta.description = "Validate all skill files";
          };

          # Dev shell for contributors
          devShells.default = pkgs.mkShell {
            buildInputs = [ pkgs.yq ];
          };
        };

      flake = {
        # Home Manager module (primary installation method)
        homeManagerModules.default = import ./nixosModules/home-manager.nix;

        # Templates for creating new skills
        templates = {
          skill = {
            path = ./templates/skill;
            description = "Template for creating a new agent skill";
          };
        };
      };
    };
}
