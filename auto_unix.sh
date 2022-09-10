# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>. 
# By: Celestia

#I do not claim responsibility or ownership of any of the code of this project. Full credit goes to Seth Morabito of loomcom.com. 
#The GPL does not apply to any of the source code downloaded, rather to the script itself. See https://github.com/simh/simh for licensising information regarding the 3b2 simulator.
#!/bin/bash

function confirm_dir() {
    read -p "Would you like the nessecary files to be placed in $(pwd)/3b2unix (y/n)?" CONF
    echo
    if [[ "$CONF" =~ ^[Nn] ]]
    then
        read -p "Where would you like the nessecary files to be located? (Must be a directory)" DIR_LOCATION
        if [ ! -d "$DIR_LOCATION"] 
        then
            echo "Please enter a valid directory location when you restart this program"
            exit 1
        fi
    else
        DIR_LOCATION="./3b2unix"
    fi
}

function file_download {
    wget $1 -P "$DIR_LOCATION" || echo "File failed to download!"
}

function download_prompt() {
    echo "Would you like the base, full, developer image, or developer with GNU Software (1-4)?"
    select PACKAGE_CHOICE in "1" "2" "3" "4"; do
        case $PACKAGE_CHOICE in
            1 ) file_download https://archives.loomcom.com/3b2/emulator/base.img.gz; gzip -d "$DIR_LOCATION/base.img.gz"; mv "$DIR_LOCATION/base.img" "$DIR_LOCATION/hd161.img"; break;;
            2 ) file_download https://archives.loomcom.com/3b2/emulator/full.img.gz; gzip -d "$DIR_LOCATION/full.img.gz"; mv "$DIR_LOCATION/full.img" "$DIR_LOCATION/hd161.img"; break;;
            3 ) file_download https://archives.loomcom.com/3b2/emulator/devel.img.gz; gzip -d "$DIR_LOCATION/devel.img.gz"; mv "$DIR_LOCATION/devel.img" "$DIR_LOCATION/hd161.img"; break;;
            4 ) file_download https://archives.loomcom.com/3b2/emulator/extras_gnu_src.img.gz; gzip -d "$DIR_LOCATION/extra_gnu_src.img.gz"; mv "$DIR_LOCATION/extra_gnu_src.img" "$DIR_LOCATION/hd161.img";;
            * ) echo "Please enter a valid option";;
        esac
    done    
    git clone https://github.com/simh/simh "$DIR_LOCATION/simh" || echo "Git failed to clone this repository"
    wget https://raw.githubusercontent.com/princessalicorn/3b2unix-downloader/main/boot.ini -P $DIR_LOCATION || echo "Failed to fetch boot.ini"
}

function build_simulator() {
    cd "$DIR_LOCATION/simh" || echo "The directory with the 3b2 simulator has been moved or deleted."
    make 3b2 "-j$(getconf _NPROCESSORS_ONLN)"
    cd ..
}

function run_to_installer() {
    ./simh/BIN/3b2 boot.ini
}

confirm_dir
download_prompt
build_simulator
run_to_installer
