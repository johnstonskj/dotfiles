# -*- mode: sh; eval: (sh-set-shell "zsh") -*-

############################################################################
# Config stuff
############################################################################

OSSYS=`uname -s | tr '[:upper:]' '[:lower:]'`
OSDIST=
OSVERSION=`uname -r`
OSARCH=`uname -m`
INSTALLER=
APP_INSTALLER=
UPDATER=
LOCAL_BIN=$HOME/bin
LOCAL_CONFIG=$HOME/.config
LOCAL_DOWNLOADS=$HOME/Downloads

ACTION=install
ACTION_ARGS=

ACTION_FILE=ACTION.sh

############################################################################
# Pre-install stuff
############################################################################

link_self_bin() {
	if [[ ! -f "$LOCAL_BIN/$CMD_FILE" ]] ; then
		run_command ln -s "$DOTFILEDIR/$CMD_FILE" "$LOCAL_BIN/$CMD_FILE"
	fi
}

check_not_sudo() {
  if [[ $UID == 0 || $EUID == 0 ]]; then
    log-critical "Cannot run as root, run with -h for options"
  fi
}

decode_os_type() {
  case $OSSYS in
	darwin)
    STDOUT=$(defaults read loginwindow SystemVersionStampAsString)
    if [[ $? -eq 0 ]] ; then
      OSSYS=macos
      OSVERSION=$STDOUT
    fi
    ;;
	linux)
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
      OSDIST=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'// | tr '[:upper:]' '[:lower:]')
    else
      # Otherwise, use release info file
      OSDIST=$(ls -d /etc/[A-Za-z]*[_-]\(version|release\) | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1 | grep -v system | tr '[:upper:]' '[:lower:]')
    fi
    ;;
	msys*)
    OSSYS=windows
    OSVERSION=`ver | cut - d [ -f 2 | cut -d ] -f 1 | cut -d ' ' -f 2`
    ;;
	*)
    log-error "Unknown OS $OSSYS unsupported"
    ;;
  esac

  if [[ $OSSYS = macos ]] ; then
		INSTALLER=brew
		APP_INSTALLER=(brew)
		UPDATER=upgrade
  elif [[ $OSSYS = linux ]] ; then
		STDOUT=$(yum --version 2>&1)
		if [[ $? -eq 0 ]] ; then
      log-debug "You appear to be running a redhat derived Linux"
      INSTALLER=(sudo yum --assumeyes)
      APP_INSTALLER=flatpack
		else
      STDOUT=$(apt --version 2>&1)
      if [[ $? -eq 0 ]] ; then
				log-debug "You appear to be running a debian derived Linux"
				INSTALLER=(sudo apt --assume-yes)
				APP_INSTALLER=snap
				UPDATER=upgrade
      else
				log-critical "No known installer (yum|apt-get) found"
      fi
		fi
  fi

  if [ ! -d "$LOCAL_DOWNLOADS" ] ; then
    make_dir $LOCAL_DOWNLOADS
  fi
}

############################################################################
# Command-line stuff
############################################################################

parse_command_line() {
  case $1 in
  help)
		ACTION=help;;
	install)
		ACTION=install;;
	update-self)
		ACTION=update-self;;
	update)
		ACTION=update;;
	remove)
		ACTION=uninstall;;
	link)
		ACTION=link;;
	group)
		ACTION=cfg-groups;;
	action)
		ACTION=cfg-actions;;
	list)
		ACTION=list;;
	-w)
		DOTFILEDIR=$WORKDOTFILEDIR;
		ACTIONDIR=$WORKACTIONDIR;
		shift;
        parse_command_line $*;;
	-v)
    LOGLEVEL=3;
		shift;
        parse_command_line $*;;
	-V)
    LOGLEVEL=4;
		shift;
        parse_command_line $*;;
	*)
	  log-error "Error: unknown command: $1."
		ACTION=help;;
  esac
  ACTION_ARGS=(${@:2:4})
}

############################################################################
# Drivers
############################################################################

run_inner_command() {
	log-debug "ACTION=$ACTION, ACTION_ARGS='${ACTION_ARGS[@]}' (${#ACTION_ARGS})"
	log-debug "DOTFILEDIR=$DOTFILEDIR, ACTIONDIR=$ACTIONDIR"
	case $ACTION in
	install|update|uninstall|link)
		cmd_install;;
	update-self)
		cmd_update_self;;
	list)
		cmd_list_actions;;
	cfg-groups)
		cmd_manage_groups;;
	cfg-actions)
		cmd_manage_actions;;
	execute)
		cmd_exec_sub_command;;
	*)
		cmd_help;;
	esac
}

cmd_help() {
	echo_bright "NAME";
	echo "\t$CMD_FILE - setup environment, cross-platform";
	echo_bright "SYNOPSIS";
	echo "\t$CMD_FILE [-v -V] COMMAND";
	echo_bright "DESCRIPTION";
	echo "Run commands to ensure consistency of machine environment across machines."
	echo "Do not run this command in sudo mode, it will ask for passwords when it needs them"
	echo ""
	echo "\t-w\tuse the work, not common, configuration"
	echo "\t-v\tverbose mode";
	echo "\t-V\tvery verbose mode";
	echo_bright "COMMANDS";
	echo "\thelp\tshow help";
	echo "\tinstall\tinstall actions (default)";
	echo "\tupdate\tupdate actions";
	echo "\tremove\tremove actions";
	echo "\tlink\tlink files only";
	echo "\tlist\tlist actions";
	echo "\tgroup\tmanage groups";
	echo "\taction\tmanage actions";
	echo "\tupdate-self\tupdate local configuration repositories";
	exit 0
}

cmd_list_actions() {
	for gdir in $ACTIONDIR/0*; do
		if [[ ! $gdir:t = "00" && -d $gdir ]] ; then
			for idir in $gdir/*; do
				if [[ -d $idir && -e $idir/$ACTION_FILE ]] ; then
		 			echo "$gdir:t/$idir:t"
		 		fi
			done
 		fi
	done
	exit 0
}

cmd_manage_groups() {
	case $ACTION_ARGS[1]
	in
	new)
		if [[ ${#ACTION_ARGS} -ge 2 ]] ; then
			local new_name="$ACTION_ARGS[2]"
			if [[ "$new_name" = "" ]] ; then
				log-critical "Specify a new group name."
			elif [[ $new_name =~ "/" ]] ; then
				log-error "Group name may not be a path."
			elif [[ ! $new_name =~ "^[0-9]+\-" ]] ; then
				log-error "Group names should start with two digits."
			else
				make_dir "$ACTIONDIR/$new_name"
			fi
		else
			log-error "New group name required."
		fi;;
	list) 
		for gdir in $ACTIONDIR/0*; do
			if [[ ! $gdir:t = "00" && -d $gdir ]] ; then
				echo "$gdir:t"
			fi
		done;;
	*) 
		cmd_help;;
	esac
}

cmd_manage_actions() {
	log-info "manage action $ACTION_ARGS"
	case $ACTION_ARGS[1]
	in
	new)
		if [[ ${#ACTION_ARGS} -ge 3 ]] ; then
			local group="$ACTIONDIR/$ACTION_ARGS[2]"
			local new_name="$ACTION_ARGS[3]"
			if [[ ! -d $group ]] ; then
				log-error "Group $group is not a group folder."
			elif [[ "$new_name" = "" ]] ; then
				log-critical "Specify a new action name."
			elif [[ $new_name =~ "/" ]] ; then
				log-error "Action name may not be a path."
			elif [[ ! $new_name =~ "^[0-9]+\-" ]] ; then
				log-error "Action names should start with two digits."
			else
				make_dir "$group/$new_name"
				if [[ ! -e "$group/$new_name/$ACTION_FILE" ]] ; then
					echo "# -*- mode: sh; eval: (sh-set-shell \"zsh\") -*-\n# Action file for $new_name" > "$group/$new_name/$ACTION_FILE"
				fi
				$VISUAL "$group/$new_name/$ACTION_FILE"
			fi
		else
			log-error "New action name required."
		fi;;
	edit)
		if [[ ${#ACTION_ARGS} -ge 3 ]] ; then
			local action_file="$ACTIONDIR/$ACTION_ARGS[2]/$ACTION_ARGS[3]/$ACTION_FILE"
			log-debug $action_file
			if [[ ! -f $action_file ]] ; then
				log-error "No action file for group $ACTION_ARGS[2], action $ACTION_ARGS[3]."
			else
				$VISUAL "$action_file"
			fi
		else
			log-error "New action name required."
		fi;;
	list) 
		if [[ ${#ACTION_ARGS} -ge 2 ]] ; then
			local gdir="$ACTIONDIR/$ACTION_ARGS[2]"
			if [[ ! $gdir:t = "00" && -d $gdir ]] ; then
				for idir in $gdir/*; do
					if [[ -d $idir && -e $idir/$ACTION_FILE ]] ; then
			 			echo "$gdir:t/$idir:t"
			 		fi
				done
			fi
		else
			log-error "Group name to list required."
		fi;;
	*) 
		cmd_help;;
	esac
}

cmd_update_self () {
	log-info "Updating self"
	if [[ -d $DOTFILEDIR ]] ; then
		log-debug "+ pulling latest common repo in $DOTFILEDIR"
		pushd $DOTFILEDIR
		run_command git pull --rebase
		popd
	fi
	if [[ -d $WORKDOTFILEDIR ]] ; then
		log-debug "+ pulling latest common repo in $WORKDOTFILEDIR"
		pushd $WORKDOTFILEDIR
		run_command git pull --rebase
		popd
	fi
}

cmd_install () {
  log-info "Performing install $ACTION on $OSSYS ($OSTYPE), DIST=$OSDIST, VERSION=$OSVERSION, ARCH=$OSARCH"
  log-info "Using install=$INSTALLER, app=$APP_INSTALLER, update=$UPDATER"
  log-info "Using download file dir $LOCAL_DOWNLOADS"
	make_dir $LOCAL_DOWNLOADS
  log-info "Using binary file dir $LOCAL_BIN"
  make_dir $LOCAL_BIN
  log-info "Using configuration dir $LOCAL_CONFIG"
  make_dir $LOCAL_CONFIG

	if [[ -f "$ACTIONDIR/$ACTION_ARGS/$ACTION_FILE" ]] ; then
		cmd_install_actions "$ACTIONDIR/$ACTION_ARGS"
	elif [[ "$ACTION_ARGS" == "" ]] ; then
		log-info "Enumerating action groups in $ACTIONDIR"
		for dir in $ACTIONDIR/0*; do
			if [[ ! $dir:t = "00" && -d $dir ]] ; then
				log-info "Enumerating action group: $dir"
	 			cmd_install_groups $dir
	 		fi
		done
	else
		log-error "Specified action $ACTION_ARGS not found in $ACTIONDIR."
	fi
}

cmd_install_groups () {
	for dir in $1/0*; do
		if [[ -d $dir ]] ; then
			log-info "Checking action item: $dir"
 			cmd_install_actions $dir
 		fi
	done
}

cmd_install_actions () {
	if [[ -e $1/$ACTION_FILE ]] ; then
		CURR_ACTION=$1
		log-info "Running actions in: $CURR_ACTION/$ACTION_FILE"
		source "$CURR_ACTION/$ACTION_FILE"
	fi
}

cmd_exec_sub_command() {
	log-error "currently unsupported"
}

############################################################################
# Actions
############################################################################

run_command() {
  log-debug "+++ +++ executing: ${(j. .)@}"
  errfile=$(mktemp)
  out=$($@ 2>|"$errfile" )
  err=$(< "$errfile")
  rm "$errfile"

  res=("${(@f)out}")
  for s in $res; do log-debug ">>> $s"; done
  res=("${(@f)err}")
  for s in $res; do log-warning ">>> $s"; done
}

install_package_for() {
  if [[ $OSSYS = $1* ]] ; then
    log-debug "+++ O/S match: $1"
		shift
		install_package $@
	else
		log-debug "+++ skipping $ACTION, not O/S $1"
  fi
}

install_package() {
  if [[ $ACTION = (install|update|uninstall) ]] ; then
		local _action=$ACTION
		if [[ $ACTION = update && $UPDATER != "" ]] ; then
		    _action=$UPDATER
		fi
		log-debug "+++ performing $_action for ${(j. .)@}"
		case $1	in
    -app)
      shift;
      if [[ $OSSYS = macos ]] ; then
        run_command $APP_INSTALLER $_action --cask $@
      else
        run_command $APP_INSTALLER $_action $@
      fi
      ;;
    -python)
      shift;
      run_command conda $ACTION --yes $@
      ;;
    -racket)
      shift;
      run_command raco pkg $ACTION --deps search-auto $@
      ;;
    *)
      run_command $INSTALLER $_action $@ ;;
		esac
  fi
}

make_dir() {
  if [[ -e $1 ]] ; then
    if [[ ! -d $1 ]] ; then
      log-error "Name $1 exists, but is not a directory."
    else
      log-warning "Directory $1 already exists."
    fi
  else
    log-debug "Making new directory $1"
    run_command mkdir -p $1
  fi
}

remove_dir() {
	if [[ -e "$1" && -d "$1" ]] ; then
		log-debug "Removing directory $1."
		run_command rmdir "$1"
	else
		log-warning "Directory $1 does not exist, or name is not a directory."
	fi
}

remove_file() {
	if [[ -e "$1" && -f "$1" ]] ; then
		log-debug "Removing file $1."
		run_command rm "$1"
	else
		log-warning "File $1 does not exist, or name is not a file."
	fi
}

link_bin_file() {
	if [[ $ACTION = (install|update|link) ]] ; then
		link_file "$1" "$LOCAL_BIN/$1"
	elif [[ $ACTION = (uninstall) ]] ; then
		remove_file "$LOCAL_BIN/$1"
	fi
}

link_env_file() {
	if [[ $ACTION = (install|update|link) ]] ; then
		make_dir "$LOCAL_CONFIG/$1"
		link_file "$1-env" "$LOCAL_CONFIG/$1/env"
	elif [[ $ACTION = (uninstall) ]] ; then
		remove_file "$LOCAL_CONFIG/$1/env"
		remove_dir "$LOCAL_CONFIG/$1"
	fi
}

link_aliases_file() {
	if [[ $ACTION = (install|update|link) ]] ; then
		make_dir "$LOCAL_CONFIG/$1"
		link_file "$1-aliases" "$LOCAL_CONFIG/$1/aliases"
	elif [[ $ACTION = (uninstall) ]] ; then
		remove_file "$LOCAL_CONFIG/$1/aliases"
		remove_dir "$LOCAL_CONFIG/$1"
	fi
}

link_file() {
    if [[ $ACTION = (install|update|link) ]] ; then
		if [[ -e "$CURR_ACTION/$1" ]] ; then
		    run_command ln -s "$CURR_ACTION/$1" "$2"
		else
		    log-warning "file $1 doesn't exist in $CURR_ACTION."
		fi
	elif [[ $ACTION = (uninstall) ]] ; then
		remove_file "$2"
    fi
}
