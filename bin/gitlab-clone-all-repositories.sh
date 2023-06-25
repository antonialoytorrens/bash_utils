#!/bin/bash

# Go to the directory where this script is located
cd $( dirname -- "$0"; )

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --gitlab-domain) GITLAB_DOMAIN="https://$2"; shift ;;
        --group) GROUP_PATH="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if group path is provided
if [ -z "$GROUP_PATH" ]
then
        echo "Group path is not provided. Use --group to provide the group path."
        exit 1
fi

# Check if git is installed
if ! command -v git &> /dev/null; then
  echo "git is not installed. Please install git and rerun the script."
  exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
  echo "jq is not installed. Please install jq and rerun the script."
  exit 1
fi

GITLAB_DOMAIN='https://git.abscue.de'  # change this to your GitLab domain
GROUP_PATH='obp'  # change this to your group path
PER_PAGE=100  # max amount of projects per page
DELAY=5  # delay between requests in seconds

# Get number of pages
NUM_PAGES=$(curl --silent --head "${GITLAB_DOMAIN}/api/v4/groups/${GROUP_PATH}/projects?include_subgroups=true&per_page=${PER_PAGE}" | \
  grep -i '^x-total-pages:' | tr -dc '0-9')

if [ -z "$NUM_PAGES" ]
then
        echo "Failed to get number of pages from GitLab API."
        exit 1
fi

echo "Number of pages: $NUM_PAGES"

page=1

# While page number is less than or equal to total number of pages
while [ $page -le $NUM_PAGES ]
do
  # Get list of projects on this page
  curl --silent "${GITLAB_DOMAIN}/api/v4/groups/${GROUP_PATH}/projects?include_subgroups=true&per_page=${PER_PAGE}&page=${page}" | \
    jq -r '.[] | "\(.path_with_namespace) \(.http_url_to_repo)"' | \
    while read path repo; do
      mkdir -p "$(dirname "$path")"
      git -C "$(dirname "$path")" clone "$repo" || git -C "$(dirname "$path")" pull --ff-only "$repo"
    done

  # Sleep for a while to avoid hitting rate limits
  if [ $page -lt $NUM_PAGES ]; then
    sleep "$DELAY"
  fi

  # Increment page number
  page=$((page + 1))
done
