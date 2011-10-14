#!/bin/bash
# License: BSD License
#
## credit:
## http://redflo.de/tiki-index.php?page=Bash+script+with+timeout+function
#

# As Example we start 3 production processes in the background
# always record PID in PRODPID

sleep 50 &
PRODPID[1]=$!

sleep 20 &
PRODPID[2]=$!

# multiple processes in a subshell as example
(sleep 20 ; sleep 10 ; sleep 5)&
PRODPID[3]=$!

export PRODPID


# record own PID
export PID=$$

# define exit function
exit_timeout() {
  echo "Timeout. These processes are not finished:"
  for i in ${PRODPID[@]} ; do
    ps -p $i |grep -v "PID TTY      TIME CMD"
    if [ $? == 0 ] ; then
      # process still alive
      echo "Sending SIGTERM to process $i"
      kill $i
    fi
  done
  # timeout exit
  exit
}

# Handler for signal USR1 for the timer
trap exit_timeout SIGUSR1

# starting timer in subshell. It sends a SIGUSR1 to the father if it timeouts.
export TIMEOUT=30
(sleep $TIMEOUT ; kill -SIGUSR1 $PID) &

# record PID of timer
TPID=$!


# wait for all production processes to finish
wait ${PRODPID[*]}

# Normal exit
echo "All processes ended normal"

# kill timer
kill $TPID
