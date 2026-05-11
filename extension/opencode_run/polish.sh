#!/bin/bash

# Run opencode headless
# type opencode >/dev/null 2>&1 || { echo >&2 "opencode is not installed. Please install it and try again."; exit 1; }

PROMPR="You are an AI assistant that specializes in writing. Please polish the following text with the rules of (a) Keep the original meaning; (b) Correct all grammar and spelling erros; (c) If the provided text is incomplete, make a good guess and complete the text. The text to polish is as follows: $@"

~/.config/Popup/extensions/opencode_run/iterm_run.sh  "opencode run \"$PROMPR\""

