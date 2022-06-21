install_package git git-lfs gh act

link_file dot-gitconfig $HOME/.gitconfig

GIT_CONFIG=$LOCAL_CONFIG/git
make_dir $GIT_CONFIG
link_file ignore_global $GIT_CONFIG/ignore_global
link_file message $GIT_CONFIG/message
make_dir $GIT_CONFIG/hooks

link_file git-all-status $LOCAL_BIN/git-all-status
link_file git-tag-delete $LOCAL_BIN/git-tag-delete
link_file git-tag-replace $LOCAL_BIN/git-tag-replace
