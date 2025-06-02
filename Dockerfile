# Use CentOS Stream as base image since it's commonly used for RPM builds
FROM quay.io/centos/centos:stream9

# Install required dependencies (curl already installed)
RUN dnf update -y && \
    dnf install -y \
    jq \
    rpm-build \
    ruby \
    ruby-devel \
    && dnf clean all

# Install FPM
RUN gem install fpm

# Create working directory
WORKDIR /app

# Copy the script and any other necessary files
COPY bash/tar_to_rpm.sh /app/tar_to_rpm.sh 
COPY ./input.json /app/input.json

RUN chmod +x /app/tar_to_rpm.sh && \
    chmod 644 /app/input.json

# Create a directory for output RPMs
RUN mkdir -p /output && chmod 777 /output

# Set the entrypoint to the script
ENTRYPOINT ["/app/tar_to_rpm.sh"]

# Default command (can be overridden)
#CMD ["/app/tar_to_rpm.sh","-j", "/app/input.json"]
CMD ["-j", "/app/input.json"]