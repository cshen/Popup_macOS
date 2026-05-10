#!/bin/bash

text="${*:-$(cat)}"
chars=$(echo -n "$text" | wc -m | tr -d ' ')
chars_no_spaces=$(echo -n "$text" | tr -d '[:space:]' | wc -m | tr -d ' ')
words=$(echo -n "$text" | wc -w | tr -d ' ')
lines=$(echo -n "$text" | wc -l | tr -d ' ')

osascript -e "
display dialog \"Characters:         $chars
Characters (no spaces): $chars_no_spaces
Words:                 $words
Lines:                   $lines\" with title \"Text Statistics\" buttons {\"OK\"} default button \"OK\"
"

