############################################################################
# Logging/display stuff
#######################e#####################################################

autoload colors; colors;

LOGLEVEL=1

__log() {
    local level=$1$2$reset_color
    printf "%s %8d %8s [%s] - "  `date "+%Y:%m:%dT%H:%M:%S%Z"` $$ `logname` $level
    echo $fg_bold[white]$3$reset_color
}

log() {
    if [ $1 -le $LOGLEVEL ] ; then
	case $1 in
	    0)
		__log $fg_bold[red] "CRITICAL" $2;
		exit 1
		;;
	    1)
		__log $fg[red] "ERROR" $2
		;;
	    2)
		__log $fg[cyan] "WARNING" $2
		;;
	    3)
		__log $fg[green] "INFO" $2
		;;
	    *)
		__log $fg[white] "DEBUG" $2
		;;
	esac
    fi
}

log-critical() { log 0 $@ }
log-error() { log 1 $@ }
log-warning() { log 2 $@ }
log-info() { log 3 $@ }
log-debug() { log 4 $@ }

echo_bright() {
    echo $fg_bold[white]$1$reset_color
}

echo_instruction() {
    echo $fg[green]perform manual action:$reset_color \$ $1
}

echo_instruction_for() {
    if [[ $OSTYPE = $1* && $ACTION = (install) ]] ; then
	shift
	echo_instruction $@
    fi
}

