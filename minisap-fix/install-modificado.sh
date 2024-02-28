#!/bin/bash

set -o pipefail
set -o nounset

# Allowed range <3, 125>
# http://tldp.org/LDP/abs/html/exitcodes.html
readonly ERR_illegal_task=119
readonly ERR_not_tested_distro=120
readonly ERR_sap_eula_refused=121
readonly ERR_log_file=122
readonly ERR_no_suitable_shell=123
readonly ERR_invalid_hostname=124
readonly ERR_invalid_args=125

ERR_no_tars_found=3
ERR_no_suid=4
ERR_unknown_vendor=5
ERR_handler=6
ERR_display_license=7
ERR_modify_sysctl=8
ERR_backup_sysctl=9
ERR_read_sysctl=10
ERR_reload_sysctl=11
ERR_extraction=12
ERR_create_temp_file=13
ERR_write_temp_file=14
ERR_update_license=15
ERR_unpacking_saphost=16
ERR_cd_hostctrl=17
ERR_install_saphost=18
ERR_unpacking_swpm=19
ERR_sapinst=20
ERR_cleanup_instdir=21
ERR_no_sidadm_home=22
ERR_update_sapenv=23
ERR_remove_sapfqdn=24
ERR_startsap=25
ERR_cd_swpm=26
ERR_missing_deps=27
ERR_cannot_read=28
ERR_stopsap=29
ERR_update_profile=30

readonly ERR_last=30

err_message=(
[0]="no error"
[1]="general error"
[2]="internal error"
[$ERR_no_tars_found]="The installation archive was not found"
[$ERR_no_suid]="You should be root to start this program"
[$ERR_unknown_vendor]="Your distribution is not supported"
[$ERR_handler]="Invalid DB handler"
[$ERR_display_license]="Could not display the license"
[$ERR_modify_sysctl]="Could not modify sysctl.conf"
[$ERR_backup_sysctl]="Could not create a backup of /etc/sysctl.conf"
[$ERR_read_sysctl]="Could not read sysctl configuration"
[$ERR_reload_sysctl]="Could not reload sysctl configuration"
[$ERR_extraction]="Could not extract all tar archives, please check free disk space"
[$ERR_create_temp_file]="Could not create temporary file, please check free disk space"
[$ERR_write_temp_file]="Could not write into temporary file"
[$ERR_update_license]="Could not update the license"
[$ERR_unpacking_saphost]="Could not unpack SAPHostAgent SAR files into temporary directory, please check free disk space"
[$ERR_cd_hostctrl]="SAPHostAgent was not correctly unpacked"
[$ERR_install_saphost]="Could not install saphostexec"
[$ERR_unpacking_swpm]="Could not unpack SWPM SAR files into temporary directory, please check free disk space"
[$ERR_sapinst]="sapinst has finished with an error code, please find logs in /tmp/sapinst_instdir"
[$ERR_cleanup_instdir]="Could not remove previous sapinst_instdir"
[$ERR_no_sidadm_home]="Could get path to SIDadm's home director"
[$ERR_update_sapenv]="Could not update SIDadm's sapenv file"
[$ERR_remove_sapfqdn]="Could remove lines with SAPFQDN from SIDadm's sapenv file"
[$ERR_startsap]="Could not start SAP CI processes"
[$ERR_cd_swpm]="SWPM was not correctly unpacked"
[$ERR_missing_deps]="Exited on user request due to missing dependencies"
[$ERR_cannot_read]="Could not read user input"
[$ERR_stopsap]="Could not stop SAP processes"
[$ERR_update_profile]="Failed to update Profile"
)

readonly TASK_check="c"
readonly TASK_extract="e"
readonly TASK_install="i"
readonly TASK_set_up="s"
readonly TASK_run="r"

usage () {

    cat <<-EOF

###############################################################################
# Call $( basename $0 ) with one or more of the following options
# (or none to use default values):
#
#  h ) own_hostname [phsical hostname] - Specify your own hostname to be used
#                                        by the SAP system, needs to fulfill
#                                        SAP requirements
#
#  s ) Skip hostname checking - set -s flag if our check fails and you are sure
#                               that you chosen have a SAP conform hostname
#
#  k ) Skip setting of Linux kernel parameters - set -k flag if setting Linux
#                                                kernel parameters fails and
#                                                you have catered for the
#                                                requirments
#
#  g ) Guided installation with SAPINSTGUI - use if ou have a working X
#                                            environment or use Windows
#                                            SAPINSTGUI
#
#  t ) Tasks to execute - Please be sure you know what you are doing!
#                         DEFAULT = "ceisr"
#                           * c - check
#                           * e - extract
#                           * i - install
#                           * s - set up
#                           * r - run processes
###############################################################################
EOF
    echo
}

skip_hostname_check="n"
skip_kernel_parameters="n"
guimode="n"
tasks="${TASK_check}${TASK_extract}${TASK_install}${TASK_set_up}${TASK_run}"

while getopts "h:skgt:" options; do
    case $options in
        h) own_hostname="$OPTARG"  # Virtual Hostname to use, e.g. ownhost
            ;;

        s) skip_hostname_check="y"  # Skip Hostname checking
            ;;

        k) skip_kernel_parameters="y"  # Skip setting kernel parameters
            ;;

        g) guimode="y"  # Use GUI mode of SAPINST
            ;;

        t) tasks="$OPTARG"
           echo $tasks | grep -q -E "[^${TASK_check}${TASK_extract}${TASK_install}${TASK_set_up}${TASK_run}]" && {
               echo "$0: illegal task string: $tasks" >&2
               exit $ERR_illegal_task
           }
            ;;

        \?) usage
            exit $ERR_invalid_args
            ;;

        * ) usage
            exit $ERR_invalid_args
            ;;
    esac
done

if [ $OPTIND -le $# ]; then
    echo "$0: illegal parameter -- ${!OPTIND}" >&2
    usage
    exit $ERR_invalid_args
fi

SID="NPL"
sid=$( echo $SID | tr '[:upper:]' '[:lower:]' )

###########################################
#
#
# INSTALL ${SID}
#
#
###########################################

sap_server_tar="dbdata.tgz-* dblog.tgz-* dbexe.tgz-* usrsap.tgz-* sapmnt.tgz-*"

dvd_dist_dir=server/TAR/x86_64

log_file="${SAP_LOG_FILE:-}"
# Make sure the fd is not opened
exec 3<&-
exec 3>&-
log_file_fd=/proc/self/fd/3

# Network Configuration
REAL_HOSTNAME=$( hostname )
virt_hostname="${own_hostname:-${REAL_HOSTNAME}}"

if [ x"${skip_hostname_check}" = "xy" ]; then
    echo "Hostname check skipped!"
else
    i="${virt_hostname}"
    if [ ${#i} -gt 13 ]; then
        cat >&2 <<_EOF
The length of the hostname you have chosen exceeds 13 character, this is not
supported by SAP, please use a different hostname, please check your hostname
selection. Start the install script with -s flag to skip the hostname check.
_EOF

        exit $ERR_invalid_hostname
    fi

    ping_bin="ping"
    if ping -4 -c1 127.0.0.1 &>/dev/null; then
        ping_bin="ping -4"
    fi

    hostip=$( $ping_bin -c1 -n "${virt_hostname}" | head -n1 | sed "s/.*(\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)).*/\1/g" )
    if [ "_" == "_$hostip" ]; then
        echo "Failed to get IP of ${virt_hostname}" >&2
        echo "The hostname check has failed" >&2
        exit $ERR_invalid_hostname
    fi

    if ! ip -4 addr show scope global | grep -q "inet $hostip/"; then
        cat >&2 <<_EOF
The hostname you have chosen is either configured on a loopback device or not
active on this server, please check your configuration and hostname selection.
If you are confident about your choice of hostname, start the install script
with -s flag to skip the hostname check.
_EOF

        exit $ERR_invalid_hostname
    fi

    echo "Hostname ${virt_hostname} assumed to be SAP compliant"
fi

# Functions:
# ---------------
start_logging() {
# ---------------
# Opens the log file under the file descriptor 3
# and copy stderr of all commands to the log file
# via the command tee.
# ---------------

    if [ -e "$log_file_fd" ]; then
        # Logging has already been started
        return 0
    fi

    if [ -z "${log_file}" ]; then
        log_file=./install_$( date +%F_%H-%M-%S ).log
    fi

    touch "${log_file}" || {
        echo "The log file ${log_file} seems NOT to be writable"
        exit $ERR_log_file
    }

    exec 3>"${log_file}" || {
        echo "Could not open LOG file descriptor on number 3"
        exit $ERR_log_file
    }

    exec 2> >(tee -a $log_file_fd >&2) || {
        echo "Could not forward STDERR to LOG file descriptor"
        exit $ERR_log_file
    }
}


#----------
log_err() {
#----------

    local log_value="$@"

    start_logging

    echo -e "Error: ${log_value}" >&2
}

#----------
log_cmd() {
#----------

    start_logging

    $@ &>> $log_file_fd
}


#-------
log() {
#-------

    local log_value="$@"

    start_logging

    echo -e "${log_value}" >>$log_file_fd
}

#-------
log_echo() {
#-------

    local log_value="$@"

    log "$log_value"

    echo -e "${log_value}"
}

#-----------
do_exit() {
#-----------

    local exit_code=$1
    shift

    if [ $# -ge 1 ]; then
        log_err "$@"
    fi

    if [ $exit_code -le $ERR_last ]; then
        log_err "${err_message[${exit_code}]}"
    fi

    log "Error code: ${exit_code}"

    log "++++ Support data section BEGIN ++++"

    log "* mount"
    log_cmd mount

    log "* df -h"
    log_cmd df -h

    log "* df -hi"
    log_cmd df -hi

    log "* cat /etc/os-release"
    log_cmd cat /etc/os-release

    log "* ls -ld / /sybase /usr/sap /sapmnt"
    log_cmd ls -ld / /sybase /usr/sap /sapmnt

    log "++++ Support data section END ++++"

    log_echo "All logs have been written to the file $( readlink -f $log_file_fd )"
    log_echo "Please see readme.html to find out how to get help"

    exit ${exit_code}
}

#-------------
get_distro() {
#-------------

    ( source ${test_check_vendor_os_release_path:-/etc/os-release} && echo $ID ) || echo "unknown"
}

#----------------
check_vendor() {
#----------------

    declare -r distro=$( get_distro )

    case "$distro" in
        fedora|centos|rhel|sles|opensuse|opensuse-leap|ubuntu)
            log_echo "Running on tested distribution ${distro}"
            ;;

        *)  log_echo "Your distribution '${distro}' was not tested. Do you want to continue?"

            read answer
            case $answer in
                y|Y|yes|YES) log "Proceeding with the installation"
                    ;;

                *) do_exit $ERR_not_tested_distro
                    ;;
            esac

            echo "You have chosen to continue with install in non tested distribution"
            echo "and we encourage you to share your experience with the SAP community"
            ;;
    esac
}

#------------------------------
report_missing_dependencies() {
#------------------------------

    declare -r bins=( which tar ping clear hostname sed gzip )
    declare -r sbins=( ip uuidd sysctl )
    declare -r libs=( libaio libstdc++ libnsl )
    declare -r files=( /etc/pam.d/passwd /etc/services /etc/sysctl.conf )

    emit() {
        local dep=$1; shift
        printf "%s " $dep
    }

    test_and_emit_executable() {
        local dir="${1}"; shift
        local name="${1}"; shift

        local tst="${dir}/${name}"
        local usrtst="/usr${tst}"

        if [[ ! -x "${tst}" ]] && [[ ! -x "${usrtst}" ]]; then
            log_err "${tst}: not executable file"
            emit "${name}"
        fi
    }

    for exe in "${bins[@]}"; do
        test_and_emit_executable "/bin" "${exe}"
    done

    for exe in "${sbins[@]}"; do
        test_and_emit_executable "/sbin" "${exe}"
    done

    # Piping ldconfig into grep directly was causing SIGPIPE on Fedora 28
    declare -r ldconfig_cache_file="/tmp/sap.td.install.sh.ldconfig"

    # ldconfig is a part of glibc and is necessary for dynamic linking
    if /sbin/ldconfig -p >${ldconfig_cache_file} 2>${log_file_fd}; then
        for lib in "${libs[@]}"; do
            grep -q "${lib}\.so\." ${ldconfig_cache_file} || {
                log_err "${lib}: shared library not found"
                emit "${lib}"
            }
        done
        rm $ldconfig_cache_file
    else
        log "ldconfig failed: dependent shared libraries cannot be checked"
    fi

    for file in "${files[@]}"; do
        [[ ! -f "${file}" ]] && {
            log_err "${file}: file not found"
            emit "${file}"
        }
    done
}

#---------------------------
dependencies_to_packages() {
#---------------------------

    declare -r pkg_distro=$1; shift

    declare -r dep_which=0
    declare -r dep_tar=1
    declare -r dep_ping=2
    declare -r dep_ip=3
    declare -r dep_clear=4
    declare -r dep_hostname=5
    declare -r dep_uuidd=6
    declare -r dep_sed=7
    declare -r dep_sysctl=8
    declare -r dep_libaio=9
    declare -r dep_libstdcpp=10
    declare -r dep_libnsl=11
    declare -r dep_pampasswd=12
    declare -r dep_services=13
    declare -r dep_sysctlconf=14
    declare -r dep_gzip=15

    case $pkg_distro in
        ubuntu)
            pkg_list=(
                [$dep_which]="debianutils"
                [$dep_tar]="tar"
                [$dep_ping]="iputils-ping"
                [$dep_ip]="iproute2"
                [$dep_clear]="ncurses-bin"
                [$dep_hostname]="hostname"
                [$dep_uuidd]="uuid-runtime"
                [$dep_sed]="sed"
                [$dep_sysctl]="procps"
                [$dep_libaio]="libaio1"
                [$dep_libstdcpp]="libstdc++6"
                [$dep_libnsl]="libc6"
                [$dep_pampasswd]="passwd"
                [$dep_services]="netbase"
                [$dep_sysctlconf]="procps"
                [$dep_gzip]="gzip"
            )
            ;;
        opensuse|opensuse-leap)
            pkg_list=(
                [$dep_which]="which"
                [$dep_tar]="tar"
                [$dep_ping]="iputils"
                [$dep_ip]="iproute2"
                [$dep_clear]="ncurses-utils"
                [$dep_hostname]="net-tools"
                [$dep_uuidd]="uuidd"
                [$dep_sed]="sed"
                [$dep_sysctl]="procps"
                [$dep_libaio]="libaio1"
                [$dep_libstdcpp]="libstdc++6"
                [$dep_libnsl]="glibc"
                [$dep_pampasswd]="shadow"
                [$dep_services]="netcfg"
                [$dep_sysctlconf]="aaa_base"
                [$dep_gzip]="gzip"
            )
            ;;
        centos)
            pkg_list=(
                [$dep_which]="which"
                [$dep_tar]="tar"
                [$dep_ping]="iputils"
                [$dep_ip]="iproute"
                [$dep_clear]="ncurses"
                [$dep_hostname]="hostname"
                [$dep_uuidd]="uuidd"
                [$dep_sed]="sed"
                [$dep_sysctl]="procps-ng"
                [$dep_libaio]="libaio"
                [$dep_libstdcpp]="libstdc++"
                [$dep_libnsl]="glibc"
                [$dep_pampasswd]="passwd"
                [$dep_services]="setup"
                [$dep_sysctlconf]="initscripts"
                [$dep_gzip]="gzip"
            )
            ;;
        fedora)
            pkg_list=(
                [$dep_which]="which"
                [$dep_tar]="tar"
                [$dep_ping]="iputils"
                [$dep_ip]="iproute"
                [$dep_clear]="ncurses"
                [$dep_hostname]="hostname"
                [$dep_uuidd]="uuidd"
                [$dep_sed]="sed"
                [$dep_sysctl]="procps-ng"
                [$dep_libaio]="libaio"
                [$dep_libstdcpp]="libstdc++"
                [$dep_libnsl]="libnsl"
                [$dep_pampasswd]="passwd"
                [$dep_services]="setup"
                [$dep_sysctlconf]="systemd"
                [$dep_gzip]="gzip"
            )
            ;;
    esac

    for dep in $@; do
        case ${dep} in
            which)              echo ${pkg_list[$dep_which]} ;;
            tar)                echo ${pkg_list[$dep_tar]} ;;
            ping)               echo ${pkg_list[$dep_ping]} ;;
            ip)                 echo ${pkg_list[$dep_ip]} ;;
            clear)              echo ${pkg_list[$dep_clear]} ;;
            hostname)           echo ${pkg_list[$dep_hostname]} ;;
            uuidd)              echo ${pkg_list[$dep_uuidd]} ;;
            sed)                echo ${pkg_list[$dep_sed]} ;;
            sysctl)             echo ${pkg_list[$dep_sysctl]} ;;
            libaio)             echo ${pkg_list[$dep_libaio]} ;;
            libstdc++)          echo ${pkg_list[$dep_libstdcpp]} ;;
            libnsl)             echo ${pkg_list[$dep_libnsl]} ;;
            /etc/pam.d/passwd)  echo ${pkg_list[$dep_pampasswd]} ;;
            /etc/services)      echo ${pkg_list[$dep_services]} ;;
            /etc/sysctl.conf)   echo ${pkg_list[$dep_sysctlconf]} ;;
            gzip)               echo ${pkg_list[$dep_gzip]} ;;

            *) log_err "unrecognized dependency: ${dep}"
                ;;
        esac
    done | sort -u | tr "\n" " "
}


#-----------------
ask_yes_or_no() {
#-----------------

    declare -r message=$1; shift

    while true; do
        log_echo "$message yes/no: "

        read answer || do_exit $ERR_cannot_read

        case ${answer} in
            y|Y|yes|YES|Yes)    return 0 ;;
            n|N|no|NO|No)       return 1 ;;
        esac
    done
}

#-------------------
install_packages() {
#-------------------

    declare -r ins_distro=$1; shift

    case "$ins_distro" in
        ubuntu)
            apt-get update && apt-get install $@
            ;;

        opensuse|opensuse-leap)
            zypper refresh && zypper install $@
            ;;

        centos)
            yum makecache && yum install $@
            ;;

        fedora)
            dnf makecache && dnf install $@
            ;;
    esac
}

#---------------------
check_dependencies() {
#---------------------

    declare -r dep_distro=$( get_distro )

    declare -r missing_deps=($( report_missing_dependencies ))

    [[ 0 -eq ${#missing_deps[@]} ]] && return

    case "$dep_distro" in
        fedora|centos|opensuse|opensuse-leap|ubuntu)
            declare -r missing_packages=($( dependencies_to_packages $dep_distro "${missing_deps[@]}" ))

            log_echo "The following packages can provide the missing dependencies:"
            for pkg in "${missing_packages[@]}"; do
                log_echo "  ${pkg}"
            done

            ask_yes_or_no "Do you want to install the packages via your manager?" && {
                install_packages $dep_distro "${missing_packages[@]}"
            }
            ;;

        *)
            ask_yes_or_no "Do you want to continue regardless of the missing dependencies?" || {
                do_exit $ERR_missing_deps
            }
            ;;
    esac
}

#----------------
replace_dblicense() {
#----------------

    local db_dist_dir=${1}
    shift
    local db_sid=${1}
    shift

    local system_lic_dir="/${test_replace_dblicense_dbdir:-sybase}/${db_sid}/SYSAM-2_0/licenses"

    log_echo "Checking presence of new SYBASE license files"

    local changed_license=false
    for new_lic_file in $(find ${db_dist_dir} -name "*.lic"); do
        changed_license=true
        local system_lic_file="${system_lic_dir}/$(basename ${new_lic_file})"

        local update_method="Added the license file"
        if [ -e "${system_lic_file}" ]; then
            update_method="Replaced the license file"
        fi

        cp -p "${new_lic_file}" "${system_lic_file}" || do_exit $ERR_update_license
        log_echo "${update_method} ${system_lic_file}"
    done

    if ! ${changed_license}; then
        log_echo "No new licenses were copied from ${db_dist_dir} to ${system_lic_dir}"
    fi
}

#--------------
check_dist() {
#--------------
# check the distribution directory:
# all files to be installed must be present

    drive=${1}
    dirname=${drive}/${dvd_dist_dir}

    if [ -f /sapmnt/${SID}/profile/DEFAULT.PFL ]; then
        log_echo "Found files from previous installation, please clean up if you want to run a"
        log_echo "new installation! Otherwise, we just overwrite /sapmnt/NPL directory, so that"
        log_echo "you can safely resume the installation"

        sap_server_tar="sapmnt.tgz-*"

        echo "Hit enter to continue otherwise use Ctrl-C!"
        read
    fi

    for name in ${sap_server_tar}
    do
        if [ -e "${dirname}/${name}" ]; then
            do_exit ${ERR_no_tars_found} "File ${dirname}/${name} not found."
        fi
    done
}

#--------------
function update_sysctl_conf () {
#--------------
    # We expect sysctl-parmname and value as parameters
    # eg. "update_sysctl_conf kernel.shmmax 21474836480"

    local date oldstring newstring

    local name=$1
    shift
    local value=$1

    log_echo "Updating the sysctl option $name"

    date=$( date -u +"%Y-%m-%d %H:%M:%S %Z" )
    newstring="$name=$value"
    oldstring=$( tac /etc/sysctl.conf | grep -m1 -E "^[^#]*$1=" )

    if [ $? -eq 0 ]; then # entry there, update
        if [ "$oldstring" != "$newstring" ]; then
            sed -i "s@$oldstring@# Changed by SAP TestDrive on $date\n#&\n$newstring@" /etc/sysctl.conf || do_exit $ERR_modify_sysctl

            log_echo "The option $name has been changed to $value"
        else
            log_echo "The option $name has already been configured"
        fi
    else # no entry, make one
        echo -e "# Added by SAP TestDrive on $date\n$newstring" >> /etc/sysctl.conf || do_exit $ERR_modify_sysctl

        log_echo "The option $name was added to the configuration file"
    fi
}

#---------------------------
function get_sysctl_conf() {
#---------------------------

    local config_option=$1

    sysctl -n $config_option

    return $?
}

#-----------------
function calculate_sysctl() {
#-----------------

    local CHANGE=""

    log_echo "Checking Linux kernel memory management parameters according to SAP Note 941735"

    if [ -f /etc/sysctl.conf ]; then
        log_echo "Backing up /etc/sysctl.conf in /etc/sysctl.backup"

        cp -a /etc/sysctl.conf /etc/sysctl.backup || do_exit $ERR_backup_sysctl
    fi
#   echo "Update the necessary information in sysctl.conf:"

    SHMALL_MIN=5242880 # 20 GB (SAP Note 941735)
    SHMALL=$( get_sysctl_conf kernel.shmall ) || do_exit $ERR_read_sysctl
    i=${SHMALL}

    if [ ${#i} -le 11  ]; then
        [ ${SHMALL_MIN} -gt ${SHMALL} ] && update_sysctl_conf kernel.shmall $SHMALL_MIN

        SHMMAX_MIN=21474836480 # 20 GB (SAP Note 941735)
        SHMMAX=$( get_sysctl_conf kernel.shmmax ) || do_exit $ERR_read_sysctl
        # value can get too large for test -gt
        # [ ${SHMMAX_MIN} -gt ${SHMMAX} ] && update_sysctl_conf kernel.shmmax $SHMMAX_MIN
        [ $(( ${SHMMAX_MIN} > ${SHMMAX} )) ] && update_sysctl_conf kernel.shmmax $SHMMAX_MIN
    fi

    SEMMSL_MIN=1250
    SEMMNS_MIN=256000
    SEMOPM_MIN=100
    SEMMNI_MIN=8192

    local KERNEL_SEM=($( get_sysctl_conf kernel.sem )) || $ERR_read_sysctl
    [ "${#KERNEL_SEM[*]}" -ne "4" ] && do_exit $ERR_unexpected_sysctl

    SEMMSL=${KERNEL_SEM[0]}
    SEMMNS=${KERNEL_SEM[1]}
    SEMOPM=${KERNEL_SEM[2]}
    SEMMNI=${KERNEL_SEM[3]}

    [ ${SEMMSL_MIN} -gt ${SEMMSL} ] && SEMMSL=${SEMMSL_MIN} && CHANGE="x"
    [ ${SEMMNS_MIN} -gt ${SEMMNS} ] && SEMMNS=${SEMMNS_MIN} && CHANGE="x"
    [ ${SEMOPM_MIN} -gt ${SEMOPM} ] && SEMOPM=${SEMOPM_MIN} && CHANGE="x"
    [ ${SEMMNI_MIN} -gt ${SEMMNI} ] && SEMMNI=${SEMMNI_MIN} && CHANGE="x"
    [ -n "${CHANGE}" ] && update_sysctl_conf kernel.sem "$SEMMSL $SEMMNS $SEMOPM $SEMMNI"

    log_echo "Checking Linux kernel parameter vm.max_map_count according to SAP Note 900929"
    MAX_MAP_COUNT_MIN=1000000 # (SAP Note 900929)
    MAX_MAP_COUNT=$( get_sysctl_conf vm.max_map_count ) || $ERR_read_sysctl
    [ ${MAX_MAP_COUNT_MIN} -gt ${MAX_MAP_COUNT} ] && update_sysctl_conf vm.max_map_count $MAX_MAP_COUNT_MIN

    sysctl -q -p || do_exit $ERR_reload_sysctl
}

#-------------------
check_for_shell() {
#-------------------

   if [ ! -e $1 ]; then
       cat >&2 <<_EOF

Warning: $1 not found.
You need a $2 to start the server.

_EOF

       do_exit $ERR_no_suitable_shell
   fi
}

#--------------------
ask_for_password() {
#--------------------

    local answer answer2 password

    password="$1"

    log_echo "Please enter a password:"
    read -rs answer

    log_echo "Please re-enter password for verification:"
    read -rs answer2

    if [ "$answer" == "$answer2" ]; then
        export ${password}="$answer"
    else
        log_echo "Sorry, passwords do not match."
        ask_for_password ${password}
    fi

    echo " "
}

#---------------
extract_tar() {
#---------------

    echo
    log_echo "extracting data archives..."

    for tar_file in ${sap_server_tar}
    do
        log_echo "extracting ${dvd_drive}/${dvd_dist_dir}/${tar_file}"
        cat "${dvd_drive}/${dvd_dist_dir}"/${tar_file} | tar -zpxvf - -C / || do_exit $ERR_extraction
    done
}

#------------------
server_install() {
#------------------

    # now install the software
    if [ x"${skip_kernel_parameters}" = "xy" ]; then
        log_echo "Kernel parameters not set!"
    else
        calculate_sysctl
    fi

    replace_dblicense "${dvd_drive}/${dvd_dist_dir}" ${SID}

    /usr/sap/${SID}/SYS/exe/run/SAPCAR -xf "${dvd_drive}/${dvd_dist_dir}"/SAPHOSTAGENT*.SAR -R /tmp/hostctrl || do_exit $ERR_unpacking_saphost

    cd /tmp/hostctrl/ || do_exit $ERR_cd_hostctrl

    #./saphostexec -install || do_exit $ERR_install_saphost

    # TODO: is it ok to remove /tmp/hostctrl?
    #cd /
    #rm -rf /tmp/hostctrl || log_echo "Failed to clean up temporary directory"


	#Replace this line with one which tries to continue (this) main script using ‘&’:
    #./saphostexec -install || do_exit $ERR_install_saphost
    ./saphostexec -install &

#Wait for a while so that hopefully the asynchronous call ends:
    log_echo "Waiting 30 seconds for asynchronous call to /tmp/hostctrl/saphostexec -install to complete..."
    sleep 30
    log_echo "30 seconds are up, continuing the main script."

    # TODO: is it ok to remove /tmp/hostctrl?
    cd /
	#Let's not remove the temporary directory, in case saphostexec command
	#is still executing. So commenting out:
		# rm -rf /tmp/hostctrl || log_echo "Failed to clean up temporary directory"

	# Now we modify the RUN_NPL executable (executable permissions are for sybnpl user):
	FILENPL=/sybase/NPL/ASE-16_0/install/RUN_NPL
	if test -f "$FILENPL"; then
		echo "$FILENPL exists. Adding the -T11889 option to config in that file:"
		sed -i 's/NPL.cfg \\/NPL.cfg -T11889 \\/g' /sybase/NPL/ASE-16_0/install/RUN_NPL
		cat $FILENPL
		echo "-T11889 config option added"
		sleep 15
	else
		echo "$FILENPL does not exist. Not modifying what doesn't exist, ontologically seems ok."
	fi

    #/cal/plugins/initial_hook.sh

    /usr/sap/hostctrl/exe/SAPCAR -xf "${dvd_drive}/${dvd_dist_dir}"/SWPM10*.SAR -R /tmp/swpm || do_exit $ERR_unpacking_swpm

    cd /tmp/swpm/ || do_exit $ERR_cd_swpm

    readonly sapinstmod_file="$( pwd )/sapinstmod.txt"
    cp "${dvd_drive}/${dvd_dist_dir}/sapinst.txt" "$sapinstmod_file" || do_exit $ERR_create_temp_file
    sed -i  "s/<INST_HOST>/${virt_hostname}/g" "$sapinstmod_file" || do_exit $ERR_write_temp_file
    sed -i  "s/<Appl1ance>/${masterpwd}/g" "$sapinstmod_file" || do_exit $ERR_write_temp_file

    local sapinst_params=""
    if [ x"${guimode}" != "xy" ]; then
        sapinst_params="$sapinst_params -nogui -noguiserver SAPINST_SKIP_DIALOGS=true"
    fi

    ./sapinst product.catalog SAPINST_EXECUTE_PRODUCT_ID=NW_StorageBasedCopy SAPINST_INPUT_PARAMETERS_URL="$sapinstmod_file" \
        $sapinst_params || do_exit $ERR_sapinst

    rm -rf /tmp/swpm || log_echo "Failed to clean up temporary directory"
    rm -rf /tmp/sapinst_instdir || log_echo "Failed to clean up temporary directory"

    local sidadmhome=$( eval echo "~${sid}adm" )
    [ "" = "$sidadmhome" ] && do_exit $ERR_no_sidadm_home

    echo "setenv LD_LIBRARY_PATH /usr/sap/NPL/hdbclient:\$LD_LIBRARY_PATH" >> "${sidadmhome}/.sapenv_${REAL_HOSTNAME}".csh || do_exit $ERR_update_sapenv
}

#--------------------
set_profile_param() {
#--------------------

    # Please make sure you do not pass the following characters in the param
    # and the value arguments:
    #  \ & |
    #
    # If you need them, then adapt the sed commands below.

    declare -r param="$1"; shift
    declare -r new_value="$1"; shift

    while [[ $# -ge 1 ]]; do
        declare -r profile="$1"; shift

        # Beware of adding local or readonly or declare - it resets return code to 0.
        # TODO: detect commend parameters and uncomment them
        old_value=$(cat ${profile} | grep -E "^\<${param}\> = .*$" | cut -d ' ' -f 3-)

        if [[ $? -eq 0 ]]; then
            if [[ "${new_value}" != "${old_value}" ]]; then
                log_echo "Profile ${profile}: changing ${param} from ${old_value} to ${new_value}"

                sed -e 's|'"${param}"' = '"${old_value}"'|'"${param}"' = '"${new_value}"'|g' -i ${profile} || {
                    do_exit $ERR_update_profile
                }
            else
                log_echo "Profile ${profile}: ${param} is already ${old_value}"
            fi
        else
            log_echo "Profile ${profile}: adding ${param} = ${new_value}"

            echo "${param} = ${new_value}" >> ${profile} || do_exit $ERR_update_profile
        fi
    done
}

#-----------------------
update_configuration() {
#------------------------

    sed -i '/SAPFQDN/d' /sapmnt/${SID}/profile/DEFAULT.PFL /sapmnt/${SID}/profile/${SID}_ASCS01* /sapmnt/${SID}/profile/${SID}_D00_* || do_exit $ERR_remove_sapfqdn

    log_echo "Configure profiles for 4GB physical memory"
    set_profile_param "PHYS_MEMSIZE" "2048" /sapmnt/${SID}/profile/${SID}_D00_*
    set_profile_param "abap/shared_objects_size_MB" "386" /sapmnt/${SID}/profile/${SID}_D00_*

    # Do not use Weak TLS that was deprecated by GitHub - see SAP note 510007, section 7
    log_echo "Configuring strong TLS according to SAP Note 510007"
    set_profile_param "ssl/ciphersuites" "135:PFS:HIGH::EC_P256:EC_HIGH" /sapmnt/NPL/profile/DEFAULT.PFL
    set_profile_param "ssl/client_ciphersuites" "150:PFS:HIGH::EC_P256:EC_HIGH" /sapmnt/NPL/profile/DEFAULT.PFL
}

#------------------
start_processes() {
#------------------

    case "$( get_distro )" in
        ubuntu)
            su -c "stopsap ALL" -l ${sid}adm || do_exit $ERR_stopsap
            su -c "startsap ALL" -l ${sid}adm || do_exit $ERR_startsap
            ;;
        *)
            su -c "startsap r3" -l ${sid}adm || do_exit $ERR_startsap
            ;;
    esac

}

#---------------------
ask_which_license() {
#---------------------

    echo " "
    log_echo "To install this TestDrive you have to accept "
    echo ""
    log_echo "the SAP COMMUNITY DEVELOPER License (DEV)."
    echo ""

    answer=DEV

    case "$answer" in
        "DEV"|"dev" ) show_license SAP_COMMUNITY_DEVELOPER_License
            ;;

        * ) echo "DEV"
            ask_which_license
            ;;
    esac
}

#----------------
show_license() {
#----------------

    cat "${dvd_drive}/$1" | ${PAGER:-more} || do_exit $ERR_display_license
    accept_license
}

#------------------
accept_license() {
#------------------

    local answer=""

    echo " "
    log_echo "Do you agree to the above license terms? yes/no:"

    read answer $answer
    log "User's response to the accept license prompt = '$answer'"

    case "$answer" in
        yes|y|Y ) echo " "
            ;;

        no|n|N ) log_echo "The license has been refused. Exiting!"
            exit ${ERR_sap_eula_refused}
            ;;

        * ) echo "yes/no"
            accept_license
            ;;
    esac
}


#-----------------------------------------------------------
#
# Main
#
#-----------------------------------------------------------
function main () {
#-----------------------------------------------------------

    local install_script_path=$( readlink -f "$0" )
    local install_script_md5sum=$( md5sum "$install_script_path" )
    log_cmd echo "Script version: $install_script_md5sum"

    dvd_drive=$( dirname "$install_script_path" )

    echo $tasks | grep -q $TASK_check && {
        # check for root:
        [ "x$( id -u )" != "x0" ] && do_exit ${ERR_no_suid}

        # check_for_shell "/bin/ksh" "Korn Shell"
        check_for_shell "/bin/csh" "C Shell"

        # mkdir -m 755 -p /db2

        check_dist "${dvd_drive}"
        check_vendor
        check_dependencies
    }

    clear
    echo " "
    echo "#============================================ "
    echo "# "
    echo "# Installing SAP Developer Edition  "
    echo "# "
    echo "#============================================ "
    echo " "
    echo " "
    echo "You are about to install the SAP Developer Edition"
    echo "Please make sure you have carefully read and understood the documentation"
    echo " "

    ask_which_license

    echo " "
    echo "Now we need the passwords for the OS users."
    echo "Please enter a password which will be used"
    echo "for all operating system users."
    echo " "

    ask_for_password masterpwd

    echo " "
    echo "Now we begin with the installation."
    echo "Be patient, this will take a while ... "
    echo " "

    echo $tasks | grep -q $TASK_extract && {
        extract_tar
    }

    echo $tasks | grep -q $TASK_install && {
        server_install
    }

    echo $tasks | grep -q $TASK_set_up && {
        update_configuration
    }

    echo $tasks | grep -q $TASK_run && {
        start_processes
    }

    log_echo "Installation of ${SID} successful"
    echo " "

    exit 0
}

if [ "x${SAP_INSTALL_SH_SOURCED:-}" = "x" ]; then
    start_logging

    main
else
    cat >&2 <<_EOF
WARNING: the install script will not be executed because
the environment varialbe SAP_INSTALL_SH_SOURCED is not empty
_EOF
fi
############################################################
