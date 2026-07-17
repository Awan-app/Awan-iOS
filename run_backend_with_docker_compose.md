# Run the Backend Locally with Docker Compose

This guide explains how to build and run the backend locally using Docker Compose.

## Prerequisites

Make sure you have:

- Docker Desktop installed
- Docker Desktop running
- The backend repository available locally
- A Docker Compose file such as:
  - `compose.yaml`
  - `compose.yml`
  - `docker-compose.yaml`
  - `docker-compose.yml`

---

## 1. Open Docker Desktop

Start Docker Desktop and wait until Docker is running.

You can verify Docker from Terminal:

```bash
docker --version
docker compose version
```

---

## 2. Go to the Backend Repository

Open Terminal and navigate to the folder containing the Docker Compose file:

```bash
cd /path/to/backend-repo
```

For example:

```bash
cd ~/Projects/AWAN-Backend
```

List the files:

```bash
ls
```

You should find a Compose file such as:

```text
compose.yaml
```

or:

```text
docker-compose.yml
```

---

## 3. Check the Environment Variables

Look for environment files:

```bash
ls -a
```

You may find:

```text
.env
.env.example
```

If the repository only contains `.env.example`, create your local `.env` file:

```bash
cp .env.example .env
```

Open `.env` and fill in the required values.

Example:

```env
DATABASE_URL=postgresql://user:password@database:5432/app_database
PORT=8080
```

Do not commit secrets or your local `.env` file unless the project explicitly requires it.

---

## 4. Check the Available Services

Run:

```bash
docker compose config --services
```

This displays the services defined in the Compose file, for example:

```text
backend
database
redis
keycloak
```

---

## 5. Build and Run the Backend

Run the containers in the foreground:

```bash
docker compose up --build
```

This command:

- Builds the required Docker images
- Creates the containers
- Starts the backend and its dependencies
- Shows the logs directly in Terminal

Press `Control + C` to stop the containers.

### Run in the Background

To run the containers without keeping the Terminal attached:

```bash
docker compose up -d --build
```

---

## 6. Check the Running Containers

Run:

```bash
docker compose ps
```

Example output:

```text
NAME        SERVICE    PORTS
backend     backend    0.0.0.0:8080->8080/tcp
database    database   0.0.0.0:5432->5432/tcp
```

In this example, the backend is available at:

```text
http://localhost:8080
```

For this mapping:

```text
0.0.0.0:8080->8080/tcp
```

- The left `8080` is the localhost port
- The right `8080` is the port inside the container

---

## 7. View the Logs

View logs from all services:

```bash
docker compose logs -f
```

View logs for only the backend service:

```bash
docker compose logs -f backend
```

Replace `backend` with the actual service name shown by:

```bash
docker compose config --services
```

Press `Control + C` to stop following the logs.

---

## 8. Stop the Backend

Stop and remove the containers and Docker Compose network:

```bash
docker compose down
```

Named volumes, such as the database volume, are preserved.

---

## 9. Restart After Code or Configuration Changes

Rebuild and restart:

```bash
docker compose up -d --build
```

To restart without rebuilding:

```bash
docker compose restart
```

---

## 10. Reset the Containers and Database Data

To remove the containers, network, and Docker-managed volumes:

```bash
docker compose down -v
```

Then start again:

```bash
docker compose up -d --build
```

> Warning: `docker compose down -v` deletes persisted data stored in Docker volumes, including local database data.

---

## Common Commands

### Start

```bash
docker compose up -d
```

### Build and start

```bash
docker compose up -d --build
```

### Check running services

```bash
docker compose ps
```

### Show service names

```bash
docker compose config --services
```

### View all logs

```bash
docker compose logs -f
```

### View backend logs

```bash
docker compose logs -f backend
```

### Stop

```bash
docker compose down
```

### Full reset

```bash
docker compose down -v
docker compose up -d --build
```

---

## Quick Start

```bash
cd /path/to/backend-repo
cp .env.example .env
docker compose up --build
```

If `.env` already exists, skip the copy command:

```bash
cd /path/to/backend-repo
docker compose up --build
```

After startup, use:

```bash
docker compose ps
```

to identify the localhost port for the backend.
