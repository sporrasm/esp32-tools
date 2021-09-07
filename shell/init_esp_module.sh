#!/bin/bash

help_f(){
    echo "Usage: ./init_esp_module.sh <module_name>"
    echo "Creates an ESP IDF project skeleton for"
    echo "module <module_name>. Template from"
    echo "https://github.com/espressif/esp-idf-template"
}

module=$1
currdir=`pwd`

if [ -z $module ]; then
    echo "Give module name as argument!"
    help_f
    exit 1
fi
if [ -d "$currdir/$module" ]; then
    echo "Module by name $module exists in $currdir!"
    exit 1
else
    echo "Crearting module $module"
fi

mkdir $module
mkdir $module/main
cd $module

echo "Initing git repo"
git init
echo "Generating files..."

cat << 'EOF' > CMakeLists.txt 
# The following lines of boilerplate have to be in your project's
# CMakeLists in this exact order for cmake to work correctly
cmake_minimum_required(VERSION 3.5)

include($ENV{IDF_PATH}/tools/cmake/project.cmake)
EOF
echo "project(${module})" >> CMakeLists.txt

cat << EOF > .gitignore
build/
sdkconfig
sdkconfig.old
EOF

cat << 'EOF' > Makefile
#
# This is a project Makefile. It is assumed the directory this Makefile resides in is a
# project subdirectory.
#
EOF
echo "PROJECT_NAME := $module" >> Makefile

echo "include \$(IDF_PATH)/make/project.mk" >> Makefile

cat << 'EOF' >> main/CMakeLists.txt
# Edit following two lines to set component requirements (see docs)
set(COMPONENT_REQUIRES )
set(COMPONENT_PRIV_REQUIRES )

EOF
echo "set(COMPONENT_SRCS \"${module}_main.c\")" >> main/CMakeLists.txt
cat << 'EOF' >> main/CMakeLists.txt
set(COMPONENT_ADD_INCLUDEDIRS "")

register_component()
EOF

cat << 'EOF' > main/component.mk
#
# Main component makefile.
#
# This Makefile can be left empty. By default, it will take the sources in the 
# src/ directory, compile them and link them into lib(subdirectory_name).a 
# in the build directory. This behaviour is entirely configurable,
# please read the ESP-IDF documents if you need to do this.
#
EOF

cat << 'EOF' > main/Kconfig.projbuild
# put here your custom config value
menu "Example Configuration"
config ESP_WIFI_SSID
    string "WiFi SSID"
    default "myssid"
    help
	SSID (network name) for the example to connect to.

config ESP_WIFI_PASSWORD
    string "WiFi Password"
    default "mypassword"
    help
	WiFi password (WPA or WPA2) for the example to use.
endmenu
EOF

cat << EOF > main/${module}_main.c
#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"


void app_main(void)
{
    int i = 0;
    while (1) {
        printf("[%d] Hello world!\n", i);
        i++;
        vTaskDelay(5000 / portTICK_PERIOD_MS);
    }
}
EOF

cat << EOF > README.md

Readme for project $module

Remeber to run the export script from ESP install dir!

To configure, run

\`\`\`
idf.py set-target esp32
idf.py menuconfig
\`\`\`
To build, run
\`\`\`
idf.py build
\`\`\`
Finally, to flash and monitor, run

\`\`\`
idf.py -p ESP_SERIAL_PORT flash monitor
\`\`\`

EOF
