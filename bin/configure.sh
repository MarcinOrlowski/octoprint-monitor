#!/bin/bash

#  OctoPrint Monitor
#
#  Updated plasmoid generated config files file based on current template,
#  env vars and metadata.desktop file
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

declare -r pkg_name=$(grep X-KDE-PluginInfo-Name < "${src_dir}/metadata.desktop" | awk '{split($0,a,"="); print a[2]}')
declare -r base_name=$(echo "${pkg_name}" | awk '{cnt=split($0,a,"."); print a[cnt]}')
declare -r pkg_version=$(grep X-KDE-PluginInfo-Version < "${src_dir}/metadata.desktop" | awk '{split($0,a,"="); print a[2]}')
declare -r plasmoid_path="$(pwd)"
declare -r plasmoid_name="${base_name}-${pkg_version}.plasmoid"

echo "PKG_NAME: ${pkg_name}"
echo " VERSION: ${pkg_version}"
echo -e "var version=\"${pkg_version}\"" > "${src_dir}/contents/js/version.js"


declare -r cfg_template_file="${src_dir}/contents/config/main-template.xml"
declare -r cfg_config_file="${src_dir}/contents/config/main.xml"

if [[ ! -s "${cfg_template_file}" ]]; then
	echo "*** Config template not found: ${cfg_template_file}"
	exit 1
fi

op_api_url=
op_api_key=
op_snapshot_url=

if [[ "$#" -eq 0 ]]; then
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
