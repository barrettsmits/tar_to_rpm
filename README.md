# Tar to RPM Converter

This script converts tar archives to RPM packages using rpmbuild. It provides a convenient way to create RPM packages from tar files, either through command-line arguments or a JSON configuration file.

## Prerequisites

The following tools must be installed on your system:
- `jq` - For JSON processing
- `curl` - For downloading tar files
- `rpmbuild` - For RPM package building
- `dos2unix` - For handling line endings
- `rpmlint` - For RPM linting
- `rpmdevtools` - For RPM development tools

## Installation

### Option 1: Manual Installation

1. Ensure you have all the required dependencies installed:

```bash
# For RHEL/CentOS/Fedora
sudo dnf install jq curl rpm-build rpm-devel rpmlint make python bash diffutils patch rpmdevtools dos2unix

# For Ubuntu/Debian
sudo apt-get install jq curl rpm rpm-build rpmlint make python3 bash diffutils patch rpmdevtools dos2unix
```

2. Make the script executable:
```bash
chmod +x tar_to_rpm.sh
```

### Option 2: Using Docker

1. Build the Docker image:
```bash
docker build -t tar-to-rpm .
```

2. Run the container:
```bash
# Using command line arguments
docker run -v /path/to/output:/output tar-to-rpm -n <package_name> -v <version> -d <description> -l <tar_file_url>

# Using JSON configuration
docker run -v /path/to/output:/output -v /path/to/input.json:/app/input.json tar-to-rpm

# OR
docker run -t -v $pwd/output:/output tar-to-rpm
```

Note: Replace `/path/to/output` with the directory where you want to store the generated RPM files.

## Usage

The script can be used in two ways:

### 1. Using Command Line Arguments

```bash
./tar_to_rpm.sh -n <package_name> -v <version> -d <description> -l <tar_file_url>
```

### 2. Using JSON Configuration File

```bash
./tar_to_rpm.sh -j <json_file>
```

### Parameters

- `-n`: Package name
- `-v`: Version number
- `-d`: Package description
- `-l`: URL or path to the tar file
- `-j`: Path to JSON configuration file

### JSON Configuration Format

```json
{
    "package_name": "example-package",
    "version": "1.0.0",
    "description": "Example package description",
    "tar_link": "https://example.com/package.tar.gz"
}
```

## Example

1. Using command line arguments:
```bash
./tar_to_rpm.sh -n myapp -v 1.0.0 -d "My Application" -l https://example.com/myapp.tar.gz
```

2. Using JSON configuration:
```bash
./tar_to_rpm.sh -j input.json
```

## Output

The script will create an RPM package in the `/output` directory with the following naming convention:
```
<package_name>-<version>.rpm
```

## Package Structure

The generated RPM package will:
1. Extract the tar archive
2. Install the contents to `/usr/local/<package_name>/`
3. Include all files from the tar archive in the package

## Error Handling

The script includes error handling for:
- Missing dependencies
- Invalid command line options
- Failed tar file downloads
- Failed RPM creation
- Missing required parameters
- Empty or invalid spec file generation

## Cleanup

The script automatically cleans up temporary files after successful RPM creation.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 
