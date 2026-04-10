#!/bin/sh
# Default action is disable if no argument is provided
ACTION=${1:-disable}

# check if system has lscpu command
if [ -x "$(command -v lscpu)" ]; then
    # get CPU model name
    modelname=$(lscpu | awk -F: '/^Model name:/ {print $2}')
    
    # if modelname contains "Intel"
    if echo "$modelname" | grep -qE "Intel" ; then
        if [ "$ACTION" = "enable" ]; then
            echo "Enabling Intel CPU Turbo Boost"
            [ -e /sys/devices/system/cpu/intel_pstate/status ] && echo "active" > /sys/devices/system/cpu/intel_pstate/status
            [ -e /sys/devices/system/cpu/intel_pstate/no_turbo ] && echo "0" > /sys/devices/system/cpu/intel_pstate/no_turbo
        else
            echo "Disabling Intel CPU Turbo Boost"
            [ -e /sys/devices/system/cpu/intel_pstate/status ] && echo "passive" > /sys/devices/system/cpu/intel_pstate/status
            [ -e /sys/devices/system/cpu/intel_pstate/no_turbo ] && echo "1" > /sys/devices/system/cpu/intel_pstate/no_turbo
        fi
    # if modelname contains "AMD"
    elif echo "$modelname" | grep -qE "AMD" ; then
        if [ "$ACTION" = "enable" ]; then
            echo "Enabling AMD CPU Turbo Boost"
            [ -e /sys/devices/system/cpu/amd_pstate/status ] && echo "active" > /sys/devices/system/cpu/amd_pstate/status
            [ -e /sys/devices/system/cpu/cpufreq/boost ] && echo "1" > /sys/devices/system/cpu/cpufreq/boost
        else
            echo "Disabling AMD CPU Turbo Boost"
            [ -e /sys/devices/system/cpu/amd_pstate/status ] && echo "passive" > /sys/devices/system/cpu/amd_pstate/status
            [ -e /sys/devices/system/cpu/cpufreq/boost ] && echo "0" > /sys/devices/system/cpu/cpufreq/boost
        fi
    fi
else
    echo "lscpu command not found, that's rare."
    exit 13
fi
