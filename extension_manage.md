# Extension Management CommandLine Tool Development Guide

This document provides a guide for developing a command-line tool to manage extensions. The tool will allow users to install, update, and remove extensions easily.
All the extensions will be stored in a specific directory, which is `~/.config/Popup/extensions/extensions` and the tool will handle the operations related to managing these extensions.

## 1. Define the Command Structure
Start by defining the command structure for your tool. Common commands include:
- `install`: Install a new extension.
- `update`: Update an existing extension.
- `remove`: Remove an installed extension.
- `list`: List all installed extensions.

## 2. Choose a Programming Language

Select a programming language that you are comfortable with and that is suitable for command-line tool development. Here we use Bash

## 3. Implement Command Handlers

For each command, implement a handler function that performs the required operations. For example:
```bash
install_extension() {
    echo "Installing extension: $1"
    # Add logic to download and install the extension
    # Two cases: 1. The extension is in a github repository, 2. The extension is a local file

    # This is not complete. We should allow users to install from a github repo by providing: popext install https://github.com/cshen/Popup (or popext install cshen/Popup) and also allow users to install from a local file by providing: popext install /path/to/extension_file

    # The following does not handle ... install cshen/Popup, you should enhance it to handle this case as well.
    if [[ "$1" == *"github.com"* ]]; then
        # Logic to clone the repository and install the extension
        git clone "$1" /path/to/extensions/$(basename "$1")
    else
        # Logic to copy the local file to the extensions directory
        cp "$1" /path/to/extensions/
    fi
    
        # After installation, you can also add logic to verify the installation and provide feedback to the user, such as confirming that the extension was installed successfully or providing error messages if the installation failed.
        if [ -d "/path/to/extensions/$(basename "$1")" ]; then
            echo "Extension installed successfully."
        else
            echo "Failed to install extension."
        fi

    # This command should also accept to install from a file which contains the list of extensions to be installed, and the tool will read the file and install all the extensions listed in it. This can be useful for users who want to set up their environment with a predefined set of extensions. This is similar to homebrew's `brew bundle` command, which allows users to define their dependencies in a `Brewfile` and install them with a single command. Implementing this feature will enhance the usability of your tool and make it more convenient for users to manage their extensions.

     if [[ -f "$1" ]]; then
        while IFS= read -r extension; do
            install_extension "$extension"
        done < "$1"
    fi

    # The installed extensions will be recorded in a file `~/.config/Popup/extensions_list.json` which will contain the name, version, and source of each installed extension. This file will be updated every time an extension is installed, updated, or removed, providing a centralized record of the user's extensions and their states. This can be useful for users to keep track of their installed extensions and manage them effectively.
     if [[ -d "/path/to/extensions/$(basename "$1")" ]]; then
        echo "{\"name\": \"$(basename "$1")\", \"version\": \"$(git -C /path/to/extensions/$(basename "$1") rev-parse --abrev-ref HEAD)\", \"source\": \"$1\"}" >> ~/.config/Popup/extensions_list.json
    fi
    
    # There is another file `~/.config/Popup/extensions_state.json` which will contain the state of each extension, such as whether it is enabled or disabled. This file will be updated every time an extension is installed, updated, or removed, providing a centralized record of the user's extensions and their states. 
    # Each newly installed extension will be enabled by default, and users can disable or enable extensions as needed. This allows users to manage their extensions more effectively, giving them control over which extensions are active at any given time. However, for those extensions that are already installed, the state will be preserved during updates, meaning that if an extension was disabled before the update, it will remain disabled after the update. This ensures that users do not lose their preferred settings when updating their extensions. 

     # For newly installed extesions,
     if [[ -d "/path/to/extensions/$(basename "$1")" ]]; then
        echo "{\"$(basename "$1")\": true}" >> ~/.config/Popup/extensions_state.json
     fi
    # Example:  {"search_GoogleScholar":true,"say_words":true} 
}


update_extension() {
    echo "Updating extension: $1"
    # Add logic to check for updates and apply them
     if [[ "$1" == *"github.com"* ]]; then
        # Logic to pull the latest changes from the repository
        cd /path/to/extensions/$(basename "$1") && git pull
    else
        echo "Update not supported for local files."
    fi
}

remove_extension() {
    echo "Removing extension: $1"
    # Add logic to remove the extension
    rm -rf /path/to/extensions/$(basename "$1")

    # Once an extension is removed, you should also update the `extensions_list.json` and `extensions_state.json` files to reflect the removal of the extension. This ensures that the records of installed extensions and their states remain accurate and up-to-date, providing users with a clear overview of their current extensions and their statuses.
     sed -i "/$(basename "$1")/d" ~/.config/Popup/extensions_list.json
     sed -i "/$(basename "$1")/d" ~/.config/Popup/extensions_state.json
}

list_extensions() {
    echo "Listing installed extensions:"
    # Add logic to list all installed extensions
    ls /path/to/extensions/

    # Optionally, you can add more details about each extension, such as version or source, and the status (enabled/disabled) of each extension. This can be achieved by reading the `extensions_list.json` and `extensions_state.json` files. 
     if [[ -f "~/.config/Popup/extensions_list.json" ]]; then
        cat ~/.config/Popup/extensions_list.json
    else
        echo "No extensions installed."
    fi

     if [[ -f "~/.config/Popup/extensions_state.json" ]]; then
        cat ~/.config/Popup/extensions_state.json
    else
        echo "No extensions installed."
    fi
    # Also you can format the output in a more user-friendly way, such as using a table or adding colors for better readability
    # Example of formatted output:
    echo "Extension Name | Version | Source"
    for extension in /path/to/extensions/*; do
        name=$(basename "$extension")
        version=$(cat "$extension/version.txt" 2>/dev/null || echo "N/A")
        source=$(cat "$extension/source.txt" 2>/dev/null || echo "N/A")
        printf "%-15s | %-7s | %-20s\n" "$name" "$version" "$source"
    done

    # One more thing to consider is to handle the case when there are no extensions installed, and provide a message to the user indicating that there are no extensions to list.
     if [ -z "$(ls -A /path/to/extensions/)" ]; then
        echo "No extensions installed."
    fi
    
    # Also it's nice to list github repository extensions separately from local file extensions, to make it easier for users to identify the source of each extension. You can achieve this by categorizing the extensions based on their source and displaying them in separate sections.
     echo "GitHub Extensions:"
    for extension in /path/to/extensions/*; do
        if [[ -d "$extension/.git" ]]; then
            name=$(basename "$extension")
            version=$(cat "$extension/version.txt" 2>/dev/null || echo "N/A")
            source=$(cat "$extension/source.txt" 2>/dev/null || echo "N/A")
            printf "%-15s | %-7s | %-20s\n" "$name" "$version" "$source"
        fi
    done
    echo "Local File Extensions:"
    for extension in /path/to/extensions/*; do
        if [[ ! -d "$extension/.git" ]]; then
            name=$(basename "$extension")
            version=$(cat "$extension/version.txt" 2>/dev/null || echo "N/A")
            source=$(cat "$extension/source.txt" 2>/dev/null || echo "N/A")
            printf "%-15s | %-7s | %-20s\n" "$name" "$version" "$source"
        fi
    done

    # With this implementation, users will have a clear overview of their installed extensions,
    # including their names, versions, and sources, making it easier to manage and maintain their extensions effectively. 
    # Also it's possible to list github repository extensions in a nice way such that users can install them directly from the github repositories,
    # The installed extensions will be listed with their names, versions, and sources, making it easier for users to identify and manage their extensions effectively.
}
```

## 4. Parse Command-Line Arguments
Use a command-line argument parser to handle user input and call the appropriate command handlers. For example:

```bash
case "$1" in
    install)
        install_extension "$2"
        ;;
    update)
        update_extension "$2"
        ;;
    remove)
        remove_extension "$2"
        ;;
    list)
        list_extensions
        ;;
    *)
        echo "Usage: $0 {install|update|remove|list} [extension_name]"
        exit 1
esac
```

NOTE: The above code snippet is a simple example of how to parse command-line arguments in a Bash script. They are NOT complete and may contain erros.
 You should enhance this by adding support for additional options, such as specifying the source of the extension (e.g., GitHub URL or local file path) or allowing users to provide multiple extensions at once.

## 5. Handle Errors and Edge Cases

Make sure to handle errors gracefully, such as when an extension is not found or when there are issues during installation. Provide informative error messages to the user.

## 6. Test Your Tool

Thoroughly test your command-line tool to ensure that all commands work as expected and that error handling is effective. Consider writing unit tests for your command handlers.

## 7. Documentation

Provide clear documentation for your tool, including usage instructions and examples. This will help users understand how to use the tool effectively.


## 8. Additional Features

You should consider features such as:

- Support for multiple extension sources (e.g., local files, remote repositories).
- Version management for extensions.

Refer to the following resources for more information and examples on developing command-line tools for extension management:
- [Fundle - A Fish Shell Plugin Manager](
https://raw.githubusercontent.com/danhper/fundle/refs/heads/master/functions/fundle.fish)
NOTE: The above link is an example of a command-line tool for managing extensions in the Fish shell. You can use it as a reference for your own tool development. In your case, you will use Bash instead of Fish, so make sure to adapt the code accordingly.

