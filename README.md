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

# Problem with the script

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

# References

http://www.zohaib.me/spacemacs-and-alchemist-to-make-elixir-of-immortality/

https://github.com/kiere/vagrant-phoenix-postgres

# Useful commands

### List the locally installed packages

```shell
sudo dpkg -l
```
