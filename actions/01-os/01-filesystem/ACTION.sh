
while read -r line ;
do
    mkdir "$HOME/$line"
done < create-user-dirs

if [[ $OSSYS = macos ]] ; then
    link_file user-dirs.dirs $LOCAL_CONFIG/user-dirs.dirs
fi
