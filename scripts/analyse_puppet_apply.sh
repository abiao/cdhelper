#!/bin/sh

function analyse_puppet_apply {
    logfile=$1
    status=SUCCESS

    while read line
    do
        success_regexpr="Package\[.*\]|Service\[.*\]|File\[.*\]|Retrieving plugin|Applying configuration|Finished catalog run"
        filter_regexpr="content:$|Filebucketed|/File\[/var/lib/puppet/lib"

        sslerr_regexpr="SSL certificate error|Could not request certificate|certificate verify failed"
        sslreq_regexpr="no certificate found and waitforcert is disabled"

        classnotfound_regexpr="Could not find class"
        general_error="err: "
        err_blacklist="Package\[.*\]|Could not retrieve catalog"
        err_whitelist="Could not find package drbd-km"

        #   TODO: more regexpr added here
        #    400 error

        if echo $line | grep -E "$sslerr_regexpr" >/dev/null 2>&1; then
            echo "[IM_CONFIG_WARN]: $line" >> $logfile
            status=SSL_ERROR
        elif echo $line | grep -E "$sslreq_regexpr" >/dev/null 2>&1; then
            echo "[IM_CONFIG_WARN]: $line" >> tee -a $logfile
            status=SSL_REQ
        elif echo $line | grep -E "$classnotfound_regexpr" >/dev/null 2>&1; then
            echo "[IM_CONFIG_WARN]: $line" >> $logfile
            status=CLASSNOTFOUND
        elif echo $line | grep -E "$general_error" >/dev/null 2>&1; then
            if echo $line | grep -Ev "$err_whitelist" >/dev/null 2>&1; then
                if echo $line | grep -E "$err_blacklist" >/dev/null 2>&1; then
                    [ "$status" == "SUCCESS" ] || [ "$status" == "WARN" ] && status="ERROR"
                else
                    [ "$status" == "SUCCESS" ] && status="WARN"
                fi
                echo "[IM_CONFIG_$status]: $line" | tee -a $logfile
            fi
        elif echo $line | grep -E "$success_regexpr" | grep -Ev "$filter_regexpr" >/dev/null 2>&1; then
            echo "[IM_CONFIG_INFO]: $line" | sed "s:'{md5}.*'::g; s:content as:content:g; s:/Stage\[main\]/::g" | tee -a $logfile
        fi
    done

    echo "[PUPPET_APPLY_STATUS]: $status" | tee -a $logfile
}

function split_rotate_log {
    logfile=$1
    rotate_num=${2:-5}
    max_size=${3:-2048}

    [ ! -f $logfile ] && return 1
    logdir=`dirname $logfile`
    baselog=`basename $logfile`

    cd $logdir
    log_size=`du $baselog | cut -f1`

    if [ $log_size -gt $max_size ]; then
        split -b "${max_size}K" $baselog $baselog.

        while [ $rotate_num -gt 1 ]; do
            prev=`expr $rotate_num - 1`
            [ -f "$baselog.$prev" ] && mv "$baselog.$prev" "$baselog.$rotate_num"
            rotate_num=$prev
        done
        mv "$baselog.aa" "$baselog.1";
        mv "$baselog.ab" "$baselog";
    fi
    cd - >/dev/null
}
