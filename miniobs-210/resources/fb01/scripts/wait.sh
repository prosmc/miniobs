#!/bin/sh

CODE=200
DEBUG=0

echoerr() {
  if [ "$DEBUG" -ne 1 ]; then printf "%s\n" "$*" 1>&2; fi
}

usage() {
  exitcode="$1"
  cat << USAGE >&2
Usage:
  $cmdname url [-t timeout] [-- command args]
  -d | --debug                        Debug mode
  -c CODE | --http_code               Expected http code (200 by default)
  -- COMMAND ARGS                     Execute command with args after the test finishes
USAGE
  exit "$exitcode"
}

wait_for() {
  ret=0
  while [ "$ret" != "$CODE" ]; do
    ret=$(curl -s -o /dev/null -w '%{http_code}' $URL)
    if [ "$DEBUG" -ne 0 ]; then echo "Waiting for $URL to return $CODE... Got $ret"; fi
    sleep 1
  done
  exit 0
}

while [ $# -gt 0 ]
do
  case "$1" in
    http*://* )
    URL=$1
    shift 1
    ;;
    -d | --debug)
    DEBUG=1
    shift 1
    ;;
    -c)
    CODE="$2"
    if [ "$CODE" = "" ]; then break; fi
    shift 2
    ;;
    --http_code=*)
    CODE="${1#*=}"
    shift 1
    ;;
    --)
    shift
    break
    ;;
    --help)
    usage 0
    ;;
    *)
    echoerr "Unknown argument: $1"
    usage 1
    ;;
  esac
done

if [ "$URL" = "" ]; then
  echoerr "Error: you need to provide a url to test."
  usage 2
fi

wait_for "$@"