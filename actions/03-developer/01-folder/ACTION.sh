if [[ $OSSYS = macos ]] ; then
	export DEVHOME=$HOME/Projects
else
	export DEVHOME=$HOME/development
fi

if [ ! -d "$DEVHOME" ] ; then
	run_command mkdir $DEVHOME
fi
