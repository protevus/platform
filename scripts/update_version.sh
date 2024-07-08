#!/bin/bash

# Function to update version in pubspec.yaml
update_version() {
    local directory=$1
    local new_version=$2

    pubspec_file="$directory/pubspec.yaml"
    
    if [[ -f $pubspec_file ]]; then
        echo "Updating version in $pubspec_file to $new_version"
        sed -i.bak -E "s/^version: .*/version: $new_version/" $pubspec_file
        if [[ $? -eq 0 ]]; then
            echo "Version updated successfully in $directory"
        else
            echo "Failed to update version in $directory"
        fi
    else
        echo "pubspec.yaml not found in $directory"
    fi
}

# Main script logic
main() {
    local target_dir=$1
    local new_version=$2

    if [[ -z $target_dir || -z $new_version ]]; then
        echo "Usage: $0 <target_directory_or_all> <new_version>"
        exit 1
    fi

    packages_dir="packages"

    if [[ $target_dir == "all" ]]; then
        for dir in $packages_dir/*/; do
            update_version "$dir" "$new_version"
        done
    else
        update_version "$packages_dir/$target_dir" "$new_version"
    fi
}

# Call the main function with provided arguments
main "$@"
