#!/usr/bin/env bash
# The streem workspace slots -- colour-coded parallel clones of the same repos,
# one wezterm tab each. Single source of truth for the colour/dot/path mapping:
# sourced by bin/wt-pr (colour -> path) and bin/tab-title (path -> dot), and by
# zsh_custom, whose precmd hook needs the repo roots.
#
# Sourced by both bash and zsh, so stick to syntax the two parse identically --
# in particular no associative arrays, which macOS's bash 3.2 lacks.
#
# Record: colour|dot|repo root|pane cwd
# (repo root and pane cwd differ for backend, where the interesting dir is api/)
STREEM_SLOTS=(
  "green|🟢|$HOME/github/streem/frontend|$HOME/github/streem/frontend"
  "blue|🔵|$HOME/github/streem/frontend-blue|$HOME/github/streem/frontend-blue"
  "yellow|🟡|$HOME/github/streem/frontend-yellow|$HOME/github/streem/frontend-yellow"
  "purple|🟣|$HOME/github/streem/frontend-purple|$HOME/github/streem/frontend-purple"
  "red|🔴|$HOME/github/streem/backend|$HOME/github/streem/backend/api"
)

# streem_slot_colours -> "green|blue|yellow|purple|red", for usage messages
streem_slot_colours() {
  local entry out=""
  for entry in "${STREEM_SLOTS[@]}"; do
    out="${out}${out:+|}${entry%%|*}"
  done
  printf '%s\n' "$out"
}

# streem_slot_by_colour <colour> -> the matching record, or 1
streem_slot_by_colour() {
  local entry
  for entry in "${STREEM_SLOTS[@]}"; do
    case "$entry" in
      "$1|"*) printf '%s\n' "$entry"; return 0 ;;
    esac
  done
  return 1
}

# streem_slot_by_path <path> -> the record whose repo root holds <path>, or 1
streem_slot_by_path() {
  local entry colour dot root cwd
  for entry in "${STREEM_SLOTS[@]}"; do
    IFS='|' read -r colour dot root cwd <<<"$entry"
    case "$1" in
      "$root"|"$root"/*) printf '%s\n' "$entry"; return 0 ;;
    esac
  done
  return 1
}

# streem_slot_by_dot <string> -> the record whose dot <string> starts with, or 1
streem_slot_by_dot() {
  local entry colour dot root cwd
  for entry in "${STREEM_SLOTS[@]}"; do
    IFS='|' read -r colour dot root cwd <<<"$entry"
    case "$1" in
      "$dot"*) printf '%s\n' "$entry"; return 0 ;;
    esac
  done
  return 1
}
