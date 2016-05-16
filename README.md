# ubuntu-xenial-elixir-install-shell-script
Shell script that automates install of Elixir, Erlang, Node 5.x, Postgres, pgadmin, Phoenix, Elm, Atom, emacs (spacemacs) incl. elixir mode and alchemist.

# Usage

## Warning

**This script is designed for initial installation on a clean system. It is not designed to recognize if software has already been installed or system settings have already been changed.**

In some cases it does not matter if the script is executed on a system with software installed (most of the `apt-get install` ought to be safe), but the Postgres or Emacs install might overwrite existing files.

## Installation

- Copy the `install.sh` to the Desktop, for example.

- Assign the file `install.sh` the permission `Allow executing file as program`.

- Open the file with a text editor, search for `GIT_USER_EMAIL` and `GIT_USER_NAME`, enter the appropriate values and save the changes.

- Open a terminal window
```shell
cd Desktop
./install.sh 2>&1 | tee install.log
```

You will be required to enter your superuser password when the first `sudo` is referenced in the script.

The `... 2>&1 | tee ...` redirects both stdout and stderr to a file and the stdout. You can follow the installation in the terminal, but the terminal output is also saved to the file `install.log` in the same folder as the `install.sh`.

Do _**not**_ start the script as follows:

```shell
sudo ./install.sh
```

This will start the entire script as a superuser, and any downloaded files will have superuser permissions. The current user will not have permissions for these files and parts of the installation will fail.

# Manual patches

### [Sublime Elm Language Package](https://github.com/deadfoxygrandpa/Elm.tmLanguage)

The current package does not support the new module syntax introduced in Elm 0.17.0 .

Elm 0.16: module Queue (..) where
Elm 0.17: module Queue exposing (..)

There is a patch for this, but has, as of 16. May 2016, not been integrated into master. It is however, easy to patch.

https://github.com/deadfoxygrandpa/Elm.tmLanguage/pull/101
https://github.com/deadfoxygrandpa/Elm.tmLanguage/pull/101/commits/a6c6df00bff7fd1ef16f70b528e13e33838a1abd

Navigate to the local folder

~/.config/sublime-text-3/Packages/Elm Language Support/Syntaxes

and modify the files `Elm.YAML-tmLanguage` and `Elm.tmLanguage` manually.

https://raw.githubusercontent.com/ThomasWeiser/Elm.tmLanguage/a6c6df00bff7fd1ef16f70b528e13e33838a1abd/Syntaxes/Elm.YAML-tmLanguage

https://raw.githubusercontent.com/ThomasWeiser/Elm.tmLanguage/a6c6df00bff7fd1ef16f70b528e13e33838a1abd/Syntaxes/Elm.tmLanguage



# Reasons for specific implemetaions

#### Elixir
Even though the [Elixir Installation](http://elixir-lang.org/install.html) notes mention that you can install Elixir on Ubuntu using

```
sudo apt-get install elixir
```
there is a problem using this method. According to the following [reference](http://packages.ubuntu.com/xenial/elixir) the version that is installed using `apt-get` is **elixir (1.1.0~0.20150708-1)**, which is suboptimal. This install script thus downloads and installs the latest precompiled build from github.

###### Update, 5. May 2016
This issue no longer exists, and the standard installation procedure for Ubuntu documented on the elixir-lang website works fine again.

#### Atom
Atom on Ubuntu currently does not auto-update, as it does on Mac and Windows. It is possible to download a new version, double click on the file and let Ubuntu perform the update, but the repo **ppa:webupd8team/atom** is kept up to date and automates the update whenever a `sudo apt-get upgrade` is executed.

# Problem with the script

#### esl-erlang not installing correctly
The script has a problem installing `esl-erlang`.

```
+ sudo apt-get -y install erlang-mode esl-erlang
Reading package lists...
Building dependency tree...
Reading state information...
Some packages could not be installed. This may mean that you have
requested an impossible situation or if you are using the unstable
distribution that some required packages have not yet been created
or been moved out of Incoming.
The following information may help to resolve the situation:

The following packages have unmet dependencies:
 esl-erlang : Depends: libwxbase2.8-0 but it is not installable or
                       libwxbase3.0-0 but it is not installable
              Depends: libwxgtk2.8-0 but it is not installable or
                       libwxgtk3.0-0 but it is not installable
E: Unable to correct problems, you have held broken packages.
```

Even though there is this error, the installation completes successfully, and Elxir and Erlang can both be opened. There might however be some issues using Erlang tools that require these packages.

###### Update, 27. April 2016
I no longer see this error in the installation log on xenial.

# References

http://www.zohaib.me/spacemacs-and-alchemist-to-make-elixir-of-immortality/

https://github.com/kiere/vagrant-phoenix-postgres

# Useful commands

#### List the locally installed packages

```shell
sudo dpkg -l
```

#### List the locally installed packages and find some packages

```shell
sudo dpkg -l | grep erlang
```

#### Get top level global npm packages

```shell
npm -g list --depth=0
```

### When were which packages installed

```shell
subl /var/log/apt/history.log
```


