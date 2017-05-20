#!/bin/bash
USER=admin 
PASSWORD=admin 
BASEURL="http://10.0.10.11:7180/api/v16"
CLUSTERNAME="test"

STATUSURL="$BASEURL/clusters/$CLUSTERNAME"
COMMANDURL="$BASEURL/commands"
STARTURL="$BASEURL/clusters/$CLUSTERNAME/commands/start"
HOSTSURL="$BASEURL/hosts"

function curlcmd()
{
    local requestID=`curl -s -u $USER:$PASSWORD -X POST "$1" | grep -o '"id" : [^, }]*' | sed 's/^.*: //' | tr -d ','`
    local requestActive="true"
    while [ "$requestActive" == "true" ];
    do 
        sleep 5;
        requestActive=`curl -s -u $USER:$PASSWORD -X GET "$COMMANDURL/$requestID" | grep -m 1 -o '"active" : [^, }]*' | sed 's/^.*: //' | tr -d ','`
        echo -n "."
    done

    local requestSuccess=`curl -s -u $USER:$PASSWORD -X GET "$COMMANDURL/$requestID" | grep -m 1 -o '"success" : [^, }]*' | sed 's/^.*: //' | tr -d ','`
    
    if [ "$requestSuccess" == "true" ]; then  
        echo "."
        echo "Success!"
        return 0
    else
        echo "."
        echo "Failure!"
        return 1
    fi
}

function curlwithretry()
{
    echo -n "$2"
    curlcmd "$1"
    
    if [ "$?" == "1" ]; then
        echo "Will try again."
        sleep 30
        curlcmd "$1"
    fi
    
    if [ "$?" == "1" ]; then
        echo "Not trying again."
        return 1
    fi
    return 0
}

function startservices()
{
    curlwithretry "$STARTURL" "Starting Hadoop services"  

    if [ "$?" == "1" ]; then
        echo "Starting Hadoop services failed"
        return 1
    else 
        echo "Hadoop services successfully started"
        return 0    
    fi
}

function startwithretry()
{
    startservices    

    if [ "$?" == "1" ]; then
        echo "Sleeping, then will try to start services once more"
        sleep 100
        startservices
    else 
        return 0    
    fi

    if [ "$?" == "1" ]; then
        echo "Starting Hadoop the second time failed. Things might not work."
    fi
}

function waitforcdm()
{
    # use this to just see if CDM is accepting requests
    echo -n "Waiting for CDM to respond to API requests"
    local status=`curl -s -i -u $USER:$PASSWORD -X GET "$STATUSURL" | grep -o "OK"`
    while [ "$status" == "" ];
    do
        sleep 5
        echo -n "."
        status=`curl -s -i -u $USER:$PASSWORD -X GET "$STATUSURL" | grep -o "OK"`
    done
    echo "."
    echo "CDM is ready to accept request API requests"
}

waitforcdm
startwithretry