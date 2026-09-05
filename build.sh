#!/bin/bash

############################################################
# The Dynamixs.AI Developer Script
# start, build, hot, setup, deploy
# 
############################################################

strip_dash() {
    echo "$1" | sed 's/^-//'
}

    echo "     _            _   _          _  "     
    echo "  __| | _____   _(_) | |__   ___| |_ __"  
    echo " / _\` |/ _ \\ \\ / / | | '_ \\ / _ \\ | \'_ \\" 
    echo "| (_| |  __/\ V /| | | | | |  __/ | |_) |"
    echo " \__,_|\___| \_/ |_| |_| |_|\___|_| .__/ "
    echo "                                  |_|  "
    echo "    Dynamixs.AI Build Script..."
    echo "_________________________________________"

# Update git
git pull
mvn clean install -DskipTests -Pdocker
