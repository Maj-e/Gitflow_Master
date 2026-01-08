.PHONY: all check status restart run

all: run

check:
	@bash scripts/check.sh

run:
	@bash scripts/play.sh

status:
	@git log --graph --oneline --all

restart:
	@echo 1 > .gitflow_step
	@echo "Progress reset to Level 1."

hard-reset:
	@bash scripts/reset_game.sh

reset-hard: hard-reset