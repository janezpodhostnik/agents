# nixosModules/home-manager.nix - Home Manager module for agent-skills
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.agent-skills;

  # Import the skill set
  skillSet = import ../default.nix { inherit pkgs; inherit (pkgs) lib; };

  # Helper to get a skill by name
  getSkill = name: 
    let
      flatten = set:
        lib.concatMapAttrs (n: v:
          if lib.isDerivation v then { ${n} = v; }
          else if lib.isAttrs v then flatten v
          else {}
        ) set;
      allSkills = flatten skillSet;
    in
    allSkills.${name} or (throw "Skill '${name}' not found");

  # Install a skill to the config directory
  installSkill = name: skill:
    {
      "agents/skills/${name}" = {
        source = "${skill}/share/agent-skills/${name}";
        recursive = true;
      };
    };
in
{
  options.programs.agent-skills = {
    enable = mkEnableOption "agent-skills - AI agent skill collection";

    skills = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        List of skill names to install.
        Available skills can be found in the skills/ directory.
      '';
      example = [ "git-workflow" ];
    };

    allSkills = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Install all available skills.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.file = mkMerge [
      # Install selected skills
      (mkIf (cfg.skills != []) (
        mkMerge (map (name: installSkill name (getSkill name)) cfg.skills)
      ))

      # Install all skills
      (mkIf cfg.allSkills (
        let
          flatten = set:
            lib.concatMapAttrs (n: v:
              if lib.isDerivation v then { ${n} = v; }
              else if lib.isAttrs v then flatten v
              else {}
            ) set;
          allSkillsFlat = flatten skillSet;
        in
        mkMerge (lib.mapAttrsToList installSkill allSkillsFlat)
      ))
    ];
  };
}
