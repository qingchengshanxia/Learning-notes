#!/bin/sh
API="http://apt.edgapp.com"
USERNAME="root"
PASSWORD="su902902"
#该脚本需要安装相关环境才可以刷机

ECID="$(ideviceinfo --key DieID)"
HWMODEL="$(ideviceinfo --key HardwareModel)"
BLOB_VERSION="12.4"

echo "ECID: ${ECID}, HWMODEL: ${HWMODEL}\nFetching SHSH2 Blobs for ${BLOB_VERSION}..."
##########开始获取shsh2##########
rm -f saved.shsh2
curl --silent \
  "${API}/admin/login/?next=/api/token.json" \
  -H 'Accept: */*' \
  -H 'Accept-Encoding: gzip, deflate' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'User-Agent: PostmanRuntime/7.17.1' \
  -d "username=${USERNAME}&password=${PASSWORD}" \
  -c curl.cookie

curl --silent \
  "${API}/api/token.json" \
  -H 'Accept: */*' \
  -H 'Accept-Encoding: gzip, deflate' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'User-Agent: PostmanRuntime/7.17.1' \
  -b curl.cookie | jq -r ".token" > curl.token

TOKEN="$(cat curl.token)"

curl --silent -L \
  "${API}/api/fetch/" \
  -H 'Accept: */*' \
  -H 'Accept-Encoding: gzip, deflate' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'User-Agent: PostmanRuntime/7.17.1' \
  -d "token=${TOKEN}&ecid=${ECID}&blob_version=${BLOB_VERSION}" \
  -b curl.cookie -o saved.shsh2

STATUS=$(head -n 1 saved.shsh2)
if [[ ${STATUS} != "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" ]]; then
  rm -f saved.shsh2
  echo "⚠️⚠️⚠️警告: 该设备在后台没有找到shsh2备份证书，无法继续，脚本即将退出.⚠️⚠️⚠️"
  exit 1
fi


##########开始平刷##########
if [ ${HWMODEL} == "N71AP" ]; then
	echo "\033[34m CPU:N71AP \033[0m"
	./futurerestore -t saved.shsh2 -b Firmware/Mav13-5.70.01.Release.bbfw -p Firmware/BuildManifest.plist -s Firmware/sep-firmware.n71.RELEASE.im4p -m Firmware/BuildManifest.plist Firmware/iPhone_4.7_12.4_16G77_Restore.ipsw
	say restoring succeeded.
  echo "平刷完成!"
elif [ ${HWMODEL} == "N71mAP" ]; then
	echo "\033[34m CPU:N71mAP \033[0m"
	./futurerestore -t saved.shsh2 -b Firmware/Mav13-5.70.01.Release.bbfw -p Firmware/BuildManifest.plist -s Firmware/sep-firmware.n71m.RELEASE.im4p -m Firmware/BuildManifest.plist Firmware/iPhone_4.7_12.4_16G77_Restore.ipsw
	say restoring succeeded.
  echo "平刷完成!"
elif [ ${HWMODEL} == "N61AP" ]; then
	echo "\033[34m CPU:N61AP \033[0m"
	./futurerestore -t saved.shsh2 -b Firmware/Mav10-7.80.04.Release.bbfw -p Firmware/BuildManifest.plist -s Firmware/sep-firmware.n61.RELEASE.im4p -m Firmware/BuildManifest.plist Firmware/iPhone_4.7_12.4_16G77_Restore.ipsw
	say restoring succeeded.
  echo "平刷完成!"
else
   echo "⚠️⚠️⚠️未找到相关hw-model,脚本无法执行即将退出⚠️⚠️⚠️！"
   exit 1
fi