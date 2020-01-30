
# $1 service name
stopService()
{
   /usr/bin/systemctl stop $1
}

# $1 service name
startService()
{
   /usr/bin/systemctl start $1
}

enableService()
{
   /usr/bin/systemctl enable $1
}

disableService()
{
   /usr/bin/systemctl disable $1
}

# $1 full service name
removeService()
{
   echo "removeService '$1' "
   /usr/bin/systemctl stop $1
   /usr/bin/systemctl disable $1
   /usr/bin/systemctl daemon-reload
   /usr/bin/systemctl reset-failed
   #remove the files/links we created when using addService()
   /usr/bin/rm -f /usr/lib/systemd/system/$1
   /usr/bin/rm -f /usr/lib/systemd/system/multi-user.target.wants/$1
}

# $1 /path/to/serviceFileName
addService()
{
   serviceFileName=${1:0}
   serviceFileBaseName=`/usr/bin/basename ${serviceFileName}`
   /usr/bin/echo "adding service '${serviceFileBaseName}' (${serviceFileName})"

   if [ -e $serviceFileName ]; then
      #note:this file will be removed via removeService()
      /usr/bin/cp ${serviceFileName} /usr/lib/systemd/system
      #latch onto multiuser.target (same as WantedBy entry in serviceFileBaseName)
      #/usr/bin/ln -sf /usr/lib/systemd/system/${serviceFileBaseName} /usr/lib/systemd/system/multi-user.target.wants/${serviceFileBaseName}
   else
      /usr/bin/echo "Failed to install service $serviceFileName"
      exit 1
   fi
   /usr/bin/systemctl daemon-reload
}

##not in use; used when there are primary, backup and standalone
# addService()
# {
#    serviceFileName=${1:0}
#    standalone=${2:-0}
#    primary=${3:-0}
#    backup=${4:-0}
#
#    /usr/bin/echo "addService($serviceFileName) to standalone ${standalone}, primary ${primary}, backup ${backup}"
#    serviceFileBaseName=`/usr/bin/basename ${serviceFileName}`
#
#    if [ -e $serviceFileName ]; then
#       /usr/bin/cp $serviceFileName /usr/lib/systemd/system
#    else
#       /usr/bin/echo "Failed to install service $serviceFileName"
#       exit 1
#    fi
#
#    if [ $standalone = 1 ]; then
#       /usr/bin/ln -sf /usr/lib/systemd/system/${serviceFileBaseName} /usr/lib/systemd/system/abacus.standalone.target.wants/${serviceFileBaseName}
#    fi
#
#    if [ ${primary} = 1 ]; then
#       /usr/bin/ln -sf /usr/lib/systemd/system/${serviceFileBaseName} /usr/lib/systemd/system/abacus.primary.target.wants/${serviceFileBaseName}
#    fi
#
#    if [ ${backup} = 1 ]; then
#       /usr/bin/ln -sf /usr/lib/systemd/system/${serviceFileBaseName} /usr/lib/systemd/system/abacus.backup.target.wants/${serviceFileBaseName}
#    fi
#    /usr/bin/systemctl daemon-reload
# }

# $1 = service_name
# returns 0 if OK ; 1 if error. Quits imediately when 'unknown' - not installed.
waitServiceActive()
{
    poll_cnt=0
    while [[ ${poll_cnt} -lt 60 ]]     # 60 seconds should be enough
    do
        svc_is_in_state=`systemctl is-active $1`
        if [ ${svc_is_in_state} = 'active' ]; then
            return 0;
        fi
        if [ ${svc_is_in_state} = 'unknown' ]; then
            return 1;
        fi
        /bin/echo "svc $1 state is " $svc_is_in_state
        sleep 1
        poll_cnt=$((poll_cnt + 1))
    done
    return 1;
}

# $1 = service_name
# $2 = optional timeout in seconds
# returns 0 if OK ; 1 if error. Quits imediately when 'unknown' - not installed.
waitServiceActiveTimeout()
{
    sleep_count=${2:-60}
    poll_cnt=0
    while [[ ${poll_cnt} -lt ${sleep_count} ]]
    do
        svc_is_in_state=`systemctl is-active $1`
        if [ ${svc_is_in_state} = 'active' ]; then
            return 0;
        fi
        if [ ${svc_is_in_state} = 'unknown' ]; then
            return 1;
        fi
        /bin/echo "svc $1 state is " $svc_is_in_state
        sleep 1
        poll_cnt=$((poll_cnt + 1))
    done
    return 1;
}
