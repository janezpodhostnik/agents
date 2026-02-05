# default.nix - Main skill registry
{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
}:

let
  agent-skills-lib = import ./lib { inherit pkgs lib; };
  inherit (agent-skills-lib) mkSkill;

  # Helper to load a skill from the skills directory
  loadSkillFromDir = category: name:
    mkSkill {
      inherit name;
      src = ./skills/${category}/${name};
    };

  # Define skills by category
in
{
  development = {
    git-workflow = loadSkillFromDir "development" "git-workflow";
  };

  # Reserved for future categories:
  # data-processing = { };
  # documentation = { };
  # testing = { };
}
