log-debug "+++ installing racer"
run_command rustup toolchain add nightly
run_command cargo +nightly install racer
