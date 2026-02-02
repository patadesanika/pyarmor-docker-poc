FROM python:3.11-alpine

# Copy obfuscated application
COPY dist/ /app/

# Set working directory
WORKDIR /app

# Run the obfuscated application
CMD ["python", "hello.py"]