#!/bin/sh

source conf/set.sh

CM_CLUSTER_API=/clusters/${CM_CLUSTER_NAME}

function cm_api() {
    MOUNT_POINT=$(echo "$1" | sed -e 's# #%20#g')
    CONTENT=$2

    AUTHORIZATION=$(echo -n "${CM_USERNAME}:${CM_PASSWORD}" | base64)

    HTTP_REQUEST="POST /api/v${CM_API_VERSION}${MOUNT_POINT} HTTP/1.0\r\n"
    HTTP_REQUEST="${HTTP_REQUEST}Authorization: Basic ${AUTHORIZATION}\r\n"
    HTTP_REQUEST="${HTTP_REQUEST}Content-Type: application/json\r\n"
    HTTP_REQUEST="${HTTP_REQUEST}Content-Length: ${#CONTENT}\r\n"
    HTTP_REQUEST="${HTTP_REQUEST}\r\n"
    HTTP_REQUEST="${HTTP_REQUEST}${CONTENT}"
    for i in {1..300} ; do
        HTTP_RESPONSE=$(echo -e -n "$HTTP_REQUEST" | nc ${CM_HOSTNAME} 7180)
        echo "$HTTP_RESPONSE" | grep 'HTTP/1.1 200 OK' > /dev/null 2>&1
        local OK=$?
        echo "$HTTP_RESPONSE" | grep 'success.*false' > /dev/null 2>&1
        local notSuccess=$?
        if [ "$OK" == "0" -a "$notSuccess" == "1" ] ; then break; fi
        sleep 1
    done
}
