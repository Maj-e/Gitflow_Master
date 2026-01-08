# 📝 Cheatsheet : Gitflow & Navigation

## � Essentials (Daily Work)
- **Clone a repo:**
  `git clone <url>`
- **Stage changes:**
  `git add .` (all) or `git add <file>`
- **Save changes (Commit):**
  `git commit -m "Your message"`
- **View changes (before add):**
  `git diff`

## �🔍 Orientation & Status
- **See where I am:**
  `git status`
- **See history (Graph):** 
  `git log --graph --oneline --all`
- **List branches:**
  `git branch`

## 🌿 Branches & Merging
- **Switch branch:**
  `git checkout <branch>`
- **Merge a branch:**
  `git merge <branch>`
- **Start a feature (Gitflow):**
  `git checkout -b feature/my-feature develop`
- **Clean merge (Gitflow):**
  1. `git checkout develop`
  2. `git merge --no-ff feature/my-feature`

## 🗑️ Cleanup
- **Delete a branch (merged):**
  `git branch -d feature/my-feature`
- **Force delete a branch (unmerged):**
  `git branch -D feature/my-feature`
- **Delete a file:**
  `git rm filename`

## ☁️ Syncing (Remote)
- **Download changes:**
  `git pull`
- **Upload changes:**
  `git push`

## 📦 Temporary Storage (Stash)
- **Save unfinished work:**
  `git stash`
- **Restore saved work:**
  `git stash pop`
