#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${RED}⚠️  WARNING: THIS WILL WIPE ALL GIT HISTORY AND LOCAL .txt FILES!${NC}"
echo -e "Your history will be reset to 'Initial commit' and all .txt files will be deleted."
read -p "Are you sure? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Determine project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo -e "${YELLOW}🔄 Resetting Git history...${NC}"

# 1. Create a temporary orphan branch (no parents)
git checkout --orphan temp_reset_branch &> /dev/null

# 1b. Delete .txt files (game artifacts)
rm -f *.txt

# 2. Stage all current files
git add -A

# 3. Create the fresh commit
git commit -m "♻️ Game Reset: Fresh Start" &> /dev/null

# 4. Delete all other branches (main, develop, etc.)
# Get list of all branches except the current one (temp_reset_branch)
branches=$(git branch | grep -v "temp_reset_branch" | tr -d ' *')

for branch in $branches; do
    git branch -D "$branch" &> /dev/null
done

# 5. Delete all tags (they keep old history alive)
git tag | xargs git tag -d &> /dev/null

# 6. Rename current branch to main
git branch -m main

# 7. Reset game level
echo 1 > .gitflow_step

echo -e "${GREEN}✅ Done! You are now on a fresh 'main' branch with 1 commit.${NC}"
echo -e "${YELLOW}👉 If you are using GitHub, you must force push:${NC}"
echo -e "   git push -f origin main"
