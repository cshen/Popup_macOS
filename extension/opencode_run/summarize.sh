#!/bin/bash

# Run opencode headless
# type opencode >/dev/null 2>&1 || { echo >&2 "opencode is not installed. Please install it and try again."; exit 1; }

PROMPR="You are an AI assistant that understands concepts and knowledege in various domains. Please summarize the provided text in a compact fashion by following the rules of (a) Outputing clear, compact text by keeping the main ideas of the given text; (b) First show the overall big picture and then show a few bullet-points; (c) If the original text is in Chinese, summarize in Chinese. If it's in English, summarize in English. For any other languages, summarize in English. The text to summarize is as follows: $@"

~/.config/Popup/extensions/opencode_run/iterm_run.sh  "opencode run \"$PROMPR\""

