# Bash Scripts
A hand-made collection of bash scripts and utils.

* `gitlab-clone-all-repositories.sh`: Clones / pulls all the repositories, trying to follow original structure. Note: it has a delay of 5 seconds for each request.
	* Arguments:
		* `--gitlab-domain "DOMAIN"` for GitLab domain. Defaults to "https://gitlab.com" if it is not set.
		* `--group` for main GitLab group.
* `determine-ports-device.sh`: Lists all USB devices connected to your system and print out their serial numbers.
