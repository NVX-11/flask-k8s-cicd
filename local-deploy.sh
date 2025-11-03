#!/bin/bash

# Local deployment script for Minikube
set -e

echo "=========================================="
echo "Local Deployment to Minikube"
echo "=========================================="

# Check Minikube
if ! minikube status &> /dev/null; then
    echo "❌ Minikube is not running"
    echo "Start it with: minikube start --driver=docker"
    exit 1
fi

echo "✓ Minikube is running"

# Build image locally
echo ""
echo "Building Docker image..."
eval $(minikube docker-env)
docker build -t flask-k8s-cicd:latest .
echo "✓ Image built successfully"

# Update deployment to use local image
echo ""
echo "Creating local deployment config..."
cat > k8s/deployment-local.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
  labels:
    app: flask-app
spec:
  replicas: 2
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
          value: "1.0.0-local"
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 5
EOF

# Deploy
echo ""
echo "Deploying to Kubernetes..."
kubectl apply -f k8s/deployment-local.yaml
kubectl apply -f k8s/service.yaml

# Wait for deployment
echo ""
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=flask-app --timeout=120s

echo ""
echo "=========================================="
echo "✅ Deployment Successful!"
echo "=========================================="

# Get service URL
URL=$(minikube service flask-app-service --url)
echo ""
echo "🌐 Application URL: $URL"
echo ""
echo "Test the API:"
echo "  curl $URL/"
echo "  curl $URL/health"
echo "  curl $URL/api/tasks"
echo ""
echo "View pods:"
echo "  kubectl get pods -l app=flask-app"
echo ""
echo "View logs:"
echo "  kubectl logs -l app=flask-app --tail=50"
