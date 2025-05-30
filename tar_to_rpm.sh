#!/bin/bash

# Check for dependencies
command -v jq >/dev/null 2>&1 || { echo "jq is required but not installed. Aborting."; exit 1; }
command -v fpm >/dev/null 2>&1 || { echo "fpm is required but not installed. Aborting."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl is required but not installed. Aborting."; exit 1; }
command -v rpmbuild >/dev/null 2>&1 || { echo "rpmbuild is required but not installed. Aborting."; exit 1; }

# Function to display usage
usage() {
    echo "Usage: $0 [-j json_file] | [-n name -v version -d description -p path -l tar_link]"
    exit 1
}

# Parse command line options
while getopts ":j:n:v:d:p:l:" opt; do
    case $opt in
        j) json_file=$OPTARG ;;
        n) package_name=$OPTARG ;;
        v) version=$OPTARG ;;
        d) description=$OPTARG ;;
        p) path=$OPTARG ;;
        l) tar_link=$OPTARG ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
        :) echo "Option -$OPTARG requires an argument." >&2; usage ;;
    esac
done

# If json_file is provided, read from it
if [ -n "$json_file" ]; then
    package_name=$(jq -r '.package_name' "$json_file")
    version=$(jq -r '.version' "$json_file")
    description=$(jq -r '.description' "$json_file")
    path=$(jq -r '.path' "$json_file")
    tar_link=$(jq -r '.tar_link' "$json_file")
fi

# Check if all required variables are set
if [ -z "$package_name" ] || [ -z "$version" ] || [ -z "$description" ] || [ -z "$path" ] || [ -z "$tar_link" ]; then
    echo "Missing required inputs."
    usage
fi

# Download the tar file to a temporary location
temp_dir=$(mktemp -d)
tar_file="$temp_dir/$(basename "$tar_link")"
curl -o "$tar_file" "$tar_link" || { echo "Failed to download tar file."; exit 1; }

# Create the RPM using fpm
rpm_file="$path/$package_name-$version.rpm"
fpm -s tar -t rpm -n "$package_name" -v "$version" --description "$description" --prefix "/" -p "$rpm_file" "$tar_file" || { echo "Failed to create RPM."; exit 1; }

# Clean up
rm -rf "$temp_dir"

echo "RPM created successfully at $rpm_file"
