#!/usr/bin/env bash
set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Resolve Project Root relative to this script (scripts/play.sh -> PROJECT_ROOT)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LEVEL_FILE="$PROJECT_ROOT/.gitflow_step"

ensure_git_repo() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "${RED}Error:${NC} this game must be run inside a git repository."
    exit 1
  fi
}

ensure_level_file() {
  if [ ! -f "$LEVEL_FILE" ]; then
    echo 1 > "$LEVEL_FILE"
  fi
}

current_step() {
  ensure_level_file
  local step
  step=$(cat "$LEVEL_FILE" 2>/dev/null || echo 1)
  if [[ ! "$step" =~ ^[0-9]+$ ]]; then
    step=1
  fi
  echo "$step"
}

step_title() {
  case "$1" in
    1) echo "Level 1: The Foundation" ;;
    2) echo "Level 2: New Feature" ;;
    3) echo "Level 3: The Production Emergency" ;;
    4) echo "Level 4: The Grand Release" ;;
    *) echo "(Unknown Level)" ;;
  esac
}

print_objective() {
  local step="$1"
  echo -e "${BLUE}=== $(step_title "$step") ===${NC}"
  case "$step" in
    1)
      cat <<'EOF'
Goal: Prepare the integration environment.
Task: Create a branch named `develop` from `main`.
Verification: Run `make check`.
EOF
      ;;
    2)
      cat <<'EOF'
Goal: Add the "Addition" function.
Tasks:
  1) Create a branch `feature/add-func`.
  2) Create `app.txt` and write the branch name inside.
  3) Merge it back into `develop` using --no-ff.
Verification: Run `make check`.
EOF
      ;;
    3)
      cat <<'EOF'
Goal: Fix a critical bug on the live site.
Tasks:
  1) Create `hotfix/emergency-fix` from `main`.
  2) Fix the bug in `app.txt`.
  3) Merge into both `main` and `develop`.
Verification: Run `make check`.
EOF
      ;;
    4)
      cat <<'EOF'
Goal: Ship the final product.
Tasks:
  1) Merge `develop` into `main`.
  2) Tag it as `v1.0`.
EOF
      ;;
    *)
      echo "Unknown level. Run: make restart"
      ;;
  esac
}

show_hint() {
  local step="$1"
  echo -e "${BLUE}=== Hint for Level $step ===${NC}"
  case "$step" in
    1)
      echo "  git checkout -b develop main"
      ;;
    2)
      cat <<'EOF'
  git checkout develop
  git checkout -b feature/add-func
  echo "feature/add-func" > app.txt
  git add app.txt && git commit -m "Add feature info"
  git checkout develop
  git merge --no-ff feature/add-func
EOF
      ;;
    3)
      cat <<'EOF'
  git checkout main
  git checkout -b hotfix/emergency-fix
  # edit app.txt, then:
  git add app.txt && git commit -m "Hotfix"
  git checkout main && git merge --no-ff hotfix/emergency-fix
  git checkout develop && git merge --no-ff hotfix/emergency-fix
EOF
      ;;
    4)
      cat <<'EOF'
  git checkout main
  git merge --no-ff develop
  git tag v1.0
  make check
EOF
      ;;
    *)
      echo "No hint available for this level."
      ;;
  esac
}

run_check() {
  ensure_git_repo
  echo -e "${BLUE}Running check...${NC}"
  bash "$SCRIPT_DIR/check.sh"
}

show_status() {
  ensure_git_repo
  git --no-pager log --graph --oneline --all
}

restart_progress() {
  echo 1 > "$LEVEL_FILE"
  echo -e "${YELLOW}Progress reset to Level 1.${NC}"
}

usage() {
  cat <<'EOF'
Usage:
  bash play.sh            # interactive mode
  bash play.sh objective  # show current objective
  bash play.sh check      # run check.sh
  bash play.sh status     # show git graph
  bash play.sh restart    # reset progress
EOF
}

cmd="${1:-}"
case "$cmd" in
  objective)
    step=$(current_step)
    print_objective "$step"
    exit 0
    ;;
  check)
    run_check
    exit 0
    ;;
  status)
    show_status
    exit 0
    ;;
  restart)
    restart_progress
    exit 0
    ;;
  "" )
    :
    ;;
  -h|--help|help)
    usage
    exit 0
    ;;
  *)
    echo -e "${RED}Unknown command:${NC} $cmd"
    usage
    exit 2
    ;;
esac

ensure_git_repo

# Introduction message
clear
cat <<'EOF'
Welcome to Gitflow Master: The Branching Quest! 🌊

This interactive CLI game will guide you through the Gitflow branching model.
You will perform git operations in your terminal to complete objectives.

💡 PRO TIP: Open a SECOND terminal window now!
   - Use Terminal 1 (this one) to check objectives and verify progress.
   - Use Terminal 2 to run your git commands (git checkout, merge, etc.).

EOF
read -n 1 -s -r -p "Press any key to start the game..."

while true; do
  clear
  step=$(current_step)
  echo
  echo -e "${BLUE}🌊 Gitflow Master: The Branching Quest${NC}"
  echo -e "Current: ${YELLOW}Objective #$step${NC} — $(step_title "$step")"
  echo
  echo "1) Show objective"
  echo "2) Run check (make check)"
  echo "3) Show git graph (status)"
  echo "4) Restart progress"
  echo "5) Get a hint"
  echo "6) Exit"
  echo
  if ! read -r -p "> " choice; then
    echo
    exit 0
  fi

  case "$choice" in
    1)
      clear
      print_objective "$step"
      ;;
    2)
      clear
      run_check || true
      ;;
    3)
      clear
      show_status
      ;;
    4)
      clear
      restart_progress
      ;;
    5)
      clear
      show_hint "$step"
      ;;
    6)
      clear
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid choice.${NC}"
      ;;
  esac

  if [ "$choice" != "6" ]; then
    echo
    read -n 1 -s -r -p "Press any key to continue..."
  fi

done
