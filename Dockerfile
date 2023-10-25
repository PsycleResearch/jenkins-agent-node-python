FROM docker:dind as dind

FROM jenkins/agent

COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/
COPY --from=docker:dind /usr/local/libexec/docker/cli-plugins/docker-buildx /usr/local/libexec/docker/cli-plugins/docker-compose /usr/local/libexec/docker/cli-plugins/

ENV DEBIAN_FRONTEND=noninteractive

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ARG NONROOT_USER=jenkins

USER root

# Install requirements
RUN apt-get update -qq && apt-get install -qq -y git make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm unzip jq procps \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev libgeos-dev && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

USER $NONROOT_USER

ENV HOME=/home/$NONROOT_USER
WORKDIR $HOME

# Install NodeJS via NVM
ENV ENV="$HOME/.profile"
ENV NVM_DIR="$HOME/.nvm"
ARG NVM_VERSION=v0.39.5
ARG NODE_VERSION=20.9.0

RUN curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash

# install node and npm
RUN \. $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

# add node and npm to path so the commands are available
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# confirm installation
RUN node -v
RUN npm -v

ENV PYENV_ROOT=$HOME/.pyenv

# Install Pyenv
RUN git clone https://github.com/pyenv/pyenv.git $PYENV_ROOT && \
    cd $PYENV_ROOT && src/configure && make -C src

# Setup Pyenv
ENV PATH=$HOME/.local/bin:$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN eval "$(pyenv init --path)" && \
    eval "$(pyenv init -)"

# Install Python
ARG PYTHON_VERSION=3.9.13
RUN PYTHON_CONFIGURE_OPTS=--enable-shared pyenv install $PYTHON_VERSION && pyenv global $PYTHON_VERSION

# Update pip
RUN pip install -U pip wheel setuptools pexpect --no-cache-dir

# Install Poetry
ARG POETRY_VERSION=1.5.1
RUN curl -sSL https://install.python-poetry.org | python3 - --version $POETRY_VERSION

CMD /bin/bash
