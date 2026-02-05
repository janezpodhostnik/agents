#!/usr/bin/env bash
# lib/validate-script.sh - Validation script for agent skills
# Used by: nix run .#validate and nix flake check

set -euo pipefail

SKILLS_DIR="$1"
FAILED=0

echo "🔍 Validating all agent skills..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to validate a skill directory
validate_skills() {
    local skill_path="$1"
    local skill_name
    skill_name="$(basename "${skill_path}")"

    echo -n "  📦 ${skill_name} ... "

    # Check SKILL.md exists
    if [[ ! -f "${skill_path}/SKILL.md" ]]; then
        echo -e "${RED}FAILED${NC}"
        echo "     ERROR: Missing SKILL.md"
        return 1
    fi

    # Check YAML frontmatter exists
    if ! head -1 "${skill_path}/SKILL.md" | grep -q '^---$'; then
        echo -e "${RED}FAILED${NC}"
        echo "     ERROR: SKILL.md must start with YAML frontmatter (---)"
        return 1
    fi

    # Extract frontmatter (content between first two --- lines)
    local FRONTMATTER
    FRONTMATTER=$(awk '/^---$/{if (count==0) {count=1; next} else {exit}} count' "${skill_path}/SKILL.md")

    # Validate 'name' field
    local NAME_IN_FILE
    NAME_IN_FILE=$(echo "$FRONTMATTER" | yq -r '.name // empty' 2>/dev/null)
    if [ -z "$NAME_IN_FILE" ]; then
        echo -e "${RED}FAILED${NC}"
        echo "     ERROR: Missing 'name' in frontmatter"
        return 1
    fi

    if [[ "$NAME_IN_FILE" != "$skill_name" ]]; then
        echo -e "${YELLOW}WARNING${NC}"
        echo "     WARNING: Name in SKILL.md ('$NAME_IN_FILE') doesn't match directory name ('$skill_name')"
    fi

    # Validate 'description' field
    local DESCRIPTION
    DESCRIPTION=$(echo "$FRONTMATTER" | yq -r '.description // empty' 2>/dev/null)
    if [ -z "$DESCRIPTION" ]; then
        echo -e "${RED}FAILED${NC}"
        echo "     ERROR: Missing 'description' in frontmatter"
        return 1
    fi

    # Validate description length
    local DESC_LEN
    DESC_LEN=${#DESCRIPTION}
    if [[ $DESC_LEN -eq 0 ]] || [[ $DESC_LEN -gt 1024 ]]; then
        echo -e "${RED}FAILED${NC}"
        echo "     ERROR: Description must be 1-1024 characters (got $DESC_LEN)"
        return 1
    fi

    # Validate name format
    if ! echo "$NAME_IN_FILE" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
        echo -e "${RED}FAILED${NC}"
        echo "     ERROR: Name must be lowercase alphanumeric with hyphens only"
        return 1
    fi

    # Validate name length
    local NAME_LEN
    NAME_LEN=${#NAME_IN_FILE}
    if [[ $NAME_LEN -eq 0 ]] || [[ $NAME_LEN -gt 64 ]]; then
        echo -e "${RED}FAILED${NC}"
        echo "     ERROR: Name must be 1-64 characters (got $NAME_LEN)"
        return 1
    fi

    # Validate compatibility length if present
    local COMPAT
    COMPAT=$(echo "$FRONTMATTER" | yq -r '.compatibility // empty' 2>/dev/null)
    if [[ -n "$COMPAT" ]]; then
        local COMPAT_LEN
        COMPAT_LEN=${#COMPAT}
        if [[ $COMPAT_LEN -gt 500 ]]; then
            echo -e "${RED}FAILED${NC}"
            echo "     ERROR: Compatibility must be 500 characters or less (got $COMPAT_LEN)"
            return 1
        fi
    fi

    echo -e "${GREEN}OK${NC}"
    return 0
}

# Iterate through all skill directories
if [[ -d "$SKILLS_DIR" ]]; then
    for skill_dir in "$SKILLS_DIR"/*; do
        if [[ -d "$skill_dir" ]]; then
            if ! validate_skills "$skill_dir"; then
                FAILED=$((FAILED + 1))
            fi
        fi
    done
else
    echo "No skills directory found at $SKILLS_DIR"
    exit 1
fi

echo ""
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✅ All skills validated successfully!${NC}"
    exit 0
else
    echo -e "${RED}❌ $FAILED skill(s) failed validation${NC}"
    exit 1
fi
