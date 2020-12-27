# dotfiles

This repo is a little more than the traditional set of configuration files. It's designed to actually get a pretty bare-bones machine to the state I like for development. To do this it not only links in the set of config files but also installs the relevant software, any environment customizations and builds. It also works on macos and Ubuntu (and minor testing on Redhat), and has hooks in this repo to pull in an equivalent set of work-specific actions.

## Setup Action Structure

The setup script runs a  number of *actions* which are organized into *groups* and which themselves use a set of functions provided by a common library for installing packages, linking files, etc. This structure is shown below, the top level contains the main `setup.zsh` script and a directory named `actions`. Below this directory are a set of directories that start with two digits and which are the *setup groups*. The setup group `00` is reserved for library files initialized by `setup.zsh`. Within these group directories are *actions*, again directories starting with two digits and which should install, configure, or link files, for a single package or tool. Each *setup action* must have a script with the name `ACTION.sh` which will be executed by the setup script, it may then contain any other files it needs to link into place.

```
$
|-- setup.zsh
'-- actions
    |-- 00
    |   |-- common.zsh
    |   '-- logging.zsh
	|--01-os
	|  |--01-zsh
	|  |  |-- ACTION.sh
	|  |  |-- dot-zshenv
	|  |  '-- dot-zshrc
	:  :
```

An example `ACTION.sh` is shown below for configuring emacs, using functions from the library for all actions. These library functions contain checks, logging, and other features and so should always be used instead of raw shell commands.

```bash
EMACS_CONF=$HOME/.emacs.d

if [[ $ACTION = (install|update) ]] ; then
	install_package_for linux emacs-nox elpa-racket-mode
	install_package_for macos emacs
	install_package_for macos -app font-linux-libertine
fi

if [[ $ACTION = (install|update|link) ]] ; then
    make_dir $EMACS_CONF/lib
	link_file init.el $EMACS_CONF/init.el

	run_command curl -o $EMACS_CONF/lib/scribble.el "https://www.neilvandyke.org/scribble-emacs/scribble.el"
fi
```

## Running setup

```zsh
$ git clone https://github.com/johnstonskj/dotfiles.git
$ ...
$ cd dotfiles
$ ./setup.zsh -h
NAME
	setup.zsh - setup environment, cross-platform
SYNOPSIS
	setup.zsh [-h -i -l -u -s -v -V] [group/item]
DESCRIPTION
	-h	show help
	-i	run all install actions
	-l	link files only
	-u	upgrade only actions
	-s  show available actions
	-v	verbose mode
	-V  very verbose mode
```

The three options `-i`, `-l`, and `-u` determine how much of the script is run. Link *only* creates any required symlinks for dot-files, upgrade will upgrade any installed packages (and create symlinks), and install will install new packages (and create symlinks). The `-s` option will list the hierarchy of actions so that you can run setup for just a single action.

## Library Functions & Variables

* **Variables**
  * `ACTION` - the current action, one of: 'install', 'update', 'link'.
  * `ACTION_ARGS` - any arguments required by the action, usually the group/action path.
  * `ACTION_FILE` - the name of the file to look for in the action directory, by default this is `ACTION.sh`.
  * `INSTALLER` `APP_INSTALLER` `UPDATER` - the O/S dependent name of the installer commands to use.
  * `LOCAL_BIN` - local directory to store binaries.
  * `LOCAL_CONFIG` - local directory for config files.
  * `LOCAL_DOWNLOADS` - local directory for downloads and temporary files.
  * `OPSYS` - operating system, e.g. 'macos', 'linux', 'windows'.
  * `OSARCH` `OSDIST` `OSVERSION` - operating system architecture, distribution, and version.
  * `LOGLEVEL` - level to log messages, `setup.zsh` sets this with the `-v` and `-V` options.
* **Logging**
  * `log-critical` - log a critical error, this will terminate the setup.
  * `log-error`  - log an error.
  * `log-warning` - log a warning.
  * `log-info` - log informational message.
  * `log-debug` - log a debugging message.
  * `echo_bright` - echo to standard outbut in a bright color.
  * `echo_instruction` - echo an instruction to the standard output.
* **Actions**
  * `install_package` - install a package using the O/S specific installer.
  * `install_package_for` - install a package, for a given O/S only.
  * `link_env_file` - link an `env` file into the config directory.
  * `link_file`  - create a symlink for a file in this repo to it's local location.
  * `make_dir` - make a local directory.
  * `remove_file` - remove a local file.
  * `run_command` - run any command not covered above.
