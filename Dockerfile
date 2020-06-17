
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
# ---> Now copy this rubygems repository including the configs
# ---> and then use rake to build and package the migrate gem.
# --->

COPY . .
RUN rake install


# --->
# ---> We will mount the container .ssh folder to a place that has
# ---> a ssh config file and private key that allows us to access the
# ---> bitbucket repositories.
# --->

RUN mkdir .ssh
COPY private_key.pem /root/.ssh/
RUN chmod 600 /root/.ssh/private_key.pem
COPY config /root/.ssh/


# --->
# ---> Configure the git installation.
# --->

RUN git config --global user.email "apollo@somewhere.com" && \
    git config --global user.name "Apollo Akora"


# --->
# ---> Kick off the script when docker run is issued.
# --->

ENTRYPOINT [ "migrate", "do" ]
