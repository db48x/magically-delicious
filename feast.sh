#!/bin/bash
# feast.sh: distributed delicious mirroring script

SERVER=
cannibal=./cannibal.sh

while getopts :u: OPT; do
  case $OPT in
    u)
      USERNAME="$OPTARG"
      ;;
    *)
      echo "usage: `basename $0` [-u USERNAME]"
      exit 1;
  esac
done

warning() {
  echo "$0: $*" >&2
}

error() {
  echo "$0: $*" >&2
  exit 2
}

if [ -z $USERNAME ]; then
  error "You must supply a username with the -u option before you can begin"
fi

if [ ! -f $cannibal ]; then
  error "Couldn't find cannibal.sh; are you sure you cloned everything from the git repository?"
fi

EXTERN_IP=`curl --silent ipv4.icanhazip.com` #Do not change without good reason, or underscor will eat your brains

tellserver() {
  cmd="$1"
  shift
  rest=
  for chunk in "$@"; do
    rest="$rest/$chunk"
  done
  #if ! curl --silent --fail "http://$SERVER/$cmd/${USERNAME}$rest"; then
  #  error "Couldn't contact the listerine server. The listerine server could be down, or your network."
  #fi
}

askserver() {
  var="$1"
  cmd="$2"
  shift 2
  rest=
  for chunk in "$@"; do
    rest="$rest/$chunk"
  done
  #export $var=`curl --silent --fail "http://$SERVER/$cmd/${USERNAME}$rest"`
  #if [ $? != 0 ]; then
  #  error "Couldn't contact the listerine server. The listerine server could be down, or your network."
  #fi
}

tellserver introduce $EXTERN_IP

while true; do
  echo "Getting a userid from $SERVER, authenticated as $USERNAME with IP $EXTERN_IP"
  askserver userid getID
  if [ $? != 0 ]; then
    error "The server didn't give us an id. This could mean the server is broken, or possibly that we're finished."
  fi
  userid=robbiet480
  #if [ $(echo $userid | grep "^[-0-9]*$") != $userid ]; then
  #  error "The server did not return a valid id. It said: $userid"
  #fi

  modified=${userid/\./+}
  path=data/users/${modified:0:1}/${modified:1:1}/${modified:2:1}
  mkdir -p $path
  echo ID is $userid saving to $path
  file=$path/$modified.xml
  $cannibal "$userid" | tee $file | grep "<id>" | sed -e 's/.*<id>\(.*\)<\/id>/\1/' | while read mark; do
  #grep "<id>" test.xml | sed -e 's/.*<id>\(.*\)<\/id>/\1/' | while read mark; do
    tagpath=data/tags/${mark:0:2}/${mark:2:2}/${mark:4:2}
    mkdir -p $tagpath
    ./tagsaretasty.sh $mark > $tagpath/$mark.xml
  done;

  #if [ -f $file ]; then
  #  tellserver finishVid $userid $size $hash
  #else
  #  warning "Failed to download anything for $userid."
  #fi
  if [ -f STOP ]; then
    echo "$0: I see a file called STOP. Stopping."
    exit 0
  fi
done
