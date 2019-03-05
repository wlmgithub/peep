#!/usr/loca/bin/bash
#
#  brew install bash  
#    to get the newer version of bash on OSX

# list array elements 
pkgs=(
    "a1"
    "a2"
    #"a3"
    "a4"
    "a5"
    )

for i in ${pkgs[@]}; do
    echo $i
done


#  https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays

# List of logs and who should be notified of issues
logPaths=("api.log" "auth.log" "jenkins.log" "data.log")
logEmails=("jay@email" "emma@email" "jon@email" "sophia@email")


echo "logPaths: ${logPaths[@]}"
echo "logEmails: ${logEmails[@]}"

# Look for signs of trouble in each log
for i in ${!logPaths[@]};
do
  log=${logPaths[$i]}
  stakeholder=${logEmails[$i]}
#  numErrors=$( tail -n 100 "$log" | grep "ERROR" | wc -l )

  # Warn stakeholders if recently saw > 5 errors
#  if [[ "$numErrors" -gt 5 ]];
#  then
#    emailRecipient="$stakeholder"
#    emailSubject="WARNING: ${log} showing unusual levels of errors"
#    emailBody="${numErrors} errors found in log ${log}"
#    echo "$emailBody" | mailx -s "$emailSubject" "$emailRecipient"
#  fi

    echo "log: $log"
    echo "stakeholder: $stakeholder"
    echo

done

# list elements separately
echo ==========

for i in ${logPaths[@]}; do 
    echo "* logPath: $i"
done

for j in ${logEmails[@]}; do
    echo "* logEmail: $j"
done


# list key-value pairs
echo "****************"

declare -A arr
arr[key1]=val1

arr+=([key2]=val2 [key3]=val3)

for i in ${!arr[@]}; do 
    echo "$i ${arr[$i]}"
done
