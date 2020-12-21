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
DOWNLOADS=$HOME/Downloads
LOCAL_BIN=$HOME/bin
LOCAL_CONFIG=$HOME/.config

ACTION=install
ACTION_ARGS=

ACTION_FILE=ACTION.sh

############################################################################
# Pre-install stuff
############################################################################

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
			OSDIST=$(ls -d /etc/[A-Za-z]*[_-](version|release) | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1 | grep -v system | tr '[:upper:]' '[:lower:]')
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

    if [ ! -d "$DOWNLOADS" ] ; then
		run_command mkdir $DOWNLOADS
    fi
}

############################################################################
# Command-line stuff
############################################################################

parse_action() {
    case $1
    in
	-h)  echo_bright "NAME";
	     echo "\tsetup.zsh - setup environment, cross-platform";
	     echo_bright "SYNOPSIS";
	     echo "\tsetup.zsh [-v -V] [-i -u -l -s -h]";
	     echo_bright "DESCRIPTION";
             echo "\t-h\tshow help";
             echo "\t-i\trun all install actions (default)";
             echo "\t-l\tlink files only";
             echo "\t-u\tupgrade only actions";
             echo "\t-s\tshow actions";
             echo "\t-v\tverbose mode";
             echo "\t-V\tvery verbose mode";
	     echo "\nDo not run this command in sudo mode, it will ask for passwords when it needs them"
	     exit 0;;
	-i)  ACTION=install; shift; ACTION_ARGS=$@;;
	-u)  ACTION=update; shift; ACTION_ARGS=$@;;
	-l)  ACTION=link; shift; ACTION_ARGS=$@;;
	-s)  show_actions ; 
		 exit 0;;
	-v)  shift;
	     LOGLEVEL=3;
	     parse_action $*;;
	-V)  shift;
	     LOGLEVEL=4;
	     parse_action $*;;
	*)  
		 ACTION=install;;
    esac
}

############################################################################
# Drivers
############################################################################

show_actions() {
	for gdir in $ACTIONDIR/0*; do
		if [[ ! $gdir:t = "00" && -d $gdir ]] ; then
			echo "- $gdir:t/"
			for idir in $gdir/*; do
				if [[ -d $idir && -e $idir/$ACTION_FILE ]] ; then
		 			echo "    - $idir:t"
		 		fi
			done
 		fi
	done
}

run_actions () {
    log-info "Performing $ACTION on $OSSYS ($OSTYPE), DIST=$OSDIST, VERSION=$OSVERSION, ARCH=$OSARCH"
    log-info "Using install=$INSTALLER, app=$APP_INSTALLER, update=$UPDATER"
    log-info "Downloading temp files to $DOWNLOADS"
	make_dir $DOWNLOADS
    log-info "Using binary file dir $LOCAL_BIN"
    make_dir $LOCAL_BIN
    log-info "Using configuration dir $LOCAL_CONFIG"
    make_dir $LOCAL_CONFIG

	if [[ -f "$ACTIONDIR/$ACTION_ARGS/$ACTION_FILE" ]] ; then
		run_item_actions "$ACTIONDIR/$ACTION_ARGS"
	else
		log-info "Enumerating action groups in $ACTIONDIR"
		for dir in $ACTIONDIR/0*; do
			if [[ ! $dir:t = "00" && -d $dir ]] ; then
				log-info "Enumerating action group: $dir"
	 			run_group_actions $dir
	 		fi
		done
	fi
}

run_group_actions () {
	for dir in $1/0*; do
		if [[ -d $dir ]] ; then
			log-info "Checking action item: $dir"
 			run_item_actions $dir
 		fi
	done
}

run_item_actions () {
	if [[ -e $1/$ACTION_FILE ]] ; then
		CURR_ACTION=$1
		log-info "Running actions in: $CURR_ACTION/$ACTION_FILE"
		source "$CURR_ACTION/$ACTION_FILE"
	fi
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
    if [[ $OSSYS = $1* && $ACTION = install ]] ; then
		shift
		install_package $@
    fi
}

install_package() {
    if [[ $ACTION = (install|update) ]] ; then
		local _action=$ACTION
		if [[ $ACTION = update && $UPDATER != "" ]] ; then
		    _action=$UPDATER
		fi
		log-debug "+++ performing $_action for ${(j. .)@}"
		case $1
		in
		    -app)
			shift
			if [[ $OSSYS = macos ]] ; then
				run_command $APP_INSTALLER $_action --cask $@
			else
				run_command $APP_INSTALLER $_action $@
			fi
			;;
		    -python)
			shift
			run_command conda $ACTION --yes $@
			;;
		    -racket)
			shift
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
    		log-error "$1 exists, but is not a directory."
    	fi
    else
    	run_command mkdir -p $1
    fi
}

remove_file() {
	if [[ -e "$1" ]] ; then
		run_command rm "$1"
	else
		log-warning "File $1 does not exist."
	fi
}

link_env_file() {
	if [[ $ACTION = (install|update|link) ]] ; then
		run_command mkdir -p "$LOCAL_CONFIG/$1"
		link_file "$1-env" "$LOCAL_CONFIG/$1/env"
	fi
}

link_file() {
    if [[ $ACTION = (install|update|link) ]] ; then
		if [[ -e "$CURR_ACTION/$1" ]] ; then
		    run_command ln -s "$CURR_ACTION/$1" "$2"
		else
		    log-warning "file $1 doesn't exist in $CURR_ACTION."
		fi
    fi
}
