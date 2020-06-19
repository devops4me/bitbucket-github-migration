
# Migrating Git Repositories from BitBucket to Github

This dockerized application can migrate a large batch of bitbucket repositories to github. Use docker to guarantee a consistent script environment for the migration.

## **`docker build`**

Issue this docker build command either locally or within a continuous integration pipeline environment.

```
docker build       \
    --no-cache     \
    --rm           \
    --tag img.migration \
    .
```

Verify with **`docker image ls`** that you have the img.migration docker image listed.

## **`docker run`**

In order for the docker run to succeed ensure that you have

- entered your hexadecimal **`GITHUB_ACCESS_TOKEN`** environment variable value
- selected the configuration file via **`MIGRATION_CONFIGURATION_FILE`** environment variable value
- configured the bitbucket ssh connection as explained below
- switched on a VPN if required to connect to the BitBucket server.

```
docker run \
    --rm \
    --network host \
    --name vm.migration \
    --env GITHUB_ACCESS_TOKEN=1234567890abcdef1234567890abcdef \
    --env MIGRATION_CONFIGURATION_FILE=migrate-configuration.ini \
    --volume ~/.ssh:/root/.ssh \
    img.migration
```
