
# Contributing to the BitBucket to Github Migration Script

This dockerized application can migrate a large batch of bitbucket repositories to github. The documentation helps you first run a `helloworld` migration and then you can fork this repository and configure your own set of repositories to migrate.


## How to Configure the Script's Environment

The script needs you to be able to connect to the bitbucket and github repositories. To configure this you need to create this file in the repository root.

### The SSH Config File

Put this config file in the .ssh folder.

```
Host bitbucket
HostName bitbucket-something.com
User <user-id>
Port 7999
IdentityFile C:\Users\<userid>\.ssh\<name-of-ssh-key>.pem
StrictHostKeyChecking no
```

Set the hostname and the user appropriately. If on Linux set the path to the key appropriately with forward slashes.


### The BitBucket SSH Private Key

Put the bitbucket ssh key in your **`.ssh`** directory and then change the name inside the **`.ssh/config`** file.


### The Global Migration Configuration


The global migration configuration will apply for all the repositories being migrated. This script will be amended to migrate the repository list based on a spreadsheet.

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

Make sure that any VPN is running if required to connect to Bitbucket.


### Run the Migration

Once your configuration is done run the migration with these 2 commands.

```
sudo rake install # or just rake install on windows
export GITHUB_ACCESS_TOKEN=23456789ABCDEF23456789ABCDEF23456789ABCDEF
export MIGRATION_CONFIGURATION_FILE=migrate-configuration.ini
migrate do --dryrun
migrate do
```

If you want another go, run the migrate delete command to clear the destination github repositories.

```
migrate delete
```


## Creating a Development Environment for the Migrate Script

To develop the script you don't want to wait for a **`docker build`** then a **`docker run`** before you can get feedback on your change. You need to setup a development environment and this is how. Ruby is universal so you can create an environment in Windows, however Linux is preferred. The docker container runs Ubuntu and the script has been tested on MacOSX.


### How to Install Ruby on Windows 10

On windows 10 we need to first install chocolatey. **The steps for installing chocolatey are below.** Now close and re-open powershell as an administrator.

With chocolatey installed we install ruby.

```
choco install ruby
```

Now again close and reopen the powershell window.

```
ruby --version
ruby -v
```

The reply should be sensible.


### How to Run the Migrate Script

Use git bash to clone the migrate repository. After installing Ruby go to the repository in Powershell.

```
gem list
rake install
migrate --help
migrate --version
```

**`gem list`** should show that rake is installed as a gem. If all goes well then **`migrate --help`** and **`migrate --version`** should respond appropriately.

At this stage you can follow the instructions to tweaking the configuration before doing a migrate execute.


## How to Install Chocolatey

Chocolatey is the goto Windows package manager for DevOps command line (scripting) professionals.

The steps to install chocolatey through the **`Powershell`** CLI are to

- click on the Windows start button and type Powershell
- click the arrow on Windows PowerShell and Run as administrator
- Run **`Get-ExecutionPolicy`**
- if it returns Restricted, then run **`Set-ExecutionPolicy AllSigned`** or **`Set-ExecutionPolicy Bypass -Scope Process`**
- run this command - **`Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))`**

Now chocolatey should be installed.


## Using Octokit | Github API Library

With bash we need to code all the github functionality ourselves using CUrl and the REST API (or the rather sparse hub cli).

Octokit is a fully featured Github API library for Ruby and should offer most of the functionality available through the UI. 

- **[Visit the Octokit Repositories Class](https://octokit.github.io/octokit.rb/Octokit/Client/Repositories.html)**


## Using Roo | Excel Spreadsheet API

The **[roo homeopage](https://github.com/roo-rb/roo)** details the API interface for interacting with Excel spreadsheets.

The object graph for an excel spreadsheet is
- the file (spreadsheet itself)
- the sheet (numbered or named)
- the columns or rows within the sheet (numbered or named)
