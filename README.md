
# Kubernetes Job | How to Migrate Repositories using a Kubernetes Cluster

You can choose a **Kubernetes Job** to run your migration workload. This option is great if you have a Kubernetes cluster and you need the migration to run through completely.

### Why Use Kubernetes to Migrate Git Repositories

The advantages of running jobs and workloads inside Kubernetes are

- kubernetes will restart the job if it fails - it may move it to different nodes
- you only need to create secrets once as opposed to every time you run the job
- multiple team members can run and monitor from Windows, MacOS and Linux


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
github.organization=<ORGANIZATION_ID_STRING>
github.team.id=<TEAM_ID_INTEGER>

[spreadsheet]
sheet.filepath=data/team-repo-migration-data.xlsx
sheet.column.repository.name="Repository Name"
sheet.column.bitbucket.project="BitBucket Project Name"
sheet.column.github.prefix="Github Repo Prefix"
```

The filepath for the spreadsheet is relative to the home directory of the executing user.


### How to Find the Team ID

Use these API calls to retrieve the Github Team ID integer. The best way to find the team is to use the slugs and remember that teams form a hierarchy.

```
curl -H "Authorization: token <GITHUB_ACCESS_TOKEN>" https://api.github.com/orgs/<ORGANIZATION_ID_STRING>/teams
curl -H "Authorization: token <GITHUB_ACCESS_TOKEN>" https://api.github.com/orgs/<ORGANIZATION_ID_STRING>/teams/<TEAM_SLUG>
```


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
- BitBucket **private SSH key** as a **`Kubernetes Secret`** (together with)
- the **SSH config** as another file in the same **`Kubernetes Secret`**

### Create 3 Secret Volume Mappings - then Run the Job

```
kubectl create secret generic migration-config --from-file=migrate-configuration.ini
kubectl create secret generic migration-sheetkey --from-file=spreadsheet=team-repo-migration-data.xlsx --from-file=ssh-key=bitbucket-private-key.pem
kubectl create secret generic migration-sshconfig --from-file=sshconfigkey=config
kubectl create -f kubernetes-job-do.yml
```



---



## Step 5 | View the Logs then Delete the Repositories

Kubernetes keeps the pod alive so we can retrieve the logs until we delete the job. Optionally you can also delete the migrated repositories (the backups will be inside the pod).

```
kubectl logs -f job/migration-job-do
```

Also visit the Github interface and assess the quality and quantity of the repository migration.

### Delete the Github Repositories

You delete the destination Github repositories in order to rinse and repeat. The deletion script only removes the repositories it finds - it skips the deletion if the destination repository does not exist.

```
kubectl create -f kubernetes-job-delete.yml
kubectl logs -f job/migration-job-delete
```

---



## Appendix A | Useful Migration Job Commands

These commands will come in handy at some point.

```
kubectl describe job/migration-job-do
kubectl describe job/migration-job-delete
kubectl describe secret/migration-sheetkey
kubectl describe secret/migration-sshconfig
kubectl describe secret migration-sshfiles
kubectl get jobs -o wide
kubectl get secrets
kubectl get pods -o wide
kubectl delete job migration-job-do
kubectl delete job migration-job-delete
kubectl delete secret migration-config
kubectl delete secret migration-sheetkey
kubectl delete secret migration-sshconfig
```



---



## Appendix B | Using Docker to Migrate Repositories

Aside from a local development environment and a kubernetes workload we can also use docker to guarantee a consistent script environment for the migration.

## **`docker run`**

In order for the docker run to succeed you must ensure that you have mapped the 4 files from their local location to their expected path inside the docker machine.

### To Run the Migration

```
docker run \
  --volume $HOME/path/to/migrate-configuration.ini:/var/opt/migrator/configuration/migrate-configuration.ini \
  --volume $HOME/path/to/team-repo-migration-data.xlsx:/var/opt/migrator/data/team-repo-migration-data.xlsx \
  --volume $HOME/path/to/config:/var/opt/migrator/.ssh/config \
  --volume $HOME/path/to/bitbucket-private-key.pem:/var/opt/migrator/data/bitbucket-private-key.pem \
  devops4me/migrator do
```


### To Delete the Migrated Repositories

```
docker run \
  --volume $HOME/path/to/migrate-configuration.ini:/var/opt/migrator/configuration/migrate-configuration.ini \
  --volume $HOME/path/to/team-repo-migration-data.xlsx:/var/opt/migrator/data/team-repo-migration-data.xlsx \
  --volume $HOME/path/to/config:/var/opt/migrator/.ssh/config \
  --volume $HOME/path/to/bitbucket-private-key.pem:/var/opt/migrator/data/bitbucket-private-key.pem \
  devops4me/migrator delete
```
