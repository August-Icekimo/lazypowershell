#!/bin/sh
# check if system has lscpu command
if [ -x "$(command -v lscpu)" ]; then
    # get CPU model name
    modelname=$(lscpu | awk -F: '/^Model name:/ {print $2}')
    # if modelname contains "Intel"
    if echo "$modelname" | grep -qE "Intel" ; then
        echo "Disabling Intel CPU Turbo Boost"
        echo "passive" > /sys/devices/system/cpu/intel_pstate/status
        echo "1" > /sys/devices/system/cpu/intel_pstate/no_turbo
    elif echo "$modelname" | grep -qE "AMD" ; then
        echo "Disabling AMD CPU Turbo Boost"
        if [ -e /sys/devices/system/cpu/amd_pstate/status ]; then
          echo "passive" > /sys/devices/system/cpu/amd_pstate/status
            if [ -e /sys/devices/system/cpu/cpufreq/boost ]; then
                echo "0" > /sys/devices/system/cpu/cpufreq/boost
            # else
            #     echo "/sys/devices/system/cpu/cpufreq/boost not found"
            fi
        else
            echo "/sys/devices/system/cpu/amd_pstate/status not found"
        fi
        echo "0" > /sys/devices/system/cpu/cpufreq/boost
    fi
else
    echo "lscpu command not found, that's rare."
    exit 13
fi
