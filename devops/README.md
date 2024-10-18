# Protevus Platform DevOps

This directory contains Docker and Kubernetes configurations for the Protevus Platform. It is organized to support our containerization and orchestration needs across different environments.

## Directory Structure

```
devops/
├── docker/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── .dockerignore
├── kubernetes/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── configmap.yaml
├── scripts/
│   ├── docker-build.sh
│   ├── docker-push.sh
│   ├── k8s-deploy.sh
│   └── k8s-rollback.sh
└── README.md
```

### docker/

This directory contains Docker-related files for building and running the Protevus Platform in containers.

- `Dockerfile`: Defines the container image for the Protevus Platform.
- `docker-compose.yml`: Configures multi-container Docker applications for local development.
- `.dockerignore`: Specifies which files and directories should be excluded when building Docker images.

### kubernetes/

The kubernetes/ directory houses Kubernetes manifests for deploying and managing the Protevus Platform in a Kubernetes cluster.

- `deployment.yaml`: Defines the deployment configuration for the Protevus Platform.
- `service.yaml`: Specifies the service configuration for exposing the platform.
- `ingress.yaml`: Configures ingress rules for routing external traffic to the service.
- `configmap.yaml`: Stores configuration data that can be consumed by pods.

### scripts/

This directory contains utility scripts for Docker and Kubernetes operations.

- `docker-build.sh`: Script for building Docker images.
- `docker-push.sh`: Script for pushing Docker images to a registry.
- `k8s-deploy.sh`: Script for deploying the application to a Kubernetes cluster.
- `k8s-rollback.sh`: Script for rolling back a Kubernetes deployment.

## Usage Guidelines

1. Use the provided scripts in the `scripts/` directory for common Docker and Kubernetes operations.
2. Ensure all configuration files are properly parameterized for different environments (dev, staging, production).
3. Keep sensitive information (like passwords and API keys) out of these files and use Kubernetes secrets instead.
4. Regularly update and test these configurations as the Protevus Platform evolves.

## Deployment Process

1. Build the Docker image using `scripts/docker-build.sh`.
2. Push the image to the container registry with `scripts/docker-push.sh`.
3. Deploy to Kubernetes using `scripts/k8s-deploy.sh`.
4. If needed, rollback the deployment using `scripts/k8s-rollback.sh`.

## Contributing

When contributing to the DevOps configurations:

1. Test all changes thoroughly in a non-production environment before applying to production.
2. Document any new scripts or significant changes to existing configurations.
3. Follow Kubernetes and Docker best practices for security and efficiency.
4. Submit a pull request with a clear description of the changes and their purpose.

For any questions or suggestions regarding the DevOps setup, please contact the Protevus Platform infrastructure team.