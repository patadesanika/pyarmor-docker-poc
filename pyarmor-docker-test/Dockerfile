FROM python:3.12-slim

WORKDIR /app

# Install network tools for debugging
RUN apt-get update && apt-get install -y \
    curl \
    iputils-ping \
    dnsutils \
    && rm -rf /var/lib/apt/lists/*

# Install Pyarmor
RUN pip install --no-cache-dir pyarmor==9.2.3

# Copy CI registration file
COPY pyarmor-ci-8153.zip /app/

# Copy test script
COPY test.py /app/

# Register Pyarmor with CI license
RUN pyarmor reg pyarmor-ci-8153.zip && \
    echo "License registered successfully" && \
    pyarmor -v

CMD ["/bin/bash"]