#!/bin/bash

#notes
#PROJECT naming convention is molecule_XXsolv_temp (on the folder)
#the files additionally have a timestep added molecule_XXsolv_temp

#assumptions
# 1. PROJECT folder name will be used as the prefix of the input,prm,key filenames


#arguments:
# b = base directory - absolute full path of the folder
#     which contains the folder with the initial molcas run
# p = PROJECT folder - folder name of initial molcas run
# s = step number for downstream

while getopts r:p:b:e:s:dt:hop: option
do
        case "${option}"
        in
                r) BASE=${OPTARG};;
                p) PROJECT=${OPTARG};;
                b) BEGINTIMESTEP=${OPTARG};;
                e) ENDTIMESTEP=${OPTARG};;
                s) STEPSIZE${OPTARG};;
                dt) DT=${OPTARG};;
                hop) HOP=${OPTARG};;
        esac
done

for ((STEP=$BEGINTIMESTEP; STEP<=$ENDTIMESTEP; STEP+=$STEPSIZE)); do

  DOWNSTREAM=Trajectory_${STEP}fs

  if [ ! -d "$BASE/$PROJECT" ]; then
    echo ERROR: PROJECT folder path is incorrect
    exit 1
  fi

  if [ -d "$BASE/$PROJECT/$DOWNSTREAM" ]; then
    echo ERROR: Downstream folder path already exists
    exit 1
  fi


  mkdir $BASE/$PROJECT/$DOWNSTREAM

  cp template.input $BASE/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.input

  sed -i 's/dtvalue/'"$DT"'/g' $BASE/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.input
  sed -i 's/hopvalue/'"$HOP"'/g' $BASE/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.input

  find $BASE/$PROJECT -name $PROJECT*.prm -exec cp {} $BASE/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.prm \;
  find $BASE/$PROJECT -name $PROJECT*.key -exec cp {} $BASE/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.key \;

  sed -i 's/'"$PROJECT"'.*.prm/'"$DOWNSTREAM"'.prm/g' $BASE/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.key

  #might want to consider changing the job name in each of the sbatch scripts, or make a sbatch array
  cp $BASE/$PROJECT/molcas_sub $BASE/$PROJECT/$DOWNSTREAM/molcas_sub
  sed -i 's/file_name/'"$DOWNSTREAM"'/g' $BASE/$PROJECT/$DOWNSTREAM/molcas_sub

  find $BASE/$PROJECT/TMP -name $PROJECT*.$STEP -exec cp {} $BASE/$PROJECT/$DOWNSTREAM/$DOWNSTREAM.xyz \;

done
