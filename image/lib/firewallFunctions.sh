
# $1 is the firewalld service name to remove
firewallRemoveService()
{
    waitServiceActive firewalld
    is_active=$?
    if [ ${is_active} = 0 ]; then
        /bin/echo "Disable ${1} traffic in the firewall"
        svc_available=`/usr/bin/firewall-cmd --get-services|grep ${1} |wc -l`
        if [ $svc_available -ne 0 ]; then
            # remove firewall hole in firewall for svc.
            svc=`/usr/bin/firewall-cmd --query-service=${1}`
            if [ ${svc} = 'yes' ]; then
                /usr/bin/firewall-cmd  --remove-service=${1}
            fi
        fi

        svc_available=`/usr/bin/firewall-cmd --permanent --get-services|grep ${1}|wc -l`
        if [ $svc_available -ne 0 ]; then
            svc=`/usr/bin/firewall-cmd --permanent --query-service=${1}`
            if [ ${svc} = 'no' ]; then
                /usr/bin/firewall-cmd  --permanent --remove-service=${1}
            fi
        fi
    fi
}

# $1 is the firewalld service name to add.
firewallAddService()
{
    # Before issuing firewall-cmd commands the firewalld daemon must be in the active state.
    waitServiceActive firewalld
    is_active=$?
    if [ ${is_active} = 0 ]; then
        /bin/echo "Enabling ${1} to pass through the firewall"
        svc_available=`/usr/bin/firewall-cmd --get-services|grep ${1} |wc -l`
        if [ $svc_available -ne 0 ]; then
            svc=`/usr/bin/firewall-cmd --query-service=${1} `
            if [ ${svc} = 'no' ]; then
                /usr/bin/firewall-cmd --add-service=${1}
            fi
        fi

        svc_available=`/usr/bin/firewall-cmd --permanent --get-services|grep ${1} |wc -l`
        if [ $svc_available -ne 0 ]; then
            svc=`/usr/bin/firewall-cmd --permanent --query-service=${1} `
            if [ ${svc} = 'no' ]; then
                /usr/bin/firewall-cmd --permanent --add-service=${1}
            fi
        fi
    fi
}
