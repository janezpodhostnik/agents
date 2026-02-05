{
  description = "Agent Skills - A collection of reusable agent capabilities";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { pkgs, ... }: {
        packages.agent-skills = pkgs.symlinkJoin {
          name = "agent-skills";
          paths = map
            (name: pkgs.runCommand name { } ''
              mkdir -p $out/share/agent-skills/${name}
              cp -r ${./skills}/${name}/* $out/share/agent-skills/${name}/
              test -f $out/share/agent-skills/${name}/SKILL.md
            '')
            (builtins.attrNames (builtins.readDir ./skills));
        };
        packages.default = self.packages.${pkgs.system}.agent-skills;

        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.yq ];
        };
      };

      flake = {
        overlays.default = final: prev: {
          agent-skills = self.packages.${prev.system}.agent-skills;
        };

        homeManagerModules.default = { config, lib, pkgs, ... }: {
          options.programs.agent-skills.enable = lib.mkEnableOption "agent skills";
          config = lib.mkIf config.programs.agent-skills.enable {
            home.file."agents/skills/agent-skills".source =
              "${pkgs.agent-skills or self.packages.${pkgs.system}.agent-skills}/share/agent-skills";
          };
        };
      };
    };
}
