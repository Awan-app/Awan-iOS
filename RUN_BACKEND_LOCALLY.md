# Run the Backend Locally

The local backend configuration is in the sibling `backend` repository. It includes
an ignored `.env` file with development-only database, mail, and application values.

## Start the containers

From the iOS repository root, run:

```bash
cd ../backend
docker compose up -d --build
```

The first run downloads images and builds the Spring application, so it can take a
few minutes. Later starts normally only need:

```bash
docker compose up -d
```

## Confirm it is running

```bash
docker compose ps
curl http://localhost:8080/api/v1/test
```

The curl command should return:

```text
Working!!
```

## Local URLs and ports

| Service | Address |
| --- | --- |
| Backend API | `http://localhost:8080` |
| Test endpoint | `http://localhost:8080/api/v1/test` |
| Mailpit inbox | `http://localhost:8025` |
| MySQL (host access) | `localhost:3307` |

The root path (`http://localhost:8080/`) is protected and returning `403` is
expected. Use an API endpoint instead.

## View logs

```bash
docker compose logs -f app
```

Use `Control-C` to stop following logs; the containers keep running.

## Stop or reset

```bash
docker compose down
```

To remove the local MySQL data as well:

```bash
docker compose down -v
```

After resetting data, start the stack again with `docker compose up -d --build`.
