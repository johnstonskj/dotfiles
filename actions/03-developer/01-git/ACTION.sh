install_package git git-lfs git-standup gh act

link_file dot-gitconfig $HOME/.gitconfig

GIT_CONFIG=$LOCAL_CONFIG/git
make_dir $GIT_CONFIG
link_file ignore_global $GIT_CONFIG/ignore_global
link_file message $GIT_CONFIG/message
make_dir $GIT_CONFIG/hooks

link_file git-all-status $LOCAL_BIN/git-all-status
link_file git-tag-delete $LOCAL_BIN/git-tag-delete
link_file git-tag-replace $LOCAL_BIN/git-tag-replace

local PKG=git-extras
install_package ${PKG}
make_dir $LOCAL_CONFIG/${PKG}/completions
link_file /opt/homebrew/share/${PKG}/${PKG}-completion.zsh $LOCAL_CONFIG/${PKG}/completions/${PKG}.zsh
