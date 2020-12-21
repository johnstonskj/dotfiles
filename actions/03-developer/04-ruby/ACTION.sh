install_package ruby
run_command curl -sSL https://get.rvm.io -o $DOWNLOADS/rvm.sh
run_command bash $DOWNLOADS/rvm.sh stable
remove_file $DOWNLOADS/rvm.sh

link_env_file ruby

log-debug "+++ installing gems"
while IFS= read -r line; do
	log-debug "+++ +++ gem $line"
    run_command gem install $line
done < "$CURR_ACTION/gems"
