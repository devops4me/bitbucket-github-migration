
# --->
# ---> Extend the base ruby image to prepare for installing the
# ---> bitbucket to github migration environment.
# --->

FROM ruby:latest
USER root


# --->
# ---> Install the ruby gems that the migration script depends on.
# --->

RUN gem install \
    thor        \
    inifile     \
    octokit     \
    roo


# --->
# ---> Update the packages within this machine and create a user
# ---> to run the repository migration with minimal privileges.
# --->

RUN apt-get update && \
    apt-get --assume-yes install -qq -o=Dpkg::Use-Pty=0 wget && \
    adduser --home /var/opt/migrator --shell /bin/bash --gecos 'Link Checking User' migrator && \
    install -d -m 755 -o migrator -g migrator /var/opt/migrator && \
    usermod -a -G sudo migrator


# --->
# ---> Now copy this rubygems repository including the configs
# ---> and then use rake to build and package the migrate gem.
# --->

COPY . /var/opt/migrator/code
RUN cd /var/opt/migrator/code && rake install && chown -R migrator:migrator /var/opt/migrator/*


# --->
# ---> Now switch to the lesser permissioned migrator user as
# ---> it does not like to run with unnecessary privileges.
# --->

USER migrator
WORKDIR /var/opt/migrator


# --->
# ---> We will mount the container .ssh folder to a place that has
# ---> a ssh config file and private key that allows us to access the
# ---> bitbucket repositories.
# --->

RUN mkdir .ssh && mkdir data && mkdir configuration
RUN chown -R migrator:migrator ~/.ssh

# --->
# ---> Configure the git installation.
# --->
# ---> Change

RUN git config --global user.email "apolloakora@gmail.com" && \
    git config --global user.name "Apollo Akora"


# --->
# ---> Kick off the script to either do the migration or
# ---> in reverse to delete the migrated repositories.
# --->

ENTRYPOINT [ "migrate" ]
CMD [ "do" ]
