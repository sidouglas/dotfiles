#!/usr/bin/env zsh
echo "\n<<< Starting git-secrets Setup >>>\n"

# `gitconfig` points init.templateDir at this directory, so every `git init` and
# `git clone` copies its hooks into the new repo. Nothing else creates it, so
# without this step git prints
#   warning: templates not found in ~/.git-templates/git-secrets
# on every clone and no repo ever gets a pre-commit scan.
TEMPLATE_DIR="$HOME/.git-templates/git-secrets"

if ! exists git-secrets; then
  echo "git-secrets isn't installed, so $TEMPLATE_DIR can't be built."
  echo "Add 'brew \"git-secrets\"' to this host's Brewfile and re-run."
  exit 1
fi

# --force so a re-run repairs the hooks rather than skipping them. This matters
# more than it looks: a hook that lost its execute bit (copying the directory
# between machines is enough to do it) is skipped by git in silence, which is
# indistinguishable from being protected.
git secrets --install --force "$TEMPLATE_DIR"

# Belt and braces for that same failure -- the hooks are inert unless git can
# execute them, and nothing warns you when they aren't.
chmod +x "$TEMPLATE_DIR"/hooks/*

# The hooks scan for whatever secrets.patterns holds, and an empty list matches
# nothing while still looking fully wired up. The patterns live in the repo's
# `gitconfig`, so an empty list here means ~/.gitconfig isn't linked to it yet.
pattern_count=$(git config --get-all secrets.patterns 2>/dev/null | wc -l | tr -d ' ')

if (( pattern_count == 0 )); then
  echo "\nNo secrets.patterns are registered, so the hooks will run but match"
  echo "nothing. They come from this repo's gitconfig -- check that ~/.gitconfig"
  echo "is a link to it, then re-run."
  exit 1
fi

echo "\ngit-secrets ready: $pattern_count patterns, hooks in $TEMPLATE_DIR"
