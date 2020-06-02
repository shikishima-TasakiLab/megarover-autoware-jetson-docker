# MegaRover-Autoware-Jetson

This is a package to run Vstone MegaRover from ROS & Autoware.

## Install

```bash
#!/bin/bash
git clone --recursive https://github.com/shikishima-TasakiLab/megarover-autoware-jetson-docker.git MegaRover-Autoware-Jetson

cd MegaRover-Autoware-Jetson

# Set aliases
./docker/set_aliases.sh
source ~/.bashrc

# Connect the USB cable from the Mega Rover
sudo ./docker/megarover_udev.sh
```

## Build Docker Image

```bash
#!/bin/bash
./docker/build-docker.sh
```
|Option           |Parameter |Explanation        |Default|Example    |
|-----------------|----------|-------------------|-------|-----------|
|`-h`, `--help`   |(None)    |Display how to use |(None) |`-h`       |

## Run Docker Image

```bash
#!/bin/bash
autoware-run
```
|Option           |Parameter |Explanation                                              |Default                                  |Example             |
|-----------------|----------|---------------------------------------------------------|-----------------------------------------|--------------------|
|`-h`, `--help`   |(None)    |Display how to use                                       |(None)                                   |`-h`                |
|`-l`, `--launch` |{on\|off} |Launch "runtime_manager"                                 |`on`                                     |`-l off`            |
|`-p`, `--param`  |FILE      |Specify Autoware configuration file to read              |`./docker/autoware-param/param_init.yaml`|`-p robot_1.yaml`   |
|`-s`, `--save`   |FILE      |Specify the save destination of the Autoware setting file|(None)                                   |`-s robot_1.yaml`   |
|`-n`, `--name`   |NAME      |Container name                                           |`autoware`                               |`-n autoware-master`|

## Use Another Terminal

```bash
#!/bin/bash
autoware-exec
```
|Option           |Parameter |Explanation        |Default|Example    |
|-----------------|----------|-------------------|-------|-----------|
|`-h`, `--help`   |(None)    |Display how to use |(None) |`-h`       |
