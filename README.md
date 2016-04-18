# ubuntu-xenial-elixir-install-shell-script
Shell script that automates install of Elixir, Erlang, Node 5.x, Postgres, pgadmin, Phoenix, Elm, Atom, emacs (spacemacs) incl. elixir mode and alchemist

# Usage
Copy the file to the Desktop, for example.

```shell
cd Desktop
./install.sh > install.log
```

You will be required to enter your superuser password when the first `sudo` is referenced in the script.

Do _**not**_ start the script as follows:

```shell
sudo ./install.sh
```

This will start the entire script as a superuser, and any downloaded files will have superuser permissions. The current user will not have permissions for these files and parts of the installation will fail.

# References

http://www.zohaib.me/spacemacs-and-alchemist-to-make-elixir-of-immortality/

https://github.com/kiere/vagrant-phoenix-postgres

# Useful commands

### List the installed packages

sudo dpkg -l
