# Multi-Container Todo API

> roadmaps.sh — **Multi-Container Application** project solution

A production-ready Docker Compose stack running a Node.js (Express + Mongoose) Todo API
alongside MongoDB, with optional Nginx reverse proxy.

---

## API Endpoints

| Method | Endpoint               | Description         |
|--------|------------------------|---------------------|
| GET    | `/todos`               | Get all todos       |
| POST   | `/todos`               | Create a new todo   |
| GET    | `/todos/:id`           | Get a single todo   |
| PUT    | `/todos/:id`           | Update a single todo|
| DELETE | `/todos/:id`           | Delete a single todo|
| GET    | `/health`              | Health check        |

### Example requests

```bash
curl http://localhost:3000/todos
curl -X POST http://localhost:3000/todos -H "Content-Type: application/json" -d '{"title":"Buy groceries"}'
curl http://localhost:3000/todos/:id
curl -X PUT http://localhost:3000/todos/:id -H "Content-Type: application/json" -d '{"title":"Buy groceries","completed":true}'
curl -X DELETE http://localhost:3000/todos/:id
```

---

## Project Structure

```
.
├── src/
│   └── index.js          # Express + Mongoose API
├── nginx/
│   └── nginx.conf        # Reverse proxy config (bonus)
├── terraform/
│   ├── main.tf           # Digital Ocean droplet as code
│   └── terraform.tfvars.example
├── ansible/
│   ├── playbook.yml      # Server provisioning (Docker, deploy)
│   ├── inventory.ini.example
│   └── ansible.cfg
├── .github/workflows/
│   └── deploy.yml        # CI/CD pipeline — GitHub Actions
├── Dockerfile
├── docker-compose.yml
└── package.json
```

---

## Local Development

### Prerequisites
- Node.js 20+
- Docker + Docker Compose

### 1. Run locally (no Docker)

```bash
npm install
npm run dev
```

The API will be available at `http://localhost:3000`.  
Make sure MongoDB is running locally at `mongodb://localhost:27017/todos`.

### 2. Run with Docker Compose (recommended)

```bash
# Start MongoDB + API
docker compose up -d

# Verify
curl http://localhost:3000/health
# → {"status":"ok","timestamp":"..."}
```

MongoDB data is persisted in the `mongo_data` Docker volume — stopping and
restarting the stack does not lose data.

### 3. Reset databases

```bash
docker compose down -v   # WARNING: deletes the mongo_data volume
docker compose up -d
```

---

## Deploy to Production (Digital Ocean)

### Option A — Manual (Terraform + Ansible)

```bash
# 1. Provision a droplet
cd terraform
cat terraform.tfvars.example > terraform.tfvars   # fill in your values
terraform init && terraform plan && terraform apply

# 2. Note the droplet IP from the output, then configure Ansible
cd ../ansible
cat inventory.ini.example > inventory.ini   # fill in your droplet IP + SSH key
ansible-playbook playbook.yml -i inventory.ini
```

### Option B — GitHub Actions CI/CD

1. Push this repo to GitHub.
2. Add the following **repository secrets** via Settings → Secrets:

| Secret | Value |
|--------|-------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN`    | Docker Hub access token |
| `SERVER_HOST`        | Droplet public IP |
| `SERVER_USER`        | SSH user (e.g. `root`) |
| `SERVER_SSH_KEY`     | Private SSH key for the droplet |
| `SERVER_PORT`        | SSH port (default `22`) |

3. Update `IMAGE_NAME` in `.github/workflows/deploy.yml` to match your Docker Hub username.
4. Every push to `main` triggers: **lint → build → push → deploy**.

---

## Reverse Proxy (Bonus)

The Nginx reverse proxy service is defined in `docker-compose.yml` under the
`nginx` service. It is **disabled by default** and included via a Docker Compose
profile so it can be enabled with a single flag.

```bash
# Proxy runs on port 80, API kept on 3000
docker compose --profile reverse-proxy up -d

# For local HTTP access on port 80
# Option 1 — via Docker Compose with nginx override
DOCKER_HOST=unix:///var/run/docker.sock docker compose --profile reverse-proxy up -d

# Option 2 — standalone nginx.conf → Docker
docker run -d -p 80:80 \
  -v $(pwd)/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  nginx:1.27-alpine
```

The proxy forwards all requests from `http://localhost` → `api:3000` internally.

Set `your_domain.com` in your DNS A-record to point at the server IP, then update
the `nginx/nginx.conf` `server_name` directive accordingly.

---

## Environment Variables

| Variable      | Default                | Description |
|---------------|------------------------|-------------|
| `PORT`        | `3000`                 | Express listen port |
| `MONGO_URI`   | `mongodb://mongo:27017/todos` | MongoDB connection string |
| `NODE_ENV`    | `production`           | runtime environment |

---

## Tech Stack

| Tool              | Purpose                |
|-------------------|------------------------|
| Express            | REST API framework     |
| Mongoose           | MongoDB ODM            |
| MongoDB            | Document database      |
| Docker + Compose   | Container orchestration |
| Nginx              | Reverse proxy          |
| Terraform          | Infrastructure as Code |
| Ansible            | Server configuration   |
| GitHub Actions     | CI/CD                  |

---

## License

MIT — this is a learning project from roadmap.sh
