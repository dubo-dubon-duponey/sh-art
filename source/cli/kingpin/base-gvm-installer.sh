#!/usr/bin/env bash
# Modified from https://github.com/moovweb/gvm under MIT License

display_error() {
	tput sgr0
	tput setaf 1
	echo "ERROR: $1"
	tput sgr0
	exit 1
}

check_existing_go() {

	if [ "$GOROOT" = "" ]; then
    if command -v go >/dev/null; then
			GOROOT=$(go env | grep GOROOT | cut -d"=" -f2)
		else
			echo "No existing Go versions detected"
			return
		fi
	fi
	echo "Created profile for existing install of Go at $GOROOT"
	mkdir -p "$GVM_DEST/$GVM_NAME/environments" &> /dev/null || display_error "Failed to create environment directory"
	mkdir -p "$GVM_DEST/$GVM_NAME/pkgsets/system/global" &> /dev/null || display_error "Failed to create new package set"
	mkdir -p "$GVM_DEST/$GVM_NAME/gos/system" &> /dev/null || display_error "Failed to create new Go folder"
	cat << EOF > "$GVM_DEST/$GVM_NAME/environments/system"
# Automatically generated file. DO NOT EDIT!
export GVM_ROOT; GVM_ROOT="$GVM_DEST/$GVM_NAME"
export gvm_go_name; gvm_go_name="system"
export gvm_pkgset_name; gvm_pkgset_name="global"
export GOROOT; GOROOT="$GOROOT"
export GOPATH; GOPATH="$GVM_DEST/$GVM_NAME/pkgsets/system/global"
export PATH; PATH="$GVM_DEST/$GVM_NAME/pkgsets/system/global/bin:$GOROOT/bin:\$GVM_ROOT/bin:\$PATH"
EOF
}

install_gvm(){
  BRANCH=${1:-master}
  GVM_DEST=${2:-$HOME}
  GVM_NAME="gvm"
  SRC_REPO=${SRC_REPO:-https://github.com/moovweb/gvm.git}

  [ "$GVM_DEST" = "$HOME" ] && GVM_NAME=".gvm"

  [ -d "$GVM_DEST/$GVM_NAME" ] && display_error \
      "Already installed! Remove old installation by running

      rm -rf $GVM_DEST/$GVM_NAME"

  [ -d "$GVM_DEST" ] || mkdir -p "$GVM_DEST" > /dev/null 2>&1 || display_error "Failed to create $GVM_DEST"
  command -v git >/dev/null || display_error "Could not find git

    debian/ubuntu: apt-get install git
    redhat/centos: yum install git
    mac:   brew install git
  "

  # Is gvm-installer being called from the origin repo?
  # If so, skip the clone and source locally!
  # This prevents CI from breaking on non-merge commits.

  GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

  if [[ -z "$GIT_ROOT" || "$(basename "$GIT_ROOT")" != "gvm" ]]
  then
    echo "Cloning from $SRC_REPO to $GVM_DEST/$GVM_NAME"

    git clone --quiet "$SRC_REPO" "$GVM_DEST/$GVM_NAME" 2> /dev/null ||
      display_error "Failed to clone from $SRC_REPO into $GVM_DEST/$GVM_NAME"
  else
    if [[ $GVM_DEST == *"$GIT_ROOT"* ]]
    then
      ln -s "$GIT_ROOT" "$GVM_DEST"
    else
      cp -r "$GIT_ROOT" "$GVM_DEST/$GVM_NAME"
    fi
  fi

  # GVM_DEST may be a non-relative path
  # i.e: gvm-installer master foo
  pushd . > /dev/null || exit

  cd "$GVM_DEST/$GVM_NAME" || exit

  git checkout --quiet "$BRANCH" 2> /dev/null || display_error "Failed to checkout $BRANCH branch"

  popd > /dev/null || exit

  [ -z "$GVM_NO_GIT_BAK" ] && mv "$GVM_DEST/$GVM_NAME/.git" "$GVM_DEST/$GVM_NAME/git.bak"

  source_file="${GVM_DEST}/$GVM_NAME/scripts/gvm"

  echo "export GVM_ROOT=$GVM_DEST/$GVM_NAME" > "$GVM_DEST/$GVM_NAME/scripts/gvm"
  echo ". \$GVM_ROOT/scripts/gvm-default" >> "$GVM_DEST/$GVM_NAME/scripts/gvm"
  check_existing_go
  # shellcheck source=/dev/null
  [[ -s "$GVM_DEST/$GVM_NAME/scripts/gvm" ]] && source "$GVM_DEST/$GVM_NAME/scripts/gvm"
  echo "Installed GVM v${GVM_VERSION}"
  echo
  echo "Please restart your terminal session or to get started right away run"
  echo " \`source ${source_file}\`"
  echo
}
