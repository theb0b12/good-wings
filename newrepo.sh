#!/usr/bin/env bash
# reset_github_repo.sh
# Fully resets a GitHub repo so only your account appears as contributor.
# Deletes the remote repo, recreates it, and force-pushes a clean history.
#
# Usage:
#   chmod +x reset_github_repo.sh
#   ./reset_github_repo.sh
#
# Prerequisites:
#   - GitHub CLI (gh) installed and authenticated  →  https://cli.github.com
#   - Git configured with your name/email          →  git config --global user.email "you@example.com"

set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────
GITHUB_USERNAME="theb0b12"          # e.g. "octocat"
REPO_NAME="good-wings"                # e.g. "my-backend-project"
REPO_VISIBILITY="private"   # "private" or "public"
COMMIT_MESSAGE="Initial commit"
# ─────────────────────────────────────────────────────────────────────────────

# ── Validation ───────────────────────────────────────────────────────────────
if [[ -z "$GITHUB_USERNAME" || -z "$REPO_NAME" ]]; then
  echo "Please set GITHUB_USERNAME and REPO_NAME at the top of this script."
  exit 1
fi

if ! command -v gh &>/dev/null; then
  echo "GitHub CLI (gh) is not installed. Install it from https://cli.github.com"
  exit 1
fi

if ! command -v git &>/dev/null; then
  echo "Git is not installed."
  exit 1
fi
# ─────────────────────────────────────────────────────────────────────────────

REMOTE_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

echo ""
echo "════════════════════════════════════════════════════════"
echo "  GitHub Repo Full Reset"
echo "  Repo : ${GITHUB_USERNAME}/${REPO_NAME}"
echo "════════════════════════════════════════════════════════"
echo ""
echo "This will PERMANENTLY DELETE the remote repo and all"
echo "    its history, then recreate it from your local files."
echo ""
read -r -p "Type the repo name to confirm deletion: " CONFIRM

if [[ "$CONFIRM" != "$REPO_NAME" ]]; then
  echo "Confirmation didn't match. Aborting."
  exit 1
fi

# ── Step 1: Delete the remote repo ───────────────────────────────────────────
echo ""
echo "🗑️  Deleting remote repo..."
gh repo delete "${GITHUB_USERNAME}/${REPO_NAME}" --yes
echo "Remote repo deleted."

# ── Step 2: Scrub local .git and reinitialize ────────────────────────────────
echo ""
echo "Removing local .git folder..."
rm -rf .git

echo "Initializing fresh git repo..."
git init
git checkout -b main

# ── Step 3: Stage everything and make a clean commit ─────────────────────────
echo ""
echo "Staging all files..."
git add .

echo "Creating clean initial commit..."
git commit -m "$COMMIT_MESSAGE"

# ── Step 4: Recreate the remote repo ─────────────────────────────────────────
echo ""
echo "Creating new remote repo (${REPO_VISIBILITY})..."
gh repo create "${GITHUB_USERNAME}/${REPO_NAME}" \
  --"${REPO_VISIBILITY}" \
  --source=. \
  --remote=origin \
  --push

echo ""
echo "════════════════════════════════════════════════════════"
echo "Done! Your repo has been fully reset."
echo ""
echo "   Remote : ${REMOTE_URL}"
echo ""
echo "   GitHub caches contributor stats — the old contributor"
echo "   entry may linger for a few hours before disappearing."
echo "════════════════════════════════════════════════════════"
echo ""