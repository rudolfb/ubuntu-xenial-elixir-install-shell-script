# ubuntu-xenial-elixir-install-shell-script
Shell script that automates install of Elixir, Erlang, Node 5.x, Postgres, pgadmin, Phoenix, Elm, Atom

# Usage
Copy the file to the Desktop, for example.

```
cd Desktop
./install.sh > install.log
```

You will be required to enter your superuser password when the first sudo is referenced in the script.

Do *NOT* start the script as follows:

```
sudo ./install.sh
```

This will start the entire script as a superuser, and any downloaded files will have superuser permissions. The current user will not have permissions for these files.
