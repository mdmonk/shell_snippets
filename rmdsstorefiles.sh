find "$@" ( -name ".DS_Store" -or -name ".Trashes" -or -name "._*" ) -exec rm -rf "{}" ; -prune
