#!/bin/sh

process_of()
{
	process=$(echo "$@" | awk '{ print substr($0, index($0,$5)) }');
	for i in $process; do
		ps|grep -E $i|grep -v grep
	done
}

eval `dbus export thunder`

thunderPath=/koolshare/thunder
logFile=$thunderPath/getsysinfo
ifthunderExist=$(ps |grep vod_httpserver |grep -v grep)

getInfo() {
	rm -rf $logFile
	wget -q -O $logFile http://127.0.0.1:9000/getsysinfo
	if [ -e $logFile ]; then
		dbus set thunder_basic_info=$(cat "$logFile")
		if [ -n $thunder_basic_info ]; then
			dbus set thunder_basic_status="01"
		fi
	else
		dbus set thunder_basic_info=""
	fi
}

if [ "$thunder_basic_request" = "20" ]; then
	if [ -e $thunderPath/portal ] && [ -x $thunderPath/portal ]; then
		dbus set thunder_basic_status="020"
		dbus set thunder_basic_info=""
		#$thunderPath/portal -s
		rm -rf /tmp/xunlei.log
		echo "$(date +%Y年%m月%d日\ %X)： 关闭迅雷相关进程……" > /tmp/xunlei.log
		PID_all=`process_of 'EmbedThunderManager|ETMDaemon|vod_httpserver|check_xware_guard|thunder|xunlei|xware|sleep 1m|sleep 10m'|awk '{print $1}'`
		for k in 'EmbedThunderManager' 'ETMDaemon' 'vod_httpserver' 'check_xware_guard' 'thunder' 'xunlei' 'xware'; do
			until [ -z `process_of $k` ]; do
				kill ${PID_all}
			done
		done;
		echo "$(date +%Y年%m月%d日\ %X)： 完成！" > /tmp/xunlei.log
		#dbus remove __event__onwanstart_thunder
		
	else
		dbus set thunder_basic_status="00"
	fi
elif [ "$thunder_basic_request" = "10" ]; then
	if [ -e $thunderPath/portal ] && [ -x $thunderPath/portal ]; then
		dbus set thunder_basic_status="010"
		# add_cpulimit
		# $thunderPath/portal &
		sh /koolshare/thunder/xunlei.sh
		#dbus event onwanstart_thunder /jffs/scripts/start-thunder.sh
	else
		dbus set thunder_basic_status="00"
	fi
elif [ "$thunder_basic_request" = "00" ]; then
	if [ -n "$ifthunderExist" ]; then
		dbus set thunder_basic_status="01"
		getInfo
	else
		dbus set thunder_basic_status="02"
	fi
elif [ "$thunder_basic_request" = "01" ]; then
	getInfo
elif [ "$thunder_basic_request" = "02" ]; then
	if [ -n "$ifthunderExist" ]; then
		dbus set thunder_basic_status="01"
	else
		dbus set thunder_basic_status="02"
	fi
else
	dbus set thunder_basic_status="00"
fi


#dbus save thunder