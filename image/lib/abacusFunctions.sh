
## To Use these functions, add this to the top of your scipts:
##    source /opt/abacus/abacus-shell-libs/lib/abacusFunctions.sh
##

source /opt/abacus/abacus-shell-libs/lib/serviceFunctions.sh

abacusCreateUser()
{
    if [ $# -ne 2 ]; then
        /usr/bin/echo "abacusCreateUser: username, password argument required"
        return 1
    fi
    userName=$1
    passWord=$2

    /usr/bin/grep -q ${userName} /etc/passwd
    if [ $? -ne 0 ]; then
        /usr/bin/echo "abacusCreateUser: Installing ${userName}"
        /usr/sbin/useradd ${userName}
        /usr/bin/echo ${userName}:${passWord} | /usr/sbin/chpasswd
    else
        /usr/bin/echo "abacusCreateUser: ${userName} user already installed"
    fi
    return 0
}
