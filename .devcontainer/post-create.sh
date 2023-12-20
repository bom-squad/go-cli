#!/usr/bin/env bash

PYTHON_UTILS=("yamllint" "pre-commit" "semgrep")
GITHUB_UTILS=("")
GOLANG_UTILS=("github.com/google/yamlfmt/cmd/yamlfmt@latest" "github.com/goreleaser/goreleaser@latest" "go.uber.org/mock/mockgen@latest" "github.com/mfridman/tparse@latest" "github.com/vburenin/ifacemaker@latest" "github.com/maxbrunsfeld/counterfeiter/v6@latest" "github.com/go-task/task/v3/cmd/task@latest")
APT_UTILS=("shellcheck" "vim")
NODE_UTILS=("@commitlint/cli" "@commitlint/config-conventional")
set -e

# Install Python tools
if [[ $(python --version) != "" ]]; then
    echo ====================================================
    echo Installing Python tools...
    export PYTHONUSERBASE=/tmp/pip-tmp
    export PIP_CACHE_DIR=/tmp/pip-tmp/cache
    PIPX_DIR=""
    if ! type pipx >/dev/null 2>&1; then
        pip3 install --disable-pip-version-check --no-cache-dir --user pipx 2>&1
        /tmp/pip-tmp/bin/pipx install --pip-args=--no-cache-dir pipx
        PIPX_DIR="/tmp/pip-tmp/bin/"
    fi
    for util in "${PYTHON_UTILS[@]}"; do
        if ! type "${util}" >/dev/null 2>&1; then
            "${PIPX_DIR}pipx" install --system-site-packages --pip-args '--no-cache-dir --force-reinstall' "${util}"
        else
            echo "${util} already installed. Skipping."
        fi
    done
    rm -rf /tmp/pip-tmp
fi

# Install tools
echo ====================================================
echo "Installing tools from Github..."
for util in "${GITHUB_UTILS[@]}"; do
    if ! type "${util}" >/dev/null 2>&1; then
        echo "im installing ${util}"
        curl -s "https://raw.githubusercontent.com/${util}" | sudo sh -s -- -b /usr/local/bin
        echo ""
    else
        echo "${util} already installed. Skipping."
    fi
done

# Install Golang tools
echo ====================================================
echo Installing Golang tools...
for util in "${GOLANG_UTILS[@]}"; do
    if ! type "${util}" >/dev/null 2>&1; then
        go install "${util}"
    else
        echo "${util} already installed. Skipping."
    fi
done

# Install Node tools
echo ====================================================
echo Installing Node tools...
for util in "${NODE_UTILS[@]}"; do
    if ! type "${util}" >/dev/null 2>&1; then
        npm install -g "${util}"
    else
        echo "${util} already installed. Skipping."
    fi
done

# Install APT tools
echo ====================================================
echo Installing apt tools...
sudo apt-get update
for util in "${APT_UTILS[@]}"; do
    if ! type "${util}" >/dev/null 2>&1; then
        sudo apt install -y "${util}"
    else
        echo "${util} already installed. Skipping."
    fi
done

# Update .zshrc
echo ====================================================
echo Updating .zshrc ...
{
    printf "setopt appendhistory \nsetopt sharehistory \nsetopt incappendhistory \n"
    printf "export GPG_TTY=%s\n" "$(tty)"
} >>/home/vscode/.zshrc

# Other
echo ====================================================
echo Finallizing ...
pre-commit install
pre-commit run --all-files

# Done
echo ====================================================
