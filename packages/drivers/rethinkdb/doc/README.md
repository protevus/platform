# Running RethinkDb in container

Use the following command to run rethinkDb as services using the provided docker compose file. `Rancher` or `Docker` need to be installed. Replace `nerdctl` with `docker` if using Docker.

## Installation

* Starting the rethinkDB container

    ```bash
    nerdctl compose -f docker-compose-rethinkdb.yml -p rethink up -d
    ```

* Stopping the rethinkDB container

    ```bash
    nerdctl compose -f docker-compose-rethinkdb.yml -p rethink stop
    nerdctl compose -f docker-compose-rethinkdb.yml -p rethink down
    ```

* Checking the rethinkDB container log

    ```bash
    nerdctl logs rethink-rethinkdb-1 -f
    ```

## Compose file

```yaml
services:
  rethinkdb:
    image: rethinkdb:latest
    restart: "no"
    ports:
      - "8080:8080"
      - "28015:28015"
      - "29015:29015"
    volumes:
      - "rethinkdb:/data"
    networks:
      - appnet

volumes:
  rethinkdb:
    driver: local

networks:
  appnet:


```
