
# Kubernetes Job | How to Migrate Repositories using a Kubernetes Cluster

You can choose a **Kubernetes Job** to run your migration workload. This option is great if you have a Kubernetes cluster and you need the migration to run through completely.

### Why Use Kubernetes to Migrate Git Repositories

The advantages of running jobs and workloads inside Kubernetes are

- kubernetes will restart the job if it fails - it may move it to different nodes
- the team can see the results from log viewers like the ElasticSearch stack
- you only need to create secrets once as opposed to every time you run the job


---


## How to Migrate Repositories

**Let's begin at the end.** After satisfying the 5 script dependencies (excel spreadsheet, INI configuration file, bitbucket ssh key, ssh config file and the github access token) you can execute the migration like this.

```
kubectl create -f kubernetes-job.yml
kubectl get jobs -o wide
kubectl -n default logs -f job/migration-job --all-containers=true --since=10m
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

Thesea are the commands to perform the configuration actions.

```
kubectl apply -f kubernetes-secrets.yml 
kubectl create configmap repo-spreadsheet --from-file=../spreadsheets/team-repo-migration-data.xlsx
```


---


## Common and Useful Kubernetes Commands

These commands will come in handy at some point.

```
kubectl delete job migration-job
```
