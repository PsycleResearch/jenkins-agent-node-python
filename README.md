# Jenkins Agent with Node and Python

This repo contains a Dockerfile for a Jenkins agent with Node 22 and Python 3.9.13.

You can get the image from ou [public ECR](https://gallery.ecr.aws/psycle/jenkins-agent-node-python)

You can extend this image or override the Node and Python version by using the environnement variables and build arguments.

| Build argument   | Default value |
| ---------------- | ------------- |
| `NONROOT_USER`   | `jenkins`     |
| `NODE_VERSION`   | `22`          |
| `PYTHON_VERSION` | `3.9.13`      |

| Environment variable | Default value                             |
| -------------------- | ----------------------------------------- |
| `DEBIAN_FRONTEND`    | `noninteractive`                          |
| `LC_ALL`             | `C.UTF-8`                                 |
| `LANG`               | `C.UTF-8`                                 |
| `HOME`               | `/home/$USER`                             |
| `PYENV_ROOT`         | `$HOME/.pyenv`                            |
| `PATH`               | `$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH` |
