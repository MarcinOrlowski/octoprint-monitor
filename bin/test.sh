#!/bin/bash

#  OctoPrint Monitor
#
#  Runs plasmoid in plasmoidviewer. Pass any argument to run in FullRepresentation, otherwise
#  CompactReperesentation is used.
#
#  @author    Marcin Orlowski <mail (#) marcinOrlowski (.) com>
#  @copyright 2020 Marcin Orlowski
#  @license   http://www.opensource.org/licenses/mit-license.php MIT
#  @link      https://github.com/MarcinOrlowski/octoprint-monitor

# https://stackoverflow.com/questions/41409273/file-line-and-function-for-qml-files
# https://doc.qt.io/qt-5/qtglobal.html#qSetMessagePattern
#export QT_MESSAGE_PATTERN="[%{type}] %{appname} (%{file}:%{line}) - %{message}"
#export QT_MESSAGE_PATTERN="%{time} %{file}:%{line}: %{message}"
export QT_MESSAGE_PATTERN="%{time} L%{line} %{message}"

if [[ $# -ge 1 ]]; then
  echo "Running FullRepresetaion"
  plasmoidviewer --applet src/
else
  echo "Running CompactRepresetaion"
  plasmoidviewer \
    --formfactor vertical \
    --location topedge \
    --applet src\
    --size 140X150 \
    #--size "196X96" \
fi
