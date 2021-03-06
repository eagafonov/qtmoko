#!/bin/ash

export QWS_MOUSE_PROTO="tslib"
export QWS_KEYBOARD="neokbdhandler"
export QTOPIA_PHONE_DEVICE="/dev/ttySAC0:115200"
export QPEDIR=/opt/qtmoko
export PATH=$QPEDIR/bin:$PATH
export LD_LIBRARY_PATH=$QPEDIR/lib:$LD_LIBRARY_PATH

# export SXE_DISCOVERY_MODE=1
export QTOPIA_ZONEINFO_PATH=$QPEDIR/etc/zoneinfo
export QTOPIA_PHONE_VENDOR=neo

export TSLIB_TSDEVICE=/dev/input/touchscreen0
# export TSLIB_TSDEVICE=/dev/input/event1
export TSLIB_CONFFILE=/etc/ts.conf

export USER=root
export HOME=/home/$USER

echo '1' > /proc/sys/kernel/printk

restore_default()
{
    echo "Restoring system default"

    # Destroy all data in /home and /mnt/documents

    startupflags.sh RESTOREDEFAULTS_FLAG 0

    # Restart this script. It is possible that it was changed.
    exec $0
}

poweron_modem()
{
    echo 0 > /sys/bus/platform/devices/neo1973-pm-gsm.0/power_on
sleep 2
# power gsm on
    echo 1 > /sys/bus/platform/devices/neo1973-pm-gsm.0/power_on
}

poweron_bluetooth()
{
    bt-poweron.sh
}

case $1 in
'start')

KILLPROGS="quicklauncher mediaserver mediaplayer sipagent"
    killall $KILLPROGS 2>/dev/null

touch /tmp/restart-qtopia
while [ -e /tmp/restart-qtopia ]; do

# load startup flags from conf file
eval $(startupflags.sh)

# Restore default settings.
if [ "$RESTOREDEFAULTS_FLAG" = 1 ]; then
    restore_default
fi

if [ "$PHONEDUMMY_FLAG" = 1 ]; then
    export QTOPIA_PHONE_DUMMY=1
else
    export QTOPIA_PHONE_DUMMY=0
fi

if [ "$PHONEDEVICE_FLAG" != "" ]; then
    export QTOPIA_PHONE_DEVICE=$PHONEDEVICE_FLAG
fi

if [ "$PHONEBOUNCE_FLAG" = 1 ] ; then
    # Turn on the modem
    poweron_modem
    phonebounce $QTOPIA_PHONE_DEVICE 12345 &

    export QTOPIA_PHONE_DUMMY=1
fi

if [ "$PERFTEST_FLAG" = 1 ] && [ "$QTOPIA_PERFTEST" != 1 ]; then
    # Use the perftest screen driver
    export OLD_QWS_DISPLAY=$QWS_DISPLAY
    if [ "x$QWS_DISPLAY" = "x" ]; then eval "export `egrep '^QWS_DISPLAY' /opt/Qtopia/etc/defaultbuttons.conf`"; fi
    export QWS_DISPLAY="perftestlinuxfb:$QWS_DISPLAY"
    export QTOPIA_PERFTEST=1
    echo "Enabling performance testing" | logger -p local5.notice -t 'Qtopia'
    if [ "$PERFTESTSLEEP_FLAG" = 1 ]; then
        echo "Performance: sleeping for 2 minutes" | logger -p local5.notice -t 'Qtopia'
        sleep 120
        echo "Performance: finished sleeping" | logger -p local5.notice -t 'Qtopia'
    fi

elif [ "$PERFTEST_FLAG" != 1 ] && [ "$QTOPIA_PERFTEST" = 1 ]; then
    # Revert to original screen driver
    export QWS_DISPLAY=$OLD_QWS_DISPLAY
    if [ "x$QWS_DISPLAY" = "x" ]; then unset QWS_DISPLAY; fi
    unset QTOPIA_PERFTEST
    echo "Disabling performance testing" | logger -p local5.notice -t 'Qtopia'
fi

if [ "$TEST_FLAG" = 1 ]; then
    export QTOPIA_TEST=1
else
    unset QTOPIA_TEST
fi
    
    # clean up shared memory and semaphores
    # but not for resources created by syslogd
#    clearipc $(pidof syslogd)

if [ "$BOOTCHART_FLAG" = 1 ]; then
    { sleep 120; /sbin/bootchartd stop; } &
    /sbin/bootchartd start qpe 2>&1 | logger -p local5.notice -t Qtopia
else
    # For accurate perftest results, this MUST be the last line before invoking qpe
    export QTOPIA_UPTIME_AT_LAUNCH=`cat /proc/uptime`
    qpe 2>&1 | logger -p local5.notice -t 'Qtopia'
fi

poweron_modem
poweron_bluetooth

	echo "starting clock" > $HOME/log
	echo `date` >> $HOME/log

chvt 3
#	qpe 2>>$HOME/log >>$HOME/log
    qpe 2>&1 | logger -t 'Qtopia'

 done

#gifanim $QTOPIA_TOOLS/splash-shutdown-exit.gif &

;;
'stop')

KILLPROGS="qpe qpe.sh quicklauncher mediaserver mediaplayer sipagent"

rm -f /tmp/restart-qtopia

killall $KILLPROGS 2>/dev/null
;;

'restart')
KILLPROGS="qpe qpe.sh quicklauncher mediaserver mediaplayer sipagent"
killall $KILLPROGS 2>/dev/null

;;

esac

