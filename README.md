# dotfiles

Configuration files for multiple machines, work and home, Linux and MacOS. Currently
the Linux support is reasonably well tested on Ubuntu (18.10) and a started on Red Hat.

## Running setup

```zsh
$ git clone https://github.com/johnstonskj/dotfiles.git
$ ...
$ cd dotfiles
$ ./setup.zsh -h
NAME
	setup.zsh - setup environment, cross-platform
SYNOPSIS
	setup.zsh [-v] [-i -u -l -h]
DESCRIPTION
	-h	show help
	-i	run all install actions
	-l	link files only
	-u	upgrade only actions
	-s  show available actions
	-v	verbose mode
```

The three options `-i`, `-l`, and `-u` determine how much of the script is run. Link
*only* creates any required symlinks for dot-files, upgrade will upgrade any installed
packages (and create symlinks), and install will install new packages (and create
symlinks).

## Setup files

* `setup.zsh` - setup environment for MacOS, Ubuntu, (and some Red Hat) development.
* `actions/` - folder for groups and individual install structures.