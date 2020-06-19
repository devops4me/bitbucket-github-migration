
# Kubernetes Job | How to Migrate Repositories using a Kubernetes Cluster

You can choose a **Kubernetes Job** to run your migration workload. This option is great if you have a Kubernetes cluster and you need the migration to run through completely.

### Why Use Kubernetes to Migrate Git Repositories

The advantages of running jobs and workloads inside Kubernetes are

- kubernetes will restart the job if it fails - it may move it to different nodes
- the team can see the results from log viewers like the ElasticSearch stack
- you only need to create secrets once as opposed to every time you run the job


Without further ado let's step up and perform the repository migration.


---

## Step 1 | Setup the Migration Repositories Spreadsheet



---


## Step 1 | Setup the Configuration File

The software expects that the main configuration file **will be**
- in INI format
- inside the home directory of the executing user
- called **`migrate-configuration.ini`**

### `~/migrate-configuration.ini`

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

### Creating the Kubernetes Secret

```
kubectl create secret generic migration-config --from-file=<PATH_TO_INI_FILE>
```
---


## How to Configure the Repository Migration

The above migration will fail if you haven't performed the five key configuration steps.
To configure the repository migration you will need to

- set the github access token as a Kubernetes Secret
- place the spreadsheet listing the repositories as a Kubernetes ConfigMap
- place the BitBucket SSH key as a Kubernetes Secret
- set the SSH config file as a Kubernetes ConfigMap
- set the migration configuration INI file as a Kubernetes ConfigMap

These are the commands to perform the configuration actions.

```
kubectl apply -f kubernetes-secrets.yml 
kubectl create secret generic migration-config --from-file=<PATH_TO_INI_FILE>
kubectl create secret generic migration-spreadsheet --from-file=<PATH_TO_SPREADSHEET>
kubectl create configmap migration-spreadsheet --from-file=<PATH_TO_SPREADSHEET>
```


---


## How to Migrate Repositories

**Let's do the migration.** After satisfying the 4 script dependencies (INI configuration file, excel spreadsheet, bitbucket ssh key and ssh config) you execute the migration like this.

```
kubectl create -f kubernetes-job.yml
kubectl get jobs -o wide
kubectl -n default logs -f job/migration-job --all-containers=true --since=10m
```


---


## Common and Useful Kubernetes Commands

These commands will come in handy at some point.

```
kubectl get pods
kubectl get secrets
kubectl get configmaps
kubectl get jobs
kubectl delete job migration-job
kubectl delete secret migration-config
kubectl delete configmap migration-spreadsheet
```
