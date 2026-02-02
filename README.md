# PyArmor Kubernetes PoC

Minimal Proof-of-Concept for obfuscating Python applications using PyArmor inside a Kubernetes pod.

## ⚠️ Security Warning

This is a PoC implementation with the following security compromises:
- Uses privileged containers
- Mounts Docker socket directly
- Uses hostPath volumes
- **DO NOT USE IN PRODUCTION**

## Prerequisites

- EC2 instance with Ubuntu 20.04+
- PyArmor license files

## Step-by-Step Setup

### 1. Install k3s on EC2

```bash
# Install k3s
curl -sfL https://get.k3s.io | sh -

# Add kubectl alias
echo 'alias kubectl="sudo k3s kubectl"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
kubectl get nodes
```

### 2. Prepare Directories

```bash
# Create required directories
sudo mkdir -p /data/input /data/output
sudo chmod 777 /data/input /data/output
```

### 3. Build PyArmor Builder Image

```bash
# Build the PyArmor builder image
sudo docker build -t pyarmor-builder:latest -f pyarmor/Dockerfile.builder .
```

### 4. Create PyArmor License Secret

```bash
# Copy your PyArmor license files to a temporary directory
mkdir -p /tmp/pyarmor-license
# Copy your license files here (license.lic, etc.)

# Create Kubernetes secret
kubectl create secret generic pyarmor-license \
  --from-file=/tmp/pyarmor-license/

# Clean up
rm -rf /tmp/pyarmor-license
```

### 5. Deploy PyArmor Pod

```bash
# Deploy the pod
kubectl apply -f pyarmor/pyarmor-pod.yaml

# Wait for pod to be ready
kubectl wait --for=condition=Ready pod/pyarmor-builder --timeout=60s

# Verify pod is running
kubectl get pods
```

### 6. Obfuscate the Application

```bash
# Copy source code to input directory
sudo cp app/hello.py /data/input/

# Execute obfuscation inside the pod
kubectl exec -it pyarmor-builder -- sh -c "
  cd /input && \
  pyarmor gen hello.py && \
  cp -r dist /output/
"

# Verify obfuscated files
ls -la /data/output/dist/
```

### 7. Build Final Docker Image

```bash
# Copy obfuscated files to docker context
sudo cp -r /data/output/dist ./

# Build the application image
sudo docker build -t hello-obfuscated:latest -f docker/Dockerfile.app .

# Clean up
sudo rm -rf dist
```

### 8. Run the Obfuscated Application

```bash
# Run the obfuscated application
sudo docker run --rm hello-obfuscated:latest
```

Expected output:
```
Hello from PyArmor obfuscated application!
This is a minimal PoC demonstrating PyArmor in Kubernetes
```

## Cleanup

```bash
# Delete the pod
kubectl delete -f pyarmor/pyarmor-pod.yaml

# Delete the secret
kubectl delete secret pyarmor-license

# Clean up directories
sudo rm -rf /data/input /data/output

# Remove Docker images
sudo docker rmi pyarmor-builder:latest hello-obfuscated:latest
```

## Project Structure

```
pyarmor-poc/
├── app/
│   └── hello.py              # Source Python application
├── docker/
│   └── Dockerfile.app        # Runtime image for obfuscated app
├── pyarmor/
│   ├── Dockerfile.builder    # PyArmor builder with Docker support
│   └── pyarmor-pod.yaml      # Kubernetes Pod manifest
└── README.md                 # This file
```

## Troubleshooting

### Pod not starting
```bash
kubectl describe pod pyarmor-builder
kubectl logs pyarmor-builder
```

### Docker socket issues
```bash
# Verify Docker socket permissions
ls -la /var/run/docker.sock
```

### PyArmor license issues
```bash
# Check secret contents
kubectl describe secret pyarmor-license

# Verify license in pod
kubectl exec -it pyarmor-builder -- ls -la /root/.pyarmor
```