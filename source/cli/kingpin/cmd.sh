#!/usr/bin/env bash

readonly CLI_VERSION="0.0.1"
readonly CLI_LICENSE="MIT License"
readonly CLI_DESC="machine bootstrapping helper"
readonly CLI_USAGE="[-s]"

# Boot
dc::commander::init

# Depend on brew
dc::depends::mac


# Arg 1 must be the digits section of a movie imdb id
#dc::argv::arg::validate 1 "^tt[0-9]{7}$"
# Validate flag
#if [ "$DC_ARGV_IMAGE" ]; then
#  dc::argv::flag::validate image "^(?:show|dump)$"
#fi

# XXX require brew at this point

kingpin::dev::refresh(){
  local _here
  _here=$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)
  curl -s -S -L -o "$_here/.gvm-installer"  https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer
  chmod u+x "$_here/.gvm-installer"
}


get::go(){
  dc::logger::info "Installing golang development environment"

  dc::depends::mac::on go
  dc::depends::mac::on dep

  local _here
  _here=$(cd "$(dirname "${BASH_SOURCE[0]:-$PWD}")" 2>/dev/null 1>&2 && pwd)
  local dest="${POSH_BIN:-"$HOME/Applications/bin"}"
  if [ ! -e "$dest/gvm" ]; then
    "$_here"/.gvm-installer "" "$dest"
  fi

  cat <<- EOF > "$HOME/.posh_go"
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
# ★ kingpin ＆ go     ★
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★

export GOPATH="\$HOME/Projects/Go"
export PATH="\$GOPATH/bin:\${PATH}"
[[ -s "\${POSH_BIN:-\$HOME/Applications/bin}/gvm/scripts/gvm" ]] && source "\${POSH_BIN:-\$HOME/Applications/bin}/gvm/scripts/gvm"
EOF
# XXX ^ gvm will force add the last line to .profile regardless

  helpers::profile_link .posh_go
  # shellcheck source=/dev/null
  . "$HOME/.profile"

  gvm install go1.10 --prefer-binary
  gvm install go1.11 --prefer-binary
  gvm use go1.11 --default

  dc::logger::info "Done with golang"
}

setit(){
  nvm install "$1"
  nvm use "$1"
  npm install -g yarn
  yarn global add gulp slush ember-cli create-react-app
}

get::node(){
  dc::logger::info "Installing node development environment"
  ## About node version management:
  # https://github.com/ekalinin/nodeenv
  # https://github.com/isaacs/nave
  # https://github.com/tj/n
  # https://github.com/creationix/nvm

  dc::depends::mac::on node
  dc::depends::mac::on yarn
  dc::depends::mac::on nvm

  cat <<-EOF > "$HOME/.posh_node"
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
# ★ kingpin ＆ node   ★
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★

export NVM_DIR=\${POSH_BIN:-\$HOME/Applications/bin}/nvm
. \$(brew --prefix nvm)/nvm.sh
export NPM_CONFIG_CACHE=\${POSH_TMP:-\$HOME/tmp}/cache/npm
export NPM_CONFIG_TMP=\${POSH_TMP:-\$HOME/tmp}/tmp/npm

export PATH="\$(brew --prefix yarn)/bin:\${PATH}"
# yarn global bin ends-up in brew/bin
export YARN_CACHE_FOLDER="\${POSH_TMP:-\$HOME/tmp}/cache/yarn"
EOF

  helpers::profile_link .posh_node
  # shellcheck source=/dev/null
  . "$HOME/.profile"

  mkdir -p "$NVM_DIR"

  # System
  yarn global add gulp slush ember-cli create-react-app

  # Additional versions
  setit lts/boron
  setit lts/carbon
  setit 10
  nvm alias default 10

  dc::logger::info "Done with node"
}

get::python(){
  dc::logger::info "Installing python development environment"

  # From https://github.com/pyenv/pyenv/wiki/Common-build-problems#requirements
  dc::depends::mac::on readline
  dc::depends::mac::on xz
  dc::depends::mac::on pyenv

  cat <<- EOF > ~/.posh_python
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★
# ★ kingpin ＆ python           ★
# ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★ ★

export PYENV_ROOT="\$(brew --repository)/../pyenv"
if command -v pyenv; then
  eval "\$(pyenv init -)"
fi
EOF

  helpers::profile_link .posh_python
  # shellcheck source=/dev/null
  . "$HOME/.profile"

#  LIBRARY_PATH=$(brew --prefix) LD_LIBRARY_PATH=$(brew --prefix)/lib INCLUDE_PATH=$(brew --prefix)/include C_INCLUDE_PATH=$INCLUDE_PATH CPLUS_INCLUDE_PATH=$INCLUDE_PATH \
  # XXX so effed-up
  LDFLAGS="-L$(brew --prefix)/lib" CFLAGS="-I$(xcrun --show-sdk-path)/usr/include -I$(brew --prefix)/include" \
    pyenv install 2.7.15
  LDFLAGS="-L$(brew --prefix)/lib" CFLAGS="-I$(xcrun --show-sdk-path)/usr/include -I$(brew --prefix)/include" \
    pyenv install 3.7.0
  pyenv global system 2.7.15 3.7.0
  ##  pip install tox

  dc::logger::info "Done with python"
}


# get::go
# get::node
get::python
