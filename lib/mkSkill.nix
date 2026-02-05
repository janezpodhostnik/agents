# mkSkill.nix - Creates a skill derivation from a skill directory
{ pkgs, lib }:

{ name
, src
, description ? null
, license ? null
, compatibility ? null
, metadata ? {}
, allowed-tools ? []
}:

let
  # Validate skill name according to spec (Nix evaluation time)
  validName = lib.assertMsg
    (builtins.match "^[a-z0-9]+(-[a-z0-9]+)*$" name != null)
    "Skill name '${name}' must be lowercase alphanumeric with hyphens only, and cannot start/end with hyphen";

  # Validate name length
  validLength = lib.assertMsg
    (stringLength name <= 64)
    "Skill name '${name}' must be 64 characters or less";

  stringLength = s: builtins.stringLength s;

in
pkgs.stdenvNoCC.mkDerivation {
  inherit name src;

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    # Validate SKILL.md exists (basic check only)
    if [ ! -f SKILL.md ]; then
      echo "ERROR: SKILL.md is required but not found in ${name}"
      exit 1
    fi

    # Create output directory
    mkdir -p $out/share/agent-skills/${name}

    # Copy all skill files
    cp -r . $out/share/agent-skills/${name}/

    # Create a metadata JSON file for programmatic access
    cat > $out/share/agent-skills/${name}/.metadata.json << METADATA_EOF
{
  "name": "${name}",
  "store_path": "$out",
  "install_path": "$out/share/agent-skills/${name}"
}
METADATA_EOF

    runHook postInstall
  '';

  meta = {
    description = if description != null then description else "Agent skill: ${name}";
    platforms = lib.platforms.all;
  } // lib.optionalAttrs (license != null) {
    inherit license;
  };
}
