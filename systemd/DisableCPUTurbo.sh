#!/bin/sh
# check if system has lscpu command
if [ -x "$(command -v lscpu)" ]; then
    # get CPU model name
    modelname=$(lscpu | grep "^Model name:" | cut -d":" -f2)
    # if modelname contains "Intel"
    if [$modelname == *"Intel"*]; then
        echo "Disabling Intel CPU Turbo Boost"
        echo "passive" > /sys/devices/system/cpu/intel_pstate/status
        echo "1" > /sys/devices/system/cpu/intel_pstate/no_turbo
    else [$modelname == *"AMD"*]
        echo "Disabling AMD CPU Turbo Boost"
        echo "passive" > /sys/devices/system/cpu/amd_pstate/status
        echo "0" > /sys/devices/system/cpu/cpufreq/boost
    fi
else
    echo "lscpu command not found, that's rare."
    exit 13
fi
