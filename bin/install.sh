#!/bin/bash

#  OctoPrint Monitor
#
#  Packs plasmoid and installs/upgrades it locally, then restarts plasma.
#
#  @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
#  @copyright 2020 Marcin Orlowski
#  @license   http://www.opensource.org/licenses/mit-license.php MIT
#  @link      https://github.com/MarcinOrlowski/octoprint-monitor

declare -r src_dir="src"

if [[ ! -d "${src_dir}" ]]; then
	echo "*** Source dir not found: ${src_dir}"
	exit 1
fi

declare -r pkg_name=$(grep X-KDE-PluginInfo-Name < "${src_dir}/metadata.desktop" | awk '{split($0,a,"="); print a[2]}')
declare -r base_name=$(echo "${pkg_name}" | awk '{cnt=split($0,a,"."); print a[cnt]}')
declare -r pkg_version=$(grep X-KDE-PluginInfo-Version < "${src_dir}/metadata.desktop" | awk '{split($0,a,"="); print a[2]}')
declare -r plasmoid_path="/tmp/"
declare -r plasmoid_name="${base_name}-${pkg_version}.plasmoid"

echo "PKG_NAME: ${pkg_name}"
echo " VERSION: ${pkg_version}"
echo "PLASMOID: ${plasmoid_name}"

tmp="$(mktemp -d "/tmp/${base_name}.XXXXXX")"
cp -a "${src_dir}"/* "${tmp}"

echo -e "var version=\"${pkg_version}\"" > "${tmp}/contents/js/version.js"

pushd "${tmp}" > /dev/null
zip -q -r "${plasmoid_path}/${plasmoid_name}" *
ls -ld "${plasmoid_path}/${plasmoid_name}"
popd > /dev/null

declare -r user_home_dir="$(eval echo "~${USER}")"
if [[ -d "${user_home_dir}/.local/share/plasma/plasmoids/${pkg_name}" ]]; then
	kpackagetool5 --upgrade "${plasmoid_path}/${plasmoid_name}"
else
	kpackagetool5 --install "${plasmoid_path}/${plasmoid_name}"
fi

kquitapp5 plasmashell
kstart5 plasmashell

