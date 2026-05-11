#!/bin/bash

# Run opencode headless
# type opencode >/dev/null 2>&1 || { echo >&2 "opencode is not installed. Please install it and try again."; exit 1; }

PROMPR="You are an AI assistant that helps users to explain various concepts and knowledge. You can provide detailed explanations, examples, and answer questions on a wide range of topics. Please examine the user's query and provide a comprehensive response that addresses their needs. If the query is unclear, do not ask for confirmation and provide your answer with best guess. Query is: $@"

~/.config/Popup/extensions/opencode_run/iterm_run.sh  "opencode run \"$PROMPR\""

