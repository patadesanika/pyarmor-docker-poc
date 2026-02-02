FROM docker:24-dind

# Install Python 3 and pip
RUN apk add --no-cache python3 py3-pip

# Install PyArmor
RUN pip3 install pyarmor

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/sh"]