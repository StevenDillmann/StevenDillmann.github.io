#!/bin/bash
# Refreshes the Google Scholar cache from this Mac and pushes it if anything changed.
# Scholar often blocks GitHub's servers but not a home connection, so this is the main
# refresh path; .github/workflows/update-scholar.yml stays as a backup.
#
# Runs daily via ~/Library/LaunchAgents/io.github.stevendillmann.scholar-refresh.plist.
# Works in its own clone (~/.scholar-refresh/site) so it never touches the checkout you edit.
# Log: ~/.scholar-refresh/refresh.log
set -euo pipefail

export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

REPO_URL="https://github.com/StevenDillmann/StevenDillmann.github.io"
DIR="$HOME/.scholar-refresh/site"

echo "=== $(date '+%Y-%m-%d %H:%M:%S') ==="

if [ ! -d "$DIR/.git" ]; then
  git clone -q "$REPO_URL" "$DIR"
fi
cd "$DIR"

git fetch -q origin main
git checkout -q main
git reset -q --hard origin/main

bundle install --quiet
SCHOLAR_REFRESH=1 bundle exec jekyll build --quiet 2>&1 | grep -E "Warning: Failed" || true

git add _cache/
if git diff --staged --quiet; then
  echo "No Scholar changes (or Scholar blocked the request)."
  exit 0
fi

git -c user.name="StevenDillmann" -c user.email="stevendi@stanford.edu" \
  commit -q -m "chore: refresh Google Scholar cache (from Mac)"
git push -q origin main
echo "Pushed new Scholar data; the site redeploys automatically."
