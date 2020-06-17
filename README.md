
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

## How to Configure the BitBucket SSH Connection

The script needs you to be able to connect to bitbucket via SSH. To configure this

- you need a SSH config file and private key on the container's host
- use squiggle **`~`** in the identity file so inside the container it maps correctly
- the private key needs to be in the SSH folder (which is volume mounted)


### Your Local SSH Config File

Put this config file in the .ssh folder.

```
Host bitbucket
HostName bitbucket-something.com
User <user-id>
Port 7999
IdentityFile ~/.ssh/<private-key-name>.pem
StrictHostKeyChecking no
```

Set the hostname and the user appropriately. If on Linux set the path to the key appropriately with forward slashes.


## The Global Migration Configuration

The global migration configuration will apply for all the repositories being migrated. This script migrates the repository list based on a spreadsheet.

Put this file in the repository root and name it **`migrate-configuration.ini`**. Ensure that the important column names in the spreadsheet are configured correctly in the **`sheet.column`** keys.

```
[source]
bitbucket.host=bitbucket  # usually found in ~/.ssh/config file
bitbucket.port=7999       # which port should the cloning use

[destination]
github.separator=-          # the separator character after prefix
github.username=<username>  # username of the github repository

[spreadsheet]
sheet.filepath=spreadsheets/team-repo-migration-data.xlsx
sheet.column.repository.name="Repository Name"
sheet.column.bitbucket.project="BitBucket Project Name"
sheet.column.github.prefix="Github Repo Prefix"
```

