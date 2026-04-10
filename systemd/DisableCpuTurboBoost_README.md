# Disable CPU Turbo Boost

This project provides a systemd service and script to manage CPU Turbo Boost states on Linux systems. It is designed to prioritize power efficiency and lower temperatures by disabling Turbo Boost by default when the service is active, while allowing for easy restoration of full performance by stopping the service.

## How it Functions

The project consists of two main components:
1.  **`DisableCPUTurbo.sh`**: A shell script that detects the CPU manufacturer (Intel or AMD) and interacts with the `sysfs` interface to toggle Turbo Boost.
    -   **Disable**: Sets the CPU scaling driver to a power-saving mode and turns off turbo.
    -   **Enable**: Restores the CPU scaling driver to active performance mode and turns on turbo.
2.  **`disableCPUTurbo.service`**: A systemd unit that manages the script lifecycle.
    -   **Starting the service**: Disables Turbo Boost.
    -   **Stopping the service**: Enables Turbo Boost (restores default behavior).

### Tech Details

| Processor | Disable Action | Enable Action |
| :--- | :--- | :--- |
| **Intel** | `status = passive`, `no_turbo = 1` | `status = active`, `no_turbo = 0` |
| **AMD** | `status = passive`, `boost = 0` | `status = active`, `boost = 1` |

## Adapt Ranges (Compatibility)

The script is compatible with a wide range of modern x86_64 hardware:

-   **Intel**: Any processor using the `intel_pstate` driver. This includes everything from Sandy Bridge (2nd Gen) up to the latest **14th Gen** and **Core Ultra** processors.
-   **AMD**: Any processor using the `amd_pstate` or `acpi-cpufreq` driver. Best suited for **Zen 2** and newer architectures (including **Zen 4** and **Zen 5**).

## Manual Install SOP

Follow these steps to install and activate the service manually:

1.  **Clone the Repository** (or copy the files):
    Ensure the files are located in your desired path (default in this repo is `{download_path}/lazypowershell/systemd/`).

2.  **Set Script Permissions**:
    Make sure the script is executable.
    ```bash
    chmod +x ${download_path}/lazypowershell/systemd/DisableCPUTurbo.sh
    ```

3.  **Configure the Service File**:
    If you moved the script to a different location, update the `ExecStart` and `ExecStop` paths in `disableCPUTurbo.service` to match.

4.  **Register the Service**:
    Create a symbolic link to the systemd directory:
    ```bash
    sudo ln -sf ${download_path}/lazypowershell/systemd/disableCPUTurbo.service /etc/systemd/system/disableCPUTurbo.service
    ```

5.  **Reload and Start**:
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable --now disableCPUTurbo.service
    ```

6.  **Verify**:
    Check the service status:
    ```bash
    systemctl status disableCPUTurbo.service
    ```
    You can also verify the CPU state directly:
    -   **Intel**: `cat /sys/devices/system/cpu/intel_pstate/no_turbo` (Should be `1`)
    -   **AMD**: `cat /sys/devices/system/cpu/cpufreq/boost` (Should be `0`)
