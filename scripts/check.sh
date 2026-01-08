#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Resolve Project Root relative to this script (scripts/check.sh -> PROJECT_ROOT)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LEVEL_FILE="$PROJECT_ROOT/.gitflow_step"

[ ! -f "$LEVEL_FILE" ] && echo 1 > "$LEVEL_FILE"
STEP=$(cat "$LEVEL_FILE")

echo -e "${BLUE}Checking Objective #$STEP...${NC}"

case $STEP in
    1)
        if git rev-parse --verify develop >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Success! 'develop' branch created.${NC}"
            echo 2 > $LEVEL_FILE
        else
            echo -e "${RED}❌ Failed: Branch 'develop' not found.${NC}"
        fi
        ;;
    2)
        # 1. Check for merge commit (2 parents)
        develop_head=$(git rev-parse develop)
        parents_count=$(git rev-list --parents -n 1 develop | wc -w)
        
        # 2. Get the merge commit message
        merge_msg=$(git log -1 --pretty=%B develop)

        # 3. Get the commit message OF the feature (the 2nd parent)
        # Parent 1 = old develop, Parent 2 = the feature tip
        feature_tip=$(git rev-list --parents -n 1 develop | awk '{print $3}')
        
        if [ -z "$feature_tip" ]; then
             echo -e "${RED}❌ Failed: No merge found (no parent commit).${NC}"
             exit 1
        fi

        feature_msg=$(git log -1 --pretty=%B "$feature_tip")

        if [ "$parents_count" -le 1 ]; then
            echo -e "${RED}❌ Failed: No merge commit found on 'develop'. Did you forget --no-ff?${NC}"
        
        # Check Branch Naming in Merge Message (default git merge message contains branch name)
        elif [[ ! "$merge_msg" =~ "feature/" ]]; then
            echo -e "${RED}❌ Failed: Usage of Gitflow wrong.${NC}"
            echo -e "   The merged branch name must start with 'feature/'."
            echo -e "   Current merge message: $merge_msg"

        # Check Conventional Commits
        elif [[ ! "$feature_msg" =~ ^(feat|fix|docs|style|refactor|test|chore)(\(.*\))?: ]]; then
            echo -e "${RED}❌ Failed: Bad Commit Message Convention.${NC}"
            echo -e "   Your feature commit must look like: 'feat: add new button'"
            echo -e "   Yours was: '$feature_msg'"
        
        else
            echo -e "${GREEN}✅ Success! Feature merged properly & Commits are clean.${NC}"
            echo 3 > "$LEVEL_FILE"
        fi
        ;;
    3)
        # Check if hotfix branch exists first
        if ! git rev-parse --verify hotfix/emergency-fix >/dev/null 2>&1; then
             echo -e "${RED}❌ Failed: Branch 'hotfix/emergency-fix' not found.${NC}"
             echo -e "   Please create it and commit your fix."
             exit 0 # Don't exit script with error, just stop check
        fi

        hotfix_msg=$(git log -1 --pretty=%B hotfix/emergency-fix)

        # Check Conventional Commits for Hotfix
        if [[ ! "$hotfix_msg" =~ ^fix(\(.*\))?: ]]; then
             echo -e "${RED}❌ Failed: Bad Commit Message Convention on hotfix branch.${NC}"
             echo -e "   Your hotfix commit must look like: 'fix: description of fix'"
             echo -e "   Yours was: '$hotfix_msg'"

        # Check if hotfix is merged in both
        elif git branch --contains hotfix/emergency-fix | grep -q "main" && \
           git branch --contains hotfix/emergency-fix | grep -q "develop"; then
            echo -e "${GREEN}✅ Success! Hotfix applied to both branches & named correctly.${NC}"
            echo 4 > "$LEVEL_FILE"
        else
            echo -e "${RED}❌ Failed: Hotfix must be merged into main AND develop.${NC}"
        fi
        ;;
    4)
        if git tag | grep -q "v1.0"; then
            echo -e "${GREEN}🏆 QUEST COMPLETE! You are a Gitflow Master.${NC}"
            echo
            echo -e "${BLUE}Congratulations on finishing the game!${NC}"
            echo -e "You now understand the basics of strict branching and deployment."
            echo
            echo -e "${YELLOW}⭐ If you liked this challenge, please STAR the repository!${NC}"
            echo -e "   https://github.com/Maj-e/Gitflow_Master"
            echo -e "🔗 Share it with your project partner or anyone struggling with git."
            echo -e "👤 Don't forget to follow me on GitHub for more dev tools & guides:"
            echo -e "   https://github.com/Maj-e"
            echo
            echo -e "See you in production! 🚀"
        else
            echo -e "${RED}❌ Failed: Tag v1.0 not found.${NC}"
        fi
        ;;
esac