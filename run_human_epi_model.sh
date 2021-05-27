#!/bin/sh

# Runs human epi model
# Takes 5 arguments
# 1. Path where human epi model is cloned from git
# 2. Path where config files are stored for the current experiment run
# 3. Name of the human epi model config file
# 4. Path where human epi output will be stored for the current experiment run
# 5. Path where human epi log will be stored for the current experiment run

HUMAN_EPI_MODEL_PATH=$1
CONFIG_PATH=$2
HUMAN_EPI_CONFIG_FILENAME=$3
HUMAN_EPI_MODEL_OUTPUT_PATH=$4
HUMAN_EPI_LOGS_PATH=$5

# Change to directory where human epi model is cloned
pushd $HUMAN_EPI_MODEL_PATH > /dev/null

# Checkout the given branch and get latest commit id
git checkout master --quiet > /dev/null
git pull > /dev/null
echo "$(date): Pulled branch master.."
latest_human_epi_model_commit_id=`git log --format="%H" -n 1`
echo "$(date): Latest commit id is $latest_human_epi_model_commit_id.."

# Set configuration file
cp $HUMAN_EPI_MODEL_PATH/config/$HUMAN_EPI_CONFIG_FILENAME $CONFIG_PATH
sed -i.bak "s|HUMAN_EPI_MODEL_PATH|$HUMAN_EPI_MODEL_PATH|g" $CONFIG_PATH/$HUMAN_EPI_CONFIG_FILENAME
sed -i.bak "s|HUMAN_EPI_LOGS_PATH|$HUMAN_EPI_LOGS_PATH|g" $CONFIG_PATH/$HUMAN_EPI_CONFIG_FILENAME
sed -i.bak "s|HUMAN_EPI_MODEL_OUTPUT_PATH|$HUMAN_EPI_MODEL_OUTPUT_PATH|g" $CONFIG_PATH/$HUMAN_EPI_CONFIG_FILENAME

# Run model
#conda activate /projects/cimmid/miniconda3/envs/human-epi-env
source activate /projects/cimmid/miniconda3/envs/human-epi-env
logfiles=`shopt -s nullglob dotglob; echo $HUMAN_EPI_LOGS_PATH/*`
if [ "$logfiles" != "" ]; then
    rm $HUMAN_EPI_LOGS_PATH/*
fi
sh run_human_epi_model.sh $CONFIG_PATH/$HUMAN_EPI_CONFIG_FILENAME 0 > $HUMAN_EPI_LOGS_PATH/human_epi.out
conda deactivate

# Change back to integration directory
popd $HUMAN_EPI_MODEL_PATH > /dev/null
