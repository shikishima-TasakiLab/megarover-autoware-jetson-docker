#!/bin/bash
BUILD_DIR=$(dirname $(readlink -f $0))
CURRENT_DIR=$(pwd)
USER_ID=$(id -u)
PROG_NAME=$(basename $0)

ntr_arr=( $(echo $(cat /etc/nv_tegra_release) | tr -s ',' ' ') )
MAJOR_VERSION=${ntr_arr[1]}
MINOR_VERSION=${ntr_arr[4]}

function usage_exit {
  cat <<_EOS_ 1>&2
  Usage: $PROG_NAME [OPTIONS...]
  OPTIONS:
    -h, --help                      このヘルプを表示
_EOS_
    cd ${CURRENT_DIR}
    exit 1
}

while (( $# > 0 )); do
    if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
        usage_exit
    else
        echo "無効なパラメータ： $1"
        usage_exit
    fi
done

AUTOWARE_IMAGE="jetson/autoware"

images="$(docker image ls ${AUTOWARE_IMAGE} | grep ${AUTOWARE_IMAGE})"

if [[ "${images}" == "" ]]; then
    echo "${AUTOWARE_IMAGE} のDockerイメージが見つかりませんでした．"
    ${BUILD_DIR}/src-autoware/docker/build-docker.sh
    if [[ $? != 0 ]]; then
        echo "エラーにより中断しました．"
        cd ${CURRENT_DIR}
        exit 1
    fi
fi

declare -a images_list=()
while read repo tag id created size ; do
    images_list+=( "${repo}:${tag}" )
done <<END
${images}
END

if [[ ${#images_list[@]} -eq 1 ]]; then
    AUTOWARE_IMAGE="${images_list[0]}"
else
    echo -e "番号\tイメージ:タグ"
    cnt=0
    for img in "${images_list[@]}"; do
        echo -e "${cnt}:\t${img}"
        cnt=$((${cnt}+1))
    done
    isnum=3
    img_num=-1
    while [[ ${isnum} -ge 2 ]] || [[ ${img_num} -ge ${cnt} ]] || [[ ${img_num} -lt 0 ]]; do
        read -p "使用するイメージの番号を入力してください: " img_num
        expr ${img_num} + 1 > /dev/null 2>&1
        isnum=$?
    done
    AUTOWARE_IMAGE="${images_list[${img_num}]}"
fi
echo ${AUTOWARE_IMAGE}

docker build \
    -t ${AUTOWARE_IMAGE}-megarover \
    --build-arg AUTOWARE_JETSON="${AUTOWARE_IMAGE}" \
    ${BUILD_DIR}/src-megarover

if [[ $? != 0 ]]; then
    echo "エラーにより中断しました．"
    cd ${CURRENT_DIR}
    exit 1
fi

while true; do
    read rmi \?"Dockerイメージ \"${AUTOWARE_IMAGE}\" のタグを削除しますか？ [y/N]"
    case $rmi in
        [Yy]* )
            docker rmi ${AUTOWARE_IMAGE}
            break;
            ;;
        '' | [Nn]* )
            break;
            ;;
    esac
done