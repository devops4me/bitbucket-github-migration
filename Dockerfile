
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


# --->
# ---> Configure the git installation.
# --->

RUN git config --global user.email "apolloakora@gmail.com" && \
    git config --global user.name "Apollo Akora"


# --->
# ---> List the running directory
# --->

RUN ls -lah
RUN pwd


# --->
# ---> Kick off the script when docker run is issued.
# --->

ENTRYPOINT [ "migrate", "do" ]
