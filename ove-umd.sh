#!/usr/bin/env bash
declare -r VERSION='0.0.1'

# source the npm auth-token
source ./.env

# need this to delete files
shopt -s extglob

#get current version of open-vector-editor-umd
OveUmdV=$(node -pe "require('./open-vector-editor-umd/package.json').version")

# get the new version
OveV=$(yarn info --silent open-vector-editor version)

function clean()
{
    # delete all old files
    cd open-vector-editor-umd/
    rm -f !('package.json'|'readme.md')
    cd ..
}

function copy-umd-files()
{
    # copy only the umd files
    cp node_modules/open-vector-editor/umd/* open-vector-editor-umd/
}

function help()
{
    version
    echo "
    Usage: ove-umd.sh [OPTION] [COMMAND]
           ove-umd.sh [ --help | --version ]

    Commands:

        copy-umd-files  copy OVE umd files from node_modules folder to open-vector-editor-umd
        clean           delete open-vector-editor-umd files
        help            Show this text
        publish         publish the current version of open-vetor-editor-umd at npm
        run             
        upgrade         get the latest version of open-vetor-editor from npm
        version         Display elabctl version
    "
}

function publish()
{
    # update version number
    cd open-vector-editor-umd
    npm version $OveV
    cd ..
    # and publsih
    npm publish open-vector-editor-umd --access public --dry-run
}

function run()
{
    if [[ "$OveUmdV" != "$OveV" ]]; then
        upgrade
        publish
    fi
}

function upgrade()
{
    # download the new version
    yarn install --non-interactive --pure-lockfile

    clean
    copy-umd-files
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
for valid in clean copy-umd-files help publish run upgrade version
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
