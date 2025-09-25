# Container Registry Backup

This repository is used to pull and store commonly used Docker images in GitHub Packages for the MeasuringU organization. The images are then available for use in other repositories and projects.

## Images Managed

This repository manages the following Docker images:

1. **nginx-php-fpm** - Based on `richarvey/nginx-php-fpm:3.1.6`
2. **node-20-slim** - Based on `node:20-slim`

## GitHub Actions Workflow

The repository uses GitHub Actions to:
- Pull the specified Docker images from Docker Hub
- Re-tag them for the MeasuringU organization
- Push them to GitHub Packages (GitHub Container Registry)

### Manual Triggering

You can manually trigger the workflow to acquire images:

1. Go to the **Actions** tab in this repository
2. Select the **Acquire Container Images** workflow
3. Click **Run workflow**
4. Choose which image(s) to acquire:
   - `both` - Acquire both images (default)
   - `nginx-php-fpm` - Acquire only the nginx-php-fpm image
   - `node-20-slim` - Acquire only the node:20-slim image

### Automatic Triggering

The workflow also runs automatically when:
- Changes are pushed to the `main` branch that affect:
  - Files in the `docker/` directory
  - The workflow file itself

## Using the Images

Once the workflow has run successfully, the images will be available at:

- `ghcr.io/measuringu/nginx-php-fpm:3.1.6`
- `ghcr.io/measuringu/nginx-php-fpm:latest`
- `ghcr.io/measuringu/node-20-slim:20-slim`
- `ghcr.io/measuringu/node-20-slim:latest`

You can pull these images using:

```bash
docker pull ghcr.io/measuringu/nginx-php-fpm:3.1.6
docker pull ghcr.io/measuringu/node-20-slim:20-slim
```

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── acquire-images.yml    # GitHub Actions workflow
├── docker/
│   ├── nginx-php-fpm.Dockerfile  # Dockerfile for nginx-php-fpm image
│   └── node-20-slim.Dockerfile   # Dockerfile for node:20-slim image
└── README.md
```

## Migration from GitLab

This repository was previously configured to use GitLab CI/CD to store images in GitLab's container registry. It has been migrated to use GitHub Actions and GitHub Packages for better integration with the GitHub ecosystem.

