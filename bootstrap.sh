#/usr/bin/env bash

if [[ -z $DOTFILEDIR ]]; then
    DOTFILEDIR=$HOME/dotfiles
fi

if [[ -d $DOTFILEDIR ]]; then
    echo target directory, $DOTFILEDIR, exists, will not proceed.
    exit 1
fi

case $OSTYPE in
    darwin*)
        XCODE=$(xcode-select -p)
        if [[ ! -d "$XCODE" ]]; then
            xcode-select --install
        else
            echo Xcode already installed
        fi
        ;;
    linux*)
        ;;
    *)
        echo Unsupported OS type: $OSTYPE
        exit 2
esac

cd $HOME
git clone https://github.com/johnstonskj/dotfiles.git $DOTFILEDIR
cd $DOTFILEDIR

$DOTFILEDIR/mcfg install
