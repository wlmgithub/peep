#!/bain/bash
#
# http://stackoverflow.com/questions/5474732/how-can-i-add-a-help-method-to-a-shell-script
#
usage="$(basename $0) [-h] [-s n] -- program to calculate the answer to life, the universe and everything

where:
    -h  show this help text
    -s  set the seed value (default: 42)"

seed=42
while getopts ':hs:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    s) seed=$OPTARG
       ;;
    ?) printf "illegal option: '%s'\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

echo $seed
