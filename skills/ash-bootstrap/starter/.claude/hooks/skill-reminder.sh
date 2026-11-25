#!/usr/bin/env bash
# PreToolUse hook: names the skill to load for the file being edited. A line in
# CLAUDE.md saying the same is forgotten by the tenth edit; the hook arrives at the edit.
set -euo pipefail

input=$(cat)
path=$(jq -r '.tool_input.file_path // ""' <<<"$input")

# the file on disk, or the content of a Write that has not created it yet
matches() {
  if [[ -f "$path" ]]; then grep -qE "$1" -- "$path"
  else jq -r '.tool_input.content // ""' <<<"$input" | grep -qE "$1"; fi
}

case "$path" in
  */assets/*.vue) skill="live-vue" ;;
  */assets/*.ts) matches 'from "(vue|live_vue)' || exit 0; skill="live-vue" ;;
  */lib/*_web/*) skill="phoenix-framework" ;;
  */lib/*.ex | */lib/*.exs) matches '^[[:space:]]*use Ash\.(Resource|Domain)\b' || exit 0; skill="ash-framework" ;;
  *) exit 0 ;;
esac

printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"Editing %s: the skill for this file is \\"%s\\". If it is not loaded in this session yet, call it with the Skill tool before the edit and follow its rules."}}\n' \
  "$path" "$skill"
