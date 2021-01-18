log-debug "+++ installing racer"
if [[ $ACTION = install ]] ; then
    run_command rustup toolchain add nightly
    run_command cargo +nightly install racer
fi
