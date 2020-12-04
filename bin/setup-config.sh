#!/bin/bash

#  OctoPrint Monitor
#
#  Updated plasmoid dev config file based on current template and env vars
#
#  @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
#  @copyright 2020 Marcin Orlowski
#  @license   http://www.opensource.org/licenses/mit-license.php MIT
#  @link      https://github.com/MarcinOrlowski/octoprint-monitor

function escape() {
	local -r str="${1:-}"
	echo $(echo "${str}" | sed -e 's/[]\/$*.^[]/\\&/g')
}

declare -r src_dir="src"


if [[ ! -d "${src_dir}" ]]; then
	echo "*** Source dir not found: ${src_dir}"
	exit 1
fi

declare -r cfg_template_file="${src_dir}/contents/config/main-template.xml"
declare -r cfg_config_file="${src_dir}/contents/config/main.xml"

if [[ ! -s "${cfg_template_file}" ]]; then
	echo "*** Config template not found: ${cfg_template_file}"
	exit 1
fi

op_api_url=
op_api_key=
op_snapshot_url=

if [[ "$#" -gt 0 ]]; then
	echo "Populating config with env vars: ${cfg_config_file}"

	for name in OCTOPRINT_API_URL OCTOPRINT_API_KEY OCTOPRINT_SNAPSHOT_URL; do
		val="$(eval echo "\${${name}}")"
		if [[ -z "${val}" ]]; then
			echo "*** ${name} env variable is not set properly."
			exit 1
		fi

		echo "  ${name}=\"${val}\""
	done

	op_api_url=$(escape "${OCTOPRINT_API_URL}")
	op_api_key=$(escape "${OCTOPRINT_API_KEY}")
	op_snapshot_url=$(escape "${OCTOPRINT_SNAPSHOT_URL}")
else
	echo "Creating empty config file: ${cfg_config_file}"
fi

cat "${cfg_template_file}" | sed -e "s/{OCTOPRINT_API_URL}/${op_api_url}/g" | sed -e "s/{OCTOPRINT_API_KEY}/${op_api_key}/g" | sed -e "s/{OCTOPRINT_SNAPSHOT_URL}/${op_snapshot_url}/g" > "${cfg_config_file}"
