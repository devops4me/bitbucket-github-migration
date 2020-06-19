
# Kubernetes Job | How to Migrate Repositories using a Kubernetes Cluster

You can choose a **Kubernetes Job** to run your migration workload. This option is great if you have a Kubernetes cluster and you need the migration to run through completely.

### Why Use Kubernetes to Migrate Git Repositories

The advantages of running jobs and workloads inside Kubernetes are

- kubernetes will restart the job if it fails - it may move it to different nodes
- you only need to create secrets once as opposed to every time you run the job


Without further ado let's step up and perform the repository migration.


---


## Step 1 | Setup the Migration Repositories Spreadsheet

When you setup the spreadsheet ensure that it has columns for

- the repository name (in BitBucket)
- the project name (in BitBucket)
- the repository prefix (in Github)

Then take the column names and add them to the below configuration file.


---


## Step 2 | Setup the Configuration File

The software expects that the main configuration file **will be**

- in INI format
- inside the home directory of the executing user
- called **`migrate-configuration.ini`**

### `~/configuration/migrate-configuration.ini`

```
[source]
bitbucket.host=bitbucket  # this must match the Host directive in ~/.ssh/config
bitbucket.port=7999       # which port should the cloning use

[destination]
github.username=mygithubusername
github.access.token=abcdef0123456789fedcba987654321
github.separator=-

[spreadsheet]
sheet.filepath=data/team-repo-migration-data.xlsx
sheet.column.repository.name="Repository Name"
sheet.column.bitbucket.project="BitBucket Project Name"
sheet.column.github.prefix="Github Repo Prefix"
```

The filepath for the spreadsheet is relative to the home directory of the executing user.



---



## Step 3 | Configure the BitBucket SSH Connection

The script needs you to be able to connect to bitbucket via SSH. Follow these rules to perform the SSH configuration.

1. the **`Host`** directive must match **`bitbucket.host`** in the INI configuration file
1. your private key must have its counterpart public key setup in BitBucket
1. you need a SSH config file with the correct **`Hostname`**, **`User`** and **`Port`** directives
1. use squiggle **`~`** to prefix the IdentityFile path to keep the script portable
1. the name of the private key in the SSH configuration must match the filename of the key


### Your SSH Config File

Put this config file in the .ssh folder.

```
Host bitbucket
HostName bitbucket-something.com
User <lowercase-user-id>
Port 7999
IdentityFile ~/.ssh/<private-key-name>.pem
StrictHostKeyChecking no
```

Use forward slashes to run the script in Docker, Kubernetes, MacOs or Linux. Use backslashes if executing from a Windows development environment.



---



## Step 4 | Run the Workload as a Kubernetes Job

You are ready once you have a kubernetes cluster and you have satisfied the script dependencies (INI configuration file, excel spreadsheet, bitbucket ssh key and ssh config). You are going to **set the**

- **repositories spreadsheet** as a **`Kubernetes Secret`**
- migration configuration **INI file** as a **`Kubernetes Secret`**
- BitBucket **private SSH key** as a **`Kubernetes Secret`**
- **SSH config** as a **`Kubernetes ConfigMap`** (variety is the spice of life)

```
kubectl create secret generic migration-config --from-file=<PATH_TO_INI_FILE>
kubectl create secret generic migration-spreadsheet --from-file=<PATH_TO_SPREADSHEET>

kubectl create secret generic ssh-files --from-file=ssh-config=config --from-file=ssh-key=bitbucket-private-key.pem

kubectl create secret generic migration-sshkey --from-file=<PATH_TO_PRIVATE_KEY_PEM>
kubectl create configmap migration-sshconfig --from-file=<PATH_TO_PRIVATE_KEY_PEM>
kubectl create -f kubernetes-job.yml
kubectl get jobs -o wide
kubectl logs -f job/migration-job
```


---


## How to Migrate Repositories

**Let's do the migration.** After satisfying the 4 script dependencies (INI configuration file, excel spreadsheet, bitbucket ssh key and ssh config) you execute the migration like this.



---



## Common and Useful Kubernetes Commands

These commands will come in handy at some point.

```
kubectl describe job/migration-job
kubectl describe secret/migration-spreadsheet
kubectl describe secret/migration-config
kubectl describe secret migration-sshkey
kubectl get jobs -o wide
kubectl get secrets
kubectl get configmaps
kubectl get pods -o wide
kubectl delete job migration-job
kubectl delete secret migration-config
kubectl delete configmap migration-spreadsheet
```



---



## Using Docker to Migrate Repositories from BitBucket to Github

Aside from a local development environment and a kubernetes workload we can also use docker to guarantee a consistent script environment for the migration.

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
