#!/bin/bash

# Array of extensions to uninstall
extensions=(
    "nash.awesome-flutter-snippets"               # Dart Data Class Generator
    "robert-brunhage.flutter-riverpod-snippets"   # Flutter Riverpod Snippets
    "usernamehw.errorlens"                        # Error Lens
    "aaron-bond.better-comments"                  # Better Comments
    "styfle.remove-comments"                      # Remove Comments
    "patbenatar.advanced-new-file"                # Advanced New File
    "GitHub.copilot"                              # GitHub Copilot
    "dracula-theme.theme-dracula"                 # Dracula Theme (optional)
    "firebase.vscode-firebase-explorer"           # Firebase Explorer
    "pflannery.vscode-versionlens"                # Version Lens
    "tgsup.find-unused-dart-files-and-assets"     # Find Unused Dart Files & Assets
    "humao.rest-client"                           # REST Client
    "rangav.vscode-thunder-client"                # Thunder Client
    "ritwickdey.liveserver"                       # Live Server
    "Dart-Code.dart-code"                         # Dart SDK
    "Dart-Code.flutter"                           # Flutter SDK
    "ms-vscode.cpptools"                          # C/C++
    "ms-vscode.cpptools-extension-pack"           # C/C++ Extension Pack
    "ms-vscode.cpptools-themes"                   # C/C++ Themes
    "twxs.cmake "                                 # CMake
    "ms-vscode.cmake-tools"                       # CMake Tools
    "ms-vscode.makefile-tools"                    # Makefile Tools
    "saoudrizwan.claude-dev"                      # Claude Dev
    "Continue.continue"                           # Continue
    "DEVSENSE.phptools-vscode"                    # PHP Tools
    "DEVSENSE.composer-php-vscode"                # Composer PHP
    "DEVSENSE.profiler-php-vscode"                # Profiler PHP
    "ms-vscode.remote-explorer"                   # Remote - Containers
    "ms-vscode-remote.remote-ssh"                 # Remote - SSH
    "ms-vscode-remote.remote-ssh-edit"            # Remote - SSH: Edit
    "ms-vscode-remote.remote-containers"          # Remote - Containers
    "eamodio.gitlens"                             # GitLens
    "DEVSENSE.intelli-php-vscode"                 # IntelliPHP
    "blaugold.melos-code"                         # Melos
    "vscode-icons-team.vscode-icons"              # VSCode Icons
    "redhat.vscode-yaml"                          # YAML
    "GitHub.vscode-github-actions"                # GitHub Actions
    "ms-azuretools.vscode-docker"                 # Docker
    "ms-kubernetes-tools.vscode-kubernetes-tools" # Kubernetes
)

# Uninstall each extension
echo "Uninstalling VSCode extensions..."
for extension in "${extensions[@]}"; do
    code --uninstall-extension "$extension"
    echo "Uninstalled: $extension"
done

echo "All specified extensions have been uninstalled successfully."
