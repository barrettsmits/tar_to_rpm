# Use Fedora as the base image
FROM fedora:latest

# Install tools needed to build RPMs
RUN dnf install -y rpm-build gcc make

# Set a working directory
WORKDIR /build

# Copy the source tarball and spec file into the container
COPY myapp.tar.gz /build/
COPY myapp.spec /build/

# Build the RPM using the spec file
RUN rpmbuild -ba myapp.spec

# The RPM will be located in /root/rpmbuild/RPMS/<arch>/