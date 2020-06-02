#!/bin/bash

PROG_NAME=$(basename $0)
RUN_DIR=$(dirname $(readlink -f $0))
DEV=""

function usage_exit {
  cat <<_EOS_ 1>&2
  Usage: $PROG_NAME [OPTIONS...]

  現在接続されているUSBシリアルポートをMegaRover用のデバイスファイルとして固定します．
  
  OPTIONS:
    -h, --help              このヘルプを表示
    -d, --dev DEVICE        固定するデバイスを指定する．（例：/dev/ttyUSB0）
_EOS_
    exit 1
}

while (( $# > 0 )); do
    if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
        usage_exit
    elif [[ $1 == "--dev" ]] || [[ $1 == "-d" ]]; then
        if [[ ! -c $2 ]]; then
            echo "ERROR: デバイス $2 が存在しません．"
            usage_exit
        fi
        DEV=$2
        shift 2
    else
        echo "無効なパラメータ: $1"
        usage_exit
    fi
done

if [[ $(whoami) != "root" ]]; then
    echo "ERROR: root で実行してください．"
    usage_exit
fi

if [[ $DEV == "" ]]; then
    while true; do
        read -p "/dev/ttyUSB0 をMegaRover用デバイスとして固定しますか？[y/N]" yn
        case $yn in
            [Yy]* )
                DEV="/dev/ttyUSB0"
                break;
                ;;
            '' | [Nn]* )
                echo ""
                usage_exit
                break;
                ;;
        esac
    done
fi

ID_MODEL_ID="$(udevadm info -q property ${DEV} | grep ID_MODEL_ID)"
ID_SERIAL_SHORT="$(udevadm info -q property ${DEV} | grep ID_SERIAL_SHORT)"
ID_VENDOR_ID="$(udevadm info -q property ${DEV} | grep ID_VENDOR_ID)"

ID_MODEL_ID=${ID_MODEL_ID:12}
ID_SERIAL_SHORT=${ID_SERIAL_SHORT:16}
ID_VENDOR_ID=${ID_VENDOR_ID:13}

echo "ID_MODEL_ID: ${ID_MODEL_ID}"
echo "ID_SERIAL_SHORT: ${ID_SERIAL_SHORT}"
echo "ID_VENDOR_ID: ${ID_VENDOR_ID}"

if [[ -f /etc/udev/rules.d/99-usb-serial-devices.rules ]]; then
    if [[ $(cat /etc/udev/rules.d/99-usb-serial-devices.rules | grep "ttyUSB-MegaRover") == "" ]]; then
        echo "SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"${ID_VENDOR_ID}\", ATTRS{idProduct}==\"${ID_MODEL_ID}\", ATTRS{serial}==\"${ID_SERIAL_SHORT}\", SYMLINK+=\"ttyUSB-MegaRover\", MODE=\"0666\"" >> /etc/udev/rules.d/99-usb-serial-devices.rules
    fi
else
    echo "SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"${ID_VENDOR_ID}\", ATTRS{idProduct}==\"${ID_MODEL_ID}\", ATTRS{serial}==\"${ID_SERIAL_SHORT}\", SYMLINK+=\"ttyUSB-MegaRover\", MODE=\"0666\"" >> /etc/udev/rules.d/99-usb-serial-devices.rules
fi

systemctl restart udev.service

echo "MegaRoverのUSBケーブルを差し直してください．"
