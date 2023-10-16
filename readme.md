# Sensoriando
**Hub de Sensores**
[web.sensoriando.com.br](http://web.sensoriando.com.br)

## [Requirement](doc/requirement.md)

## [Setup](doc/setup.md)

## Install

1. Create docker's images
```console
docker-compose build
```

2. Docker
```console
docker network create sensoriando
docker-compose up -d
```

3. Postgres

    3.1. Set password 
    ```console 
    docker exec -it sensoriando_database psql -U postgres
    ```

    ```SQL
    ALTER USER postgres PASSWORD '[your passwd]';
    QUIT
    ```

    3.2. Create schemes
    ```console
    cd database
    ./install.sh sensoriando_database
    ```

    3.3. Load demo records **(opcional)**
    ```console
    docker exec -it sensoriando_database psql -U postgres -d sensoriando -f demo.sql
    ```

4. Mosquitto
    3.1. Set password 
    ```console 
    docker exec -it sensoriando_broker mosquitto_passwd -b /mosquitto/config/mosquitto.users [you username] [your password]
    ```

5. Environment
Create .env file

```console
touch .env
```

contexts .env file:
```console
export MOSQUITTO_HOST=sensoriando_broker
export MOSQUITTO_USER=mosquitto
export MOSQUITTO_PASSWORD="your password"
export MOSQUITTO_PORT=1883
export MOSQUITTO_QOS=1
export MOSQUITTO_RETAINED=0

export POSTGRES_HOST=sensoriando_database
export POSTGRES_USER=postgres
export POSTGRES_PASSWORD="your password"
export POSTGRES_DB=sensoriando
export POSTGRES_PORT=5432

export DOCKER_POSTGRES_DATA=./database/data
export DOCKER_MOSQUITTO_DATA=./broker/data
```

6. Reload
```console
docker-compose restart
```

