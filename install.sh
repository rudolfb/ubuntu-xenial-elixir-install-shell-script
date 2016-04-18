*+-usr-bin-env bash

echo on

cd ~/Downloads/
mkdir autoinstall
cd autoinstall

echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo "| Dependencies                                                        |"
echo "======================================================================"

# For atom
sudo add-apt-repository -y ppa:webupd8team/atom

sudo apt-get -y update
sudo apt-get -y install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev git
# libgtk2.0-0 libgtk2.0-bin libgtk2.0-common

# Problem installing esl-erlang.
# Standard installation methods for libwxbase fail.
# http://packages.ubuntu.com/search?suite=default&section=all&arch=any&keywords=libwxbase&searchon=names
# Even after the explicit installation of libwxbase3.0-0v5 the dependencies are not resolved, so
# this forces us to manually install libwxbase3 and libwxgtk3.
wget http://archive.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxbase3.0-0_3.0.2-1_amd64.deb
yes Y | sudo dpkg -i libwxbase3.0-0_3.0.2-1*.deb
yes Y | sudo apt-get -fy install

wget http://archive.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxgtk3.0-0_3.0.2-1_amd64.deb
yes Y | sudo dpkg -i libwxgtk3.0-0_3.0.2-1*.deb
yes Y | sudo apt-get -fy install

echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo "| nodejs 5.x                                                         |"
echo "======================================================================"

curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo "| postgres and pgadmin                                               |"
echo "======================================================================"

# Edit the following to change the name of the database user that will be created:
APP_DB_USER=postgres
APP_DB_PASS=$APP_DB_USER

# Edit the following to change the name of the database that is created (defaults to the user name)
# APP_DB_NAME=${APP_DB_USER}_unused

# Edit the following to change the version of PostgreSQL that is installed
PG_VERSION=9.5

###########################################################
# Changes below this line are probably not necessary
###########################################################
print_db_usage () {
  echo "Your PostgreSQL database has been setup and can be accessed on your local machine on the forwarded port (default: 5432)"
  echo "  Host: localhost"
  echo "  Port: 5432"
  echo "  Database: <DATABASE_NAME>"
  echo "  Username: $APP_DB_USER"
  echo "  Password: $APP_DB_PASS"
  echo ""
  echo "Admin access to postgres user via VM:"
  echo "  vagrant ssh"
  echo "  sudo su - postgres"
  echo ""
  echo "psql access to app database user via VM:"
  echo "  vagrant ssh"
  echo "  sudo su - postgres"
  echo "  PGUSER=$APP_DB_USER PGPASSWORD=$APP_DB_PASS psql -h localhost <DATABASE_NAME>"
  echo ""
  echo "Env variable for application development:"
  echo "  DATABASE_URL=postgresql://$APP_DB_USER:$APP_DB_PASS@localhost:5432/<DATABASE_NAME>"
  echo ""
  echo "Local command to access the database via psql:"
  echo "  PGUSER=$APP_DB_USER PGPASSWORD=$APP_DB_PASS psql -h localhost -p 5432 <DATABASE_NAME>"
}

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
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

# Append to pg_hba.conf to add password auth:
echo "host    all             all             all                     md5" >> "$PG_HBA"

# Explicitly set default client_encoding
echo "client_encoding = utf8" >> "$PG_CONF"

# Restart so that all new config is loaded:
service postgresql restart

cat << EOF | su - postgres -c psql
-- Create the database user:
CREATE USER $APP_DB_USER PASSWORD '$APP_DB_PASS' CREATEDB;
EOF

# cat << EOF | su - postgres -c psql
# -- Create the database:
# CREATE DATABASE $APP_DB_NAME WITH OWNER=$APP_DB_USER
#                                   LC_COLLATE='en_US.utf8'
#                                   LC_CTYPE='en_US.utf8'
#                                   ENCODING='UTF8'
#                                   TEMPLATE=template0;
# EOF

# Tag the provision time:

echo "Successfully created PostgreSQL dev virtual machine."
echo ""
print_db_usage

echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo "| elixir, incl. erlang                                               |"
echo "======================================================================"

wget http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc
sudo apt-key add erlang_solutions.asc
# There is as of now no erlang download for xenial, so we have to hard code wily.
sudo add-apt-repository "deb http://packages.erlang-solutions.com/ubuntu wily contrib"
# sudo add-apt-repository "deb http://packages.erlang-solutions.com/ubuntu $(lsb_release -s -c) contrib"
sudo apt-get update
yes Y | sudo apt-get -y install esl-erlang
sudo apt-get -y install elixir

echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo "| phoenix                                                            |"
echo "======================================================================"

mix local.hex --force
mix local.rebar --force
mix archive.install "https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez" --force

echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo "| elm                                                                |"
echo "======================================================================"

sudo npm install -g elm

echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo "| emacs                                                              |"
echo "======================================================================"

sudo apt-get -y install emacs
cd ~
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
# Revert back to previous directory
cd -

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

echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo "| atom                                                                |"
echo "======================================================================"

# wget https://github.com/atom/atom/releases/download/v1.6.2/atom-amd64.deb
# sudo dpkg --install atom-amd64.deb
sudo apt-get -y install atom
apm install  autocomplete-elixir elm-format file-icons git-plus html-to-elm language-elixir language-elm language-lisp linter linter-elixirc linter-xmllint merge-conflicts minimap project-manager refactor regex-railroad-diagram split-diff tabs-to-spaces trailing-spaces xml-formatter

echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo "| check the version numbers to test the installations                |"
echo "======================================================================"

echo " "
echo " "
echo "--- git"
echo "--------------------"
echo "git --version"
git --version
echo " "
echo " "
echo "--- node"
echo "--------------------"
echo "node --version"
node --version
echo " "
echo " "
echo "--- postgres"
echo "--------------------"
echo "psql --version"
psql --version
echo " "
echo " "
echo "--- erlang"
echo "--------------------"
echo "cat /usr/lib/erlang/releases/RELEASES"
cat /usr/lib/erlang/releases/RELEASES
echo " "
echo " "
echo "--- elixir"
echo "--------------------"
echo "elixir --version"
elixir --version
echo " "
echo " "
echo "--- phoenix"
echo "--------------------"
echo "mix help phoenix.new"
if [ $(strings ~/.mix/archives/phoenix_new.ez | grep -co '{vsn,') = 0 ]; then
  echo "Error: unable to find installed phoenix"
else
  mix help phoenix.new | sed -e 3b -e '$!d'
  strings ~/.mix/archives/phoenix_new.ez | grep '{vsn,'
fi
echo " "
echo " "
echo "--- elm"
echo "--------------------"
echo "elm"
if [ $(elm | grep -co 'Elm Platform') = 0 ]; then
  echo "Error: unable to find installed elm"
else
  elm | sed -e 1b -e '$!d'
fi
echo " "
echo " "
echo "--- atom"
echo "--------------------"
echo "Check to see if atom is opened"
atom
echo " "
echo " "

echo "vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"
echo "| end                                                                |"
echo "======================================================================"

# Setting up git

# git config --global user.email "you@example.com"
# git config --global user.name "Your Name"

# Save your password in memory for a default of 15 minutes:
# git config --global credential.helper cache

# Save your password in memory and set the cache time in minutes manually:
# git config --global credential.helper 'cache --timeout=3600'
# Set the cache to timeout after 1 hour (setting is in seconds)



