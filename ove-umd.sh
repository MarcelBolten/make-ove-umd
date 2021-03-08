#!/usr/bin/env bash
declare -r VERSION='0.0.1'

# need this to delete files
shopt -s extglob

#get current version of open-vector-editor-umd
OveUmdV=$(node -pe "require('./open-vector-editor-umd/package.json').version")

# get the new version
OveV=$(yarn info --silent open-vector-editor version)

#
function upgrade()
{
    if [[ "$OveUmdV" != "$OveV" ]]; then
        yarn install --silent
        # download the new version
        yarn upgrade --silent
        
        # delete all old files
        cd open-vector-editor-umd/
        rm -f !('package.json'|'yarn.lock'|'readme.md')
        cd ..

        # copy only the umd files
        cp node_modules/open-vector-editor/umd/* open-vector-editor-umd/
    fi
}

function publish()
{
    yarn publish open-vector-editor-umd --new-version $OveV --access public
}

function help()
{
    version
    echo "
    Usage: ove-umd.sh [OPTION] [COMMAND]
           ove-umd.sh [ --help | --version ]

    Commands:

        help            Show this text
        publish         publish the current version of open-vetor-editor-umd at npm
        upgrade         get the latest version of open-vetor-editor from npm
        version         Display elabctl version
    "
}

function version()
{
    echo "© 2021 Marcel Bolten"
    echo "version: $VERSION"
}


# SCRIPT BEGIN

# only one argument allowed
if [ $# != 1 ]; then
    help
    exit 1
fi

# deal with --help and --version
case "$1" in
    -h|--help)
    help
    exit 0
    ;;
    -v|--version)
    version
    exit 0
    ;;
esac

# available commands
declare -A commands
for valid in help publish upgrade version
do
    commands[$valid]=1
done

if [[ ${commands[$1]} ]]; then
    # exit if variable isn't set
    set -u
    $1
else
    help
    exit 1
fi
