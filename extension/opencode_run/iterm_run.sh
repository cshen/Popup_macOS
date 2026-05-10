#!/bin/bash

# Usage: ./iterm_run.sh "your command here"
# Example: ./iterm_run.sh "echo Hello World && ls -la"


# Fires up iTerm2 and runs the provided command in a new window.
# Note: This script assumes you have iTerm2 installed and configured properly.
# Make sure to give this script execute permissions: chmod +x iterm2-run.sh
# The script uses AppleScript to interact with iTerm2, creating a new window and executing the command you provide as an argument. If no command is provided, it will display usage instructions.

if [ $# -eq 0 ]; then
    echo "Usage: $0 <command>"
    exit 1
fi

COMMAND="$*"

# Escape double quotes and backslashes for AppleScript
ESCAPED_COMMAND=$(printf "%s" "$COMMAND" | sed 's/\\/\\\\/g; s/"/\\"/g')

osascript <<EOF
tell application "iTerm2"
    -- Ensure iTerm2 is running
    if not application "iTerm2" is running then
        launch
        delay 1 -- Give it a moment to start
    end if

    -- Create a new window/tab (or use 'create tab' for current window)
    -- create window with default profile
    create tab with default profile

    -- Get the current session of the new window
    tell current session of current window
        -- Write the command followed by newline (implicitly executes it)
        write text "$ESCAPED_COMMAND"
    end tell
end tell
EOF

