#!/bin/bash

# Check for dependencies
command -v jq >/dev/null 2>&1 || { echo "jq is required but not installed. Aborting."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "curl is required but not installed. Aborting."; exit 1; }
command -v rpmbuild >/dev/null 2>&1 || { echo "rpmbuild is required but not installed. Aborting."; exit 1; }

# Function to display usage
usage() {
    echo "Usage: $0 [-j json_file] | [-n name -v version -d description -l tar_link]"
    exit 1
}

# Parse command line options
while getopts ":j:n:v:d:l:" opt; do
    case $opt in
        j) json_file=$OPTARG ;;
        n) package_name=$OPTARG ;;
        v) version=$OPTARG ;;
        d) description=$OPTARG ;;
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
    tar_link=$(jq -r '.tar_link' "$json_file")
fi

# Check if all required variables are set
if [ -z "$package_name" ] || [ -z "$version" ] || [ -z "$description" ] || [ -z "$tar_link" ]; then
    echo "Missing required inputs."
    usage
fi

# Download the tar file to a temporary location
temp_dir=$(mktemp -d)
tar_file="$temp_dir/$(basename "$tar_link")"
curl -L -o "$tar_file" "$tar_link" || { echo "Failed to download tar file."; exit 1; }

NAME=$(echo "$tar_link" | sed 's|.*/\(.*\)/archive/.*|\1|')
VERSION=$(echo "$tar_link" | sed 's|.*/refs/tags/\(.*\)\.tar\.gz|\1|')
SOURCE="${VERSION}.tar.gz"

# Set up rpmbuild environment
RPMBUILD_DIR="$temp_dir/rpmbuild"
mkdir -p "$RPMBUILD_DIR"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cp "$tar_file" "$RPMBUILD_DIR/SOURCES/"

# Generate spec file from template
SPEC_TEMPLATE="/app/spec.template"
SPEC_FILE="$RPMBUILD_DIR/SPECS/$package_name.spec"

# Escape special characters
description_escaped=$(printf '%s\n' "$description" | sed 's/[\/& \n]/\\&/g')
tar_basename=$(basename "$tar_link")

# Generate and verify spec file
sed -e "s/{{PACKAGE_NAME}}/$NAME/g" \
    -e "s/{{VERSION}}/$VERSION/g" \
    -e "s/{{DESCRIPTION}}/$description_escaped/g" \
    -e "s|{{TAR_LINK}}|$tar_basename|g" \
    -e "s|{{SOURCE_TAR}}|$SOURCE|g" \
    "$SPEC_TEMPLATE" > "$SPEC_FILE"
if [ ! -s "$SPEC_FILE" ]; then
    echo "Error: Generated spec file is empty or missing."
    exit 1
fi
echo "Generated spec file contents:" >&2
cat "$SPEC_FILE" >&2

# Build the RPM
rpmbuild --define "_topdir $RPMBUILD_DIR" -ba "$SPEC_FILE" || { echo "Failed to create RPM."; exit 1; }

# Copy the RPM to /output
rpm_file="/output/$NAME-$VERSION.rpm"
find "$RPMBUILD_DIR/RPMS" -name "$NAME-$VERSION*.rpm" -exec cp {} "$rpm_file" \;
if [ -f "$rpm_file" ]; then
    echo "RPM created successfully at $rpm_file"
else
    echo "Error: RPM not found at $rpm_file"
    exit 1
fi

# Clean up
rm -rf "$temp_dir"