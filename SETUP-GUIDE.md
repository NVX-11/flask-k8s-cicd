# Complete Setup Guide

## 🎯 Step-by-Step Instructions

### Part 1: Local Testing (15 minutes)

**Step 1: Verify Prerequisites**
```bash
# Check Docker
docker --version

# Check Minikube
minikube version

# Check kubectl
kubectl version --client
```

**Step 2: Start Minikube**
```bash
minikube start --driver=docker
minikube status
```

**Step 3: Deploy Locally**
```bash
cd ~/flask-k8s-cicd
./local-deploy.sh
```

**Step 4: Test the Application**
```bash
# Get URL
URL=$(minikube service flask-app-service --url)

# Test endpoints
curl $URL/
curl $URL/health
curl $URL/api/tasks
curl $URL/api/info
```

**Expected Output:**
- All pods should be "Running"
- Health check returns `{"status": "healthy"}`
- Tasks endpoint returns list of tasks

---

### Part 2: Setup CI/CD Pipeline (20 minutes)

**Step 1: Create GitHub Repository**
1. Go to [github.com](https://github.com)
2. Click "New Repository"
3. Name: `flask-k8s-cicd`
4. Make it public
5. Don't initialize with README (we have one)

**Step 2: Create DockerHub Account**
1. Go to [hub.docker.com](https://hub.docker.com)
2. Sign up (free tier)
3. Remember your username

**Step 3: Get DockerHub Access Token**
1. Log into DockerHub
2. Go to Account Settings → Security
3. Click "New Access Token"
4. Name it "github-actions"
5. Copy the token (you'll only see it once!)

**Step 4: Update Docker Image Name**
```bash
cd ~/flask-k8s-cicd

# Replace YOUR_DOCKERHUB_USERNAME with your actual username
sed -i 's/YOUR_DOCKERHUB_USERNAME/your-actual-username/g' k8s/deployment.yaml
```

**Step 5: Add GitHub Secrets**
1. Go to your GitHub repo
2. Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add two secrets:
   - Name: `DOCKERHUB_USERNAME`, Value: your DockerHub username
   - Name: `DOCKERHUB_TOKEN`, Value: your access token from Step 3

**Step 6: Push to GitHub**
```bash
cd ~/flask-k8s-cicd

# Initialize git
git init
git add .
git commit -m "Initial commit: Flask K8s CI/CD project

- REST API with task management
- Docker multi-stage build
- Kubernetes deployment with 3 replicas
- GitHub Actions CI/CD pipeline
- Health checks and resource limits"

# Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/flask-k8s-cicd.git

# Push
git branch -M main
git push -u origin main
```

**Step 7: Watch CI/CD in Action**
1. Go to your GitHub repo
2. Click "Actions" tab
3. You should see the workflow running!
4. Click on it to see real-time progress
5. After ~3-5 minutes, check DockerHub - your image should be there!

---

### Part 3: Verify Everything Works

**Check GitHub Actions:**
- ✅ Build & Test job passed
- ✅ Build & Push job completed
- ✅ Image is on DockerHub

**Check DockerHub:**
```bash
# Pull your image
docker pull YOUR_USERNAME/flask-k8s-cicd:latest

# Verify it exists
docker images | grep flask-k8s-cicd
```

**Deploy the CI/CD Built Image:**
```bash
# Update deployment to use DockerHub image
kubectl set image deployment/flask-app \
  flask-app=YOUR_USERNAME/flask-k8s-cicd:latest

# Watch rollout
kubectl rollout status deployment/flask-app

# Verify
kubectl get pods -l app=flask-app
```

---

## 🎉 Success Criteria

You should now have:

✅ **Local Deployment Working**
- 2-3 pods running in Minikube
- API accessible via NodePort
- Health checks passing

✅ **CI/CD Pipeline Working**
- GitHub Actions workflow passing
- Docker image on DockerHub
- Automatic builds on push

✅ **Project on GitHub**
- Code repository with README
- CI/CD badge (optional)
- Professional documentation

---

## 🚀 Demo Your Project

**For Interviews:**

1. **Show the GitHub Repo**
   - Point out the workflow file
   - Show successful CI/CD runs
   - Explain the pipeline stages

2. **Show DockerHub**
   - Your published images
   - Different tags (latest, commit SHAs)

3. **Live Demo**
   ```bash
   # Show pods running
   kubectl get pods -l app=flask-app

   # Show live API
   curl $(minikube service flask-app-service --url)/api/info

   # Show logs
   kubectl logs -l app=flask-app --tail=20

   # Demo scaling
   kubectl scale deployment/flask-app --replicas=5
   kubectl get pods -w
   ```

4. **Explain Architecture**
   - Multi-stage Docker builds for optimization
   - Kubernetes deployments for scalability
   - Health probes for reliability
   - CI/CD for automation

---

## 🔧 Troubleshooting

### Issue: GitHub Actions Failing

**Check:**
- DockerHub secrets are correct
- Image name matches your username
- Token has push permissions

### Issue: Pods CrashLoopBackOff

**Solution:**
```bash
# Check logs
kubectl logs -l app=flask-app

# Common fixes:
# 1. Rebuild image: ./local-deploy.sh
# 2. Check health endpoint works
# 3. Verify dependencies in requirements.txt
```

### Issue: Can't Access Service

**Solution:**
```bash
# For Minikube
minikube service flask-app-service --url

# Or port-forward
kubectl port-forward service/flask-app-service 8080:80
# Then access: http://localhost:8080
```

---

## 📸 Screenshots to Take

For your portfolio/resume:

1. **GitHub Actions Success**
   - Green checkmarks on workflow
   - Build & deploy stages completed

2. **DockerHub Repository**
   - Your published image
   - Multiple tags

3. **Kubernetes Dashboard**
   ```bash
   minikube dashboard
   ```
   - Running pods
   - Service endpoints

4. **API Response**
   ```bash
   curl $(minikube service flask-app-service --url)/api/info | jq
   ```

---

## 🎓 Interview Talking Points

**Technical Decisions:**
- "Used multi-stage Docker builds to reduce image size from 1GB to 200MB"
- "Implemented health probes to enable automatic pod recovery"
- "Set resource limits to prevent resource starvation in shared clusters"
- "Used GitHub Actions for CI/CD to automate the entire deployment pipeline"

**Impact:**
- "Reduced deployment time from 30 minutes (manual) to 2 minutes (automated)"
- "Enabled zero-downtime deployments through rolling updates"
- "Improved system reliability with automatic health checks and pod recovery"

**Learning:**
- "Learned importance of container optimization for faster deployments"
- "Understood Kubernetes networking and service discovery"
- "Gained hands-on experience with production-grade CI/CD practices"

---

## ✅ Checklist

Before saying "project complete":

- [ ] Minikube running
- [ ] Application deployed locally
- [ ] All pods in "Running" state
- [ ] API endpoints responding
- [ ] GitHub repo created and pushed
- [ ] CI/CD pipeline passing
- [ ] Docker image on DockerHub
- [ ] README documentation complete
- [ ] Can demo the project live

---

**🎉 Congratulations! You now have a production-grade DevOps project!**
