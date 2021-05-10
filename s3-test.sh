#!/bin/bash
#
[ $# -ne 6 ] && exit 1

while getopts ":b:k:s:" OPT; do
  case $OPT in
      b)
        BUCKET=$OPTARG
        ;;
      k)
        KEY=$OPTARG
        ;;
      s)
        SPLIT=$OPTARG
        ;;
      *)
        echo "Invalid option: -$OPTARG" >&2
        exit 2
        ;;
  esac
done

readonly THRESHOLD_PART_SIZE=10485760  # 10MB
readonly TMP_DIR="./tmp.$$";

OBJECT_SIZE=$(aws s3api list-objects --bucket $BUCKET --query "Contents[?Key==\`${KEY}\`]|[0].Size")

let PART_SIZE=OBJECT_SIZE/SPLIT

[ $PART_SIZE -lt $THRESHOLD_PART_SIZE ] && echo "Part size is $PART_SIZE. Each part size except last one must be larger than $((${THRESHOLD_PART_SIZE}/1024/1024))MB" &&  exit 3
[ ! -d "${TMP_DIR}" ] && mkdir ${TMP_DIR}

I=1
START=0

let END=PART_SIZE-1

while [ $I -le $SPLIT ]
do
    aws s3api get-object --bucket $BUCKET --key $BUCKET_OBJ/$KEY --range bytes=${START}-${END} ${TMP_DIR}/${KEY}.${I} > /dev/null 2>&1 &
    let I=I+1
    let START=START+PART_SIZE
    let END=END+PART_SIZE; [ $I -eq $SPLIT ] && END=''
done

wait > /dev/null 2>&1

[ -f $KEY ] && rm $KEY
I=1
while [ $I -le $SPLIT ]
do
    cat ${TMP_DIR}/${KEY}.${I} >> $KEY
    let I=I+1
done

rm -rf $TMP_DIR
