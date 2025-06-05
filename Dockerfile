# Use CentOS Stream as base image
FROM quay.io/centos/centos:stream9

# Install required dependencies
RUN dnf update -y && \
    dnf install -y \
    dos2unix \
    jq \
    rpm-build \
    rpm-devel \
    rpmlint \
    make \
    python \
    bash \
    diffutils \
    patch \
    rpmdevtools \
    && dnf clean all

# Create working directory
WORKDIR /app

# Copy the script, JSON file, and spec template
COPY bash/tar_to_rpm.sh /app/tar_to_rpm.sh
COPY ./input.json /app/input.json
COPY bash/spec.template /app/spec.template

# Fix line endings
RUN dos2unix /app/tar_to_rpm.sh /app/spec.template

# Set permissions
RUN chmod +x /app/tar_to_rpm.sh && \
    chmod 644 /app/input.json /app/spec.template

# Create output directory
RUN mkdir -p /output && chmod 777 /output

# # Set the entrypoint to the script
ENTRYPOINT ["/app/tar_to_rpm.sh"]

# # Default command (can be overridden)
CMD ["-j", "/app/input.json"]

# /app/tar_to_rpm.sh -j /app/input.json