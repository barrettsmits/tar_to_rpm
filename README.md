# Tar to RPM Converter

This script converts tar archives to RPM packages using FPM (Effing Package Management). It provides a convenient way to create RPM packages from tar files, either through command-line arguments or a JSON configuration file.

## Prerequisites

The following tools must be installed on your system:
- `jq` - For JSON processing
- `fpm` - For package creation
- `curl` - For downloading tar files
- `rpmbuild` - For RPM package building

## Installation

1. Ensure you have all the required dependencies installed:

```bash
# For RHEL/CentOS/Fedora
sudo yum install jq curl rpm-build

# For Ubuntu/Debian
sudo apt-get install jq curl rpm

# Install Ruby (required for FPM)
# For RHEL/CentOS/Fedora
sudo yum install ruby ruby-devel

# For Ubuntu/Debian
sudo apt-get install ruby ruby-dev

# Install FPM
sudo gem install fpm
```

2. Make the script executable:
```bash
chmod +x tar_rpm.sh
```

## Usage

The script can be used in two ways:

### 1. Using Command Line Arguments

```bash
./tar_rpm.sh -n <package_name> -v <version> -d <description> -p <output_path> -l <tar_file_url>
```

### 2. Using JSON Configuration File

```bash
./tar_rpm.sh -j <json_file>
```

### Parameters

- `-n`: Package name
- `-v`: Version number
- `-d`: Package description
- `-p`: Output path for the RPM file
- `-l`: URL or path to the tar file
- `-j`: Path to JSON configuration file

### JSON Configuration Format

```json
{
    "package_name": "example-package",
    "version": "1.0.0",
    "description": "Example package description",
    "path": "/path/to/output",
    "tar_link": "https://example.com/package.tar.gz"
}
```

## Example

1. Using command line arguments:
```bash
./tar_rpm.sh -n myapp -v 1.0.0 -d "My Application" -p /tmp -l https://example.com/myapp.tar.gz
```

2. Using JSON configuration:
```bash
./tar_rpm.sh -j config.json
```
## Output

The script will create an RPM package in the specified output path with the following naming convention:
```
<package_name>-<version>.rpm
```

## Error Handling

The script includes error handling for:
- Missing dependencies
- Invalid command line options
- Failed tar file downloads
- Failed RPM creation
- Missing required parameters

## Cleanup

The script automatically cleans up temporary files after successful RPM creation. 
