#!/bin/bash

function ask {
    echo "You are about to deprecate train: ${TRAIN_NAME}"
    echo "[y/n]?"
    read -n 1 -r -p "$1"
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
            return 1;
    else
            echo "Abort.."
            exit
    fi
}


TRAIN_NAME=${1:?"Please give me a train name, e.g., LimingTest"}

ask

CMD=' mysql -u <user> -D <db_name> -h <host_name>  --password=<pwd> '

echo "Before:"
$CMD -e "select id, name, state, type, active from build_trains where name = '$TRAIN_NAME' "

$CMD -e "update build_trains set active=null where name = '$TRAIN_NAME' "

echo "After:"
$CMD -e "select id, name, state, type, active from build_trains where name = '$TRAIN_NAME' "
