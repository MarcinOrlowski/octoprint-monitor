#!/bin/bash

declare -r src_dir="src"

if [[ ! -d "${src_dir}" ]]; then
	echo "*** Source dir not found: ${src_dir}"
	exit 1
fi

declare -r pkg_name=$(cat src/metadata.desktop | grep X-KDE-PluginInfo-Name | awk '{split($0,a,"="); print a[2]}')
declare -r base_name=$(echo "${pkg_name}" | awk '{cnt=split($0,a,"."); print a[cnt]}')
declare -r plasmoid_name="${base_name}.plasmoid"

echo "PKG_NAME: ${pkg_name}"
echo "PLASMOID: ${plasmoid_name}"

(cd src && zip -q -r "../${plasmoid_name}" *)
ls -ld *.plasmoid

declare -r user_home_dir="$(eval echo "~${USER}")"
if [[ -d "${user_home_dir}/.local/share/plasma/plasmoids/${pkg_name}" ]]; then
	kpackagetool5 --upgrade ${plasmoid_name}
else
	kpackagetool5 --install ${plasmoid_name}
fi

kquitapp5 plasmashell 
kstart5 plasmashell

