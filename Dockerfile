FROM docker:dind AS dind

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
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev libgeos-dev \
    ffmpeg libsm6 libxext6 libgl1-mesa-dev ca-certificates gnupg && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install

# Install NodeJS
ARG NODE_MAJOR=22

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install nodejs -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean &&\
    npm install --global yarn

# Install Golang
ARG GOLANG_VER=1.23.2
RUN curl -fsSL https://go.dev/dl/go${GOLANG_VER}.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH=/usr/local/go/bin:${PATH}

USER $NONROOT_USER

ENV HOME=/home/${NONROOT_USER}
WORKDIR ${HOME}

RUN mkdir -p ${HOME}/go
ENV PATH=${HOME}/go/bin:${PATH}

ENV PYENV_ROOT=${HOME}/.pyenv

# Install Pyenv
RUN git clone https://github.com/pyenv/pyenv.git ${PYENV_ROOT} && \
    cd ${PYENV_ROOT} && src/configure && make -C src

# Setup Pyenv
ENV PATH=${HOME}/.local/bin:$PYENV_ROOT/shims:${PYENV_ROOT}/bin:$PATH
RUN eval "$(pyenv init --path)" && \
    eval "$(pyenv init -)"

# Install Python
ARG PYTHON_VERSION=3.9.13
RUN PYTHON_CONFIGURE_OPTS=--enable-shared pyenv install ${PYTHON_VERSION} && \
    pyenv global ${PYTHON_VERSION} && \
    pip install -U pip wheel setuptools pexpect --no-cache-dir

# Install Poetry
ARG POETRY_VERSION=1.8.4
RUN curl -sSL https://install.python-poetry.org | python3 - --version ${POETRY_VERSION}

CMD ["/bin/bash"]
