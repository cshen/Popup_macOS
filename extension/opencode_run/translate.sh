#!/bin/bash

# Run opencode headless
# type opencode >/dev/null 2>&1 || { echo >&2 "opencode is not installed. Please install it and try again."; exit 1; }

PROMPR="You are an AI assistant that understands concepts and knowledege in various domains. You know well many languages. Please translate the text into English and Chinese. If the text is already in either English or Chinese, then just output the text in the absent language. The text to translate is as follows: $@"

~/.config/Popup/extensions/opencode_run/iterm_run.sh  "opencode run \"$PROMPR\""

