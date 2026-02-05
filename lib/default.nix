# lib/default.nix - Library functions for agent-skills
{ pkgs, lib }:

rec {
  # Import mkSkill function
  mkSkill = import ./mkSkill.nix { inherit pkgs lib; };

  # Flatten a nested skill set into a single attribute set
  # e.g., { development = { git = <drv>; }; } -> { "git" = <drv>; }
  flattenSkillSet = skillSet:
    let
      isSkill = v: lib.isDerivation v;
      
      flatten = prefix: set:
        lib.concatMapAttrs (name: value:
          if isSkill value then
            { ${name} = value; }
          else if lib.isAttrs value then
            flatten "${prefix}${name}-" value
          else
            {}
        ) set;
    in
    flatten "" skillSet;

  # Discover skills in a directory
  discoverSkills = path:
    let
      entries = builtins.readDir path;
      isDir = name: type: type == "directory";
      dirs = lib.filterAttrs isDir entries;
    in
    lib.mapAttrs (name: _: "${path}/${name}") dirs;

  # Load a skill from a path
  loadSkill = path:
    let
      name = baseNameOf path;
    in
    mkSkill {
      inherit name;
      src = path;
    };
}
