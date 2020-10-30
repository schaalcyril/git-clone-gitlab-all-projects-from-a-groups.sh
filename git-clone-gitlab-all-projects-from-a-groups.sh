#!/usr/bin/env bash
# ------------------------------------------------------------------
# [SCHAAL Cyril] git-clone-gitlab-all-projects-from-a-groups.sh
#   Bash script to download/pull repositories from a GitLab instance
# ------------------------------------------------------------------
#
VERSION=1.0.0
# HISTORY:
#
# * 30/10/2020 - v1.0.0  - First Creation
#
# ##################################################

function mainScript() {
############## Begin Script Here ###################
####################################################

echo "Cloning/pull all git projects from group $GROUP_NAME"
CURL_RESULT=$(curl -k -s "$GITLAB_URL/api/v4/groups/$GROUP_NAME/projects?private_token=$GITLAB_TOKEN&per_page=999&include_subgroups=True")
MAX_RESULT=$(($(echo ${CURL_RESULT} | jq '.|length')-1))
for i in $(seq 0 ${MAX_RESULT})
do
        REPO_PATH_WITH_NAMESPACE=$(echo ${CURL_RESULT} | jq -r ".[$i].path_with_namespace")
        REPO_SSH_URL_TO_REPO=$(echo ${CURL_RESULT} | jq -r ".[$i].ssh_url_to_repo")
        if [ ! -d "${DESTINATION_PATH}/$REPO_PATH_WITH_NAMESPACE" ]; then
                mkdir -p -v ${DESTINATION_PATH}/${REPO_PATH_WITH_NAMESPACE}
                git clone --progress ${REPO_SSH_URL_TO_REPO} ${DESTINATION_PATH}/${REPO_PATH_WITH_NAMESPACE}
        else
            echo "git pull ${DESTINATION_PATH}/${REPO_PATH_WITH_NAMESPACE}"
            (cd "${DESTINATION_PATH}/$REPO_PATH_WITH_NAMESPACE" && git pull)
        fi

done

####################################################
############### End Script Here ####################
}

############## Begin Options and Usage ###################

function safeExit() {
  trap - INT TERM EXIT
  exit
}

# Print usage
usage() {
  echo -n "

git-clone-gitlab-all-projects-from-a-groups.sh  Cloning/pull all git projects from GitLab group.

${bold}Options:${reset}
  -d, --destination Destination path
  -g, --group-id    ID's group to clone
  -t, --token       Gitlab token
  -u, --gitLab-url  GitLab URL (e.g. https://gitlab.com)
  -h, --help        Display this help and exit
  -v, --version     Output version information and exit
"
}

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
    # If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
        c=${1:i:1}

        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;

    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Print help if no arguments were passed.
# Uncomment to force arguments when invoking the script
[[ $# -eq 0 ]] && set -- "--help"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; safeExit ;;
    -v|--version) echo "$(basename $0) ${version}"; safeExit ;;
    -d|--destination) shift; DESTINATION_PATH=${1} ;;
    -g|--group-id) shift; GROUP_NAME=${1} ;;
    -t|--token) shift; GITLAB_TOKEN=${1} ;;
    -u|--gitLab-url) shift; GITLAB_URL=${1} ;;
    --endopts) shift; break ;;
    *) die "invalid option: '$1'." ;;
  esac
  shift
done

# mandatory arguments
if [ ! "$DESTINATION_PATH" ] || [ ! "$GROUP_NAME" ] || [ ! "$GITLAB_TOKEN" ] || [ ! "$GITLAB_URL" ]; then
  echo "arguments -d, -g, -t and -u must be provided"
  echo "$usage" >&2; exit 1
fi

# Store the remaining part as arguments.
args+=("$@")
############## End Options and Usage ###################


# ############# ############# #############
# ##       RUN THE SCRIPT                ##
# ############# ############# #############
mainScript

safeExit 
