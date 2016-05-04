#!/bin/bash

# Usage
# cd Desktop
# ./install.sh 2>&1 | tee install.log
#

main_section_heading () {
    echo " "
    echo " "
    echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
    echo " $1"
    if [ -n "$2" ]; then
        # $2 is set to a non-empty string
        echo " $2"
    fi
    echo "======================================================================"
}

sub_section_heading () {
    echo " "
    echo " "
    echo "--- $1"
    echo "--------------------"
}


# ----------------------------------------------------------------------------------------------------
main_section_heading "Environment variables"
# ----------------------------------------------------------------------------------------------------
# Env variables used in the commands below

sub_section_heading "postgres"
set -x
# Edit the following to change the name of the database user that will be created:
POSTGRES_APP_DB_USER=postgres
POSTGRES_APP_DB_PASS=$POSTGRES_APP_DB_USER

# Edit the following to change the name of the database that is created (defaults to the user name)
# POSTGRES_APP_DB_NAME=${POSTGRES_APP_DB_USER}_unused

# Edit the following to change the version of PostgreSQL that is installed
PG_VERSION=9.5
set +x

sub_section_heading "git"
set -x
GIT_USER_EMAIL=""
GIT_USER_NAME=""
GIT_CREDENTIAL_HELPER_CACHE_TIMEOUT="86400"
set +x


# ----------------------------------------------------------------------------------------------------
main_section_heading "Dependencies"
# ----------------------------------------------------------------------------------------------------
set -x
cd ~/Downloads/
mkdir autoinstall
cd autoinstall

# For atom
sudo add-apt-repository -y ppa:webupd8team/atom

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev git

set +x
# ----------------------------------------------------------------------------------------------------
main_section_heading "emacs"
# ----------------------------------------------------------------------------------------------------
set -x
sudo apt-get -y install emacs
cd ~
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
# Revert back to previous directory
wget --quiet https://github.com/rudolfb/ubuntu-xenial-elixir-install-shell-script/raw/master/.spacemacs
cd -

# Add ~/.local/bin to the PATH if it does not exist
[[ ":$PATH:" != *":~/.local/bin:"* ]] && PATH="~/.local/bin:${PATH}"

# http://www.zohaib.me/spacemacs-and-alchemist-to-make-elixir-of-immortality/
# Need to ensure the dotspacemacs-configuration-layers looks similar to the following:

# auto-completion
# ;; better-defaults
# colors
# company-mode
# editorconfig
# elixir
# emacs-lisp
# erlang
# git
# html
# markdown
# org
# ;; (shell :variables
# ;;        shell-default-height 30
# ;;        shell-default-position 'bottom)
# ;; osx
# perspectives
# ;; spell-checking
# syntax-checking
# themes-megapack
# ;; version-control

# Then restart emacs

# Start emacs minimized so that while everything else is being
# installed the emacs packages can be downloaded in the background.
emacs --iconic &

set +x
# ----------------------------------------------------------------------------------------------------
main_section_heading "git"
# ----------------------------------------------------------------------------------------------------
set -x
if [ -n "${GIT_USER_EMAIL}" ]; then
    # "VAR is set to a non-empty string"
    git config --global user.email "$GIT_USER_EMAIL"
fi
if [ -n "${GIT_USER_EMAIL}" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi

if [ -n "${GIT_CREDENTIAL_HELPER_CACHE_TIMEOUT}" ]; then
    # Save your password in memory and set the cache time in minutes manually:
    git config --global credential.helper 'cache --timeout='$GIT_CREDENTIAL_HELPER_CACHE_TIMEOUT
    # Set the cache to timeout after x secconds
    # 86400 = 1 day
    # default is 15 minutes
fi


set +x
# ----------------------------------------------------------------------------------------------------
main_section_heading "nodejs 5.x"
# ----------------------------------------------------------------------------------------------------
set -x
curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
sudo apt-get install -y nodejs

set +x
# ----------------------------------------------------------------------------------------------------
main_section_heading "postgres and pgadmin"
# ----------------------------------------------------------------------------------------------------
set -x

###########################################################
# Changes below this line are probably not necessary
###########################################################

PG_REPO_APT_SOURCE=/etc/apt/sources.list.d/pgdg.list
if [ ! -f "$PG_REPO_APT_SOURCE" ]
then
    # Add PG apt repo:
    echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > "$PG_REPO_APT_SOURCE"

    # Add PGDG repo key:
    wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
fi


# Update package list and upgrade all packages
sudo apt-get update
sudo apt-get -y upgrade

sudo apt-get -y install "postgresql-$PG_VERSION" "postgresql-contrib-$PG_VERSION"
sudo apt-get -y install libpq-dev # For building ruby 'pg' gem
sudo apt-get -y install pgadmin3

PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_DIR="/var/lib/postgresql/$PG_VERSION/main"

# Edit postgresql.conf to change listen address to '*':
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

# Append to pg_hba.conf to add password auth:
sudo echo "host    all             all             all                     md5" >> "$PG_HBA"

# Explicitly set default client_encoding
sudo echo "client_encoding = utf8" >> "$PG_CONF"

# Restart so that all new config is loaded:
sudo service postgresql restart

cat << EOF | su - postgres -c psql
-- Create the database user:
CREATE USER $POSTGRES_APP_DB_USER PASSWORD '$POSTGRES_APP_DB_PASS' CREATEDB;
EOF

# cat << EOF | su - postgres -c psql
# -- Create the database:
# CREATE DATABASE $POSTGRES_APP_DB_NAME WITH OWNER=$POSTGRES_APP_DB_USER
#                                   LC_COLLATE='en_US.utf8'
#                                   LC_CTYPE='en_US.utf8'
#                                   ENCODING='UTF8'
#                                   TEMPLATE=template0;
# EOF

# Tag the provision time:


set +x
# ----------------------------------------------------------------------------------------------------
main_section_heading "elixir, incl. erlang"
# ----------------------------------------------------------------------------------------------------
set -x
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install esl-erlang
sudo apt-get install elixir


set +x
# ----------------------------------------------------------------------------------------------------
main_section_heading "phoenix"
# ----------------------------------------------------------------------------------------------------
set -x
mix local.hex --force
mix local.rebar --force
mix archive.install "https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez" --force


set +x
# ----------------------------------------------------------------------------------------------------
main_section_heading "elm"
# ----------------------------------------------------------------------------------------------------
set -x
sudo npm install -g elm
sudo npm install -g elm-oracle

# https://github.com/jmfirth/generator-elm-spa
npm install -g yo gulp
npm install -g generator-elm-spa


set +x
# ----------------------------------------------------------------------------------------------------
main_section_heading "atom"
# ----------------------------------------------------------------------------------------------------
set -x
# wget https://github.com/atom/atom/releases/download/v1.6.2/atom-amd64.deb
# sudo dpkg --install atom-amd64.deb
sudo apt-get -y install atom
apm install  autocomplete-elixir elm-format file-icons git-plus html-to-elm language-elixir language-elm language-lisp linter linter-elixirc linter-xmllint merge-conflicts minimap project-manager refactor regex-railroad-diagram split-diff tabs-to-spaces trailing-spaces xml-formatter


set +x
# ----------------------------------------------------------------------------------------------------
main_section_heading "Check the version numbers to test the installations"
# ----------------------------------------------------------------------------------------------------

sub_section_heading "git"
echo "git --version"
git --version
echo "git config --list"
git config --list

sub_section_heading "node"
echo "node --version"
node --version

sub_section_heading "postgres"
echo "psql --version"
psql --version

sub_section_heading "erlang"
echo "cat /usr/lib/erlang/releases/RELEASES"
cat /usr/lib/erlang/releases/RELEASES

sub_section_heading "elixir"
echo "elixir --version"
elixir --version

sub_section_heading "phoenix"
if [ $(strings ~/.mix/archives/phoenix_new.ez | grep -co '{vsn,') = 0 ]; then
    echo "Error: unable to find installed phoenix"
else
    echo "mix help phoenix.new"
    mix help phoenix.new | sed -e 3b -e '$!d'
    strings ~/.mix/archives/phoenix_new.ez | grep '{vsn,'
fi

sub_section_heading "elm"
if [ $(elm | grep -co 'Elm Platform') = 0 ]; then
    echo "Error: unable to find installed elm"
else
    echo "elm"
    elm | sed -e 1b -e '$!d'
fi

sub_section_heading "emacs"
echo "emacs --version"
emacs --version
echo "Enter 'emacs' in a shell to start emacs."

sub_section_heading "atom"
echo "atom --version"
atom --version
echo "Enter 'atom' in a shell to start atom."


# ----------------------------------------------------------------------------------------------------
main_section_heading "End"
# ----------------------------------------------------------------------------------------------------
