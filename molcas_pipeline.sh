#!/bin/bash

#assumptions
# 1. upstream folder name will be used as the prefix of the input,prm,key filenames


#arguments:
# b = base directory - absolute full path of the folder
#     which contains the folder with the initial molcas run
# u = upstream folder - folder name of initial molcas run
# s = step number for downstream

while getopts b:u:s: option
do
        case "${option}"
        in
                b) BASE=${OPTARG};;
                u) UPSTREAM=${OPTARG};;
                s) STEP=${OPTARG};;
        esac
done

DOWNSTREAM=Trajectory_${STEP}fs

if [ ! -d "$BASE/$UPSTREAM" ]; then
  echo ERROR: Upstream folder path is incorrect
  exit 1
fi

if [ -d "$BASE/$UPSTREAM/$DOWNSTREAM" ]; then
  echo ERROR: Downstream folder path already exists
  exit 1
fi


mkdir $BASE/$UPSTREAM/$DOWNSTREAM

find $BASE/$UPSTREAM -name $UPSTREAM*.input -exec cp {} $BASE/$UPSTREAM/$DOWNSTREAM/$DOWNSTREAM.input \;
find $BASE/$UPSTREAM -name $UPSTREAM*.prm -exec cp {} $BASE/$UPSTREAM/$DOWNSTREAM/$DOWNSTREAM.prm \;
find $BASE/$UPSTREAM -name $UPSTREAM*.key -exec cp {} $BASE/$UPSTREAM/$DOWNSTREAM/$DOWNSTREAM.key \;

sed -i 's/'"$UPSTREAM"'.*.prm/'"$DOWNSTREAM"'.prm/g' $BASE/$UPSTREAM/$DOWNSTREAM/$DOWNSTREAM.key

#might want to consider changing the job name in each of the sbatch scripts, or make a sbatch array
cp $BASE/$UPSTREAM/molcas_sub $BASE/$UPSTREAM/$DOWNSTREAM/molcas_sub
sed -i 's/file_name/'"$DOWNSTREAM"'/g' $BASE/$UPSTREAM/$DOWNSTREAM/molcas_sub
