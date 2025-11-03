#!/bin/bash

set -e

echo "=========================================="
echo "Clean Deploy - Flask K8s App"
echo "=========================================="

# Use Minikube's Docker
eval $(minikube docker-env)

# Clean up everything first
echo ""
echo "Cleaning up old resources..."
kubectl delete deployment flask-app --ignore-not-found=true
kubectl delete service flask-app-service --ignore-not-found=true

# Wait for cleanup
sleep 5

# Build fresh image
echo ""
echo "Building Docker image..."
docker build -t flask-k8s-cicd:latest .

# Verify image exists
docker images | grep flask-k8s-cicd

# Create deployment
echo ""
echo "Creating deployment..."
cat > /tmp/deployment-simple.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
  labels:
    app: flask-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-app
        image: flask-k8s-cicd:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 5000
        env:
        - name: ENVIRONMENT
          value: "local"
        - name: APP_VERSION
          value: "1.0.0"
        - name: PORT
          value: "5000"
EOF

kubectl apply -f /tmp/deployment-simple.yaml
kubectl apply -f k8s/service.yaml

# Wait and check
echo ""
echo "Waiting for pod to start..."
sleep 10

echo ""
echo "Pod status:"
kubectl get pods -l app=flask-app

echo ""
echo "Checking logs:"
kubectl logs -l app=flask-app --tail=20 || echo "Pod not ready yet"

echo ""
echo "Waiting for pod to be ready (this may take a minute)..."
kubectl wait --for=condition=ready pod -l app=flask-app --timeout=60s || {
    echo ""
    echo "Pod not ready. Checking details..."
    kubectl describe pod -l app=flask-app
    kubectl logs -l app=flask-app
    exit 1
}

echo ""
echo "=========================================="
echo "✅ Success!"
echo "=========================================="

URL=$(minikube service flask-app-service --url)
echo ""
echo "Service URL: $URL"
echo ""
echo "Test with:"
echo "  curl $URL/health"
echo "  curl $URL/api/tasks"
