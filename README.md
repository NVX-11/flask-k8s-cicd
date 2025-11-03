# Flask Task Manager with CI/CD Pipeline

Production-ready REST API demonstrating Docker, Kubernetes, and automated CI/CD workflows.

[![CI/CD Pipeline](https://github.com/NVX-11/flask-k8s-cicd/workflows/CI/CD%20Pipeline/badge.svg)](https://github.com/NVX-11/flask-k8s-cicd/actions)

## Tech Stack

- **Backend:** Python 3.11 + Flask + Gunicorn
- **Containerization:** Docker (multi-stage builds)
- **Orchestration:** Kubernetes
- **CI/CD:** GitHub Actions
- **Registry:** DockerHub

## Features

- REST API with CRUD operations
- Docker multi-stage builds with non-root containers
- Kubernetes deployment with 3 replicas
- Health checks (liveness & readiness probes)
- Resource limits (CPU & memory management)
- Automated CI/CD pipeline
- Zero-downtime rolling updates

## Quick Start

### Local Deployment

```bash
# Clone repository
git clone https://github.com/NVX-11/flask-k8s-cicd.git
cd flask-k8s-cicd

# Start Minikube
minikube start --driver=docker

# Deploy
./fix-and-deploy.sh

# Get service URL
minikube service flask-app-service --url
```

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | API info |
| GET | `/health` | Health check |
| GET | `/api/tasks` | List all tasks |
| GET | `/api/tasks/{id}` | Get task by ID |
| POST | `/api/tasks` | Create task |
| PUT | `/api/tasks/{id}` | Update task |
| DELETE | `/api/tasks/{id}` | Delete task |

## CI/CD Pipeline

The GitHub Actions workflow automatically:
1. Runs tests and linting
2. Builds Docker image
3. Pushes to DockerHub (`dc0c/flask-k8s-cicd`)
4. Triggers on push to `main` branch

### Setup CI/CD

1. Create DockerHub account
2. Add GitHub secrets:
   - `DOCKERHUB_USERNAME`: Your DockerHub username
   - `DOCKERHUB_TOKEN`: Your access token
3. Push to GitHub - pipeline runs automatically

## Architecture

```
GitHub Push → CI/CD Pipeline → Docker Build → DockerHub → Kubernetes (3 replicas)
```

## Project Structure

```
flask-k8s-cicd/
├── app/
│   ├── app.py              # Flask application
│   └── requirements.txt    # Python dependencies
├── k8s/
│   ├── deployment.yaml     # Kubernetes deployment
│   └── service.yaml        # Kubernetes service
├── .github/workflows/
│   └── ci-cd.yaml         # CI/CD pipeline
├── Dockerfile             # Multi-stage Docker build
└── fix-and-deploy.sh     # Local deployment script
```

## Kubernetes Configuration

- **Replicas:** 3 (high availability)
- **CPU:** 100m request, 200m limit
- **Memory:** 128Mi request, 256Mi limit
- **Health Probes:** Liveness & readiness checks every 5-10s
- **Service Type:** NodePort (port 30081)

## Useful Commands

```bash
# View pods
kubectl get pods -l app=flask-app

# View logs
kubectl logs -l app=flask-app --tail=50

# Scale deployment
kubectl scale deployment/flask-app --replicas=5

# Rolling update
kubectl rollout restart deployment/flask-app
```

## Resume Highlights

- Implemented automated CI/CD pipeline reducing deployment time from 30 minutes to 2 minutes
- Deployed containerized application to Kubernetes with high availability (3 replicas)
- Built Docker images using multi-stage builds with security best practices
- Configured health checks and resource management for production reliability

## Author

Built by [NVX-11](https://github.com/NVX-11)

## License

MIT
