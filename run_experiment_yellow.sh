#!/bin/sh

###################################################################################################################################################################################
# Currently, CIMMID code lives on gitlab.lanl.gov (yellow network) which is not accessible from turquoise network (e.g., Badger) where ELM is setup to run. So we have created working repos on a yellow network machine (e.g., your laptop or Darwin) from where code can be pulled on turquoise network. This script pulls the latest code from gitlablanl.gov to working repos ans pushes the changes to bare DropZone repos on turquoise network (e..g, badger).

# Usage: sh run_experiment_yellow.sh PATH_TO_MINICONDA_INSTALLATION CONFIG_FILE
# PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3')
# CONFIG_FILE: Config file (e.g., cimmid.yaml)
##################################################################################################################################################################################

# load/unload modules
module unload gcc
module load gcc/7.2.0

# Check for correct number of arguments.
if [ "$#" -lt 2 ] || ! [ -d "$1" ] || ! [ -f "$2" ]; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    echo "Usage: sh run_experiment_yellow.sh PATH_TO_MINICONDA_INSTALLATION CONFIG_FILE"
    echo "PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3')"
    echo -e "CONFIG_FILE: Config file (e.g., cimmid.yaml)\n"
    exit
fi

# ADD CIMMID miniconda path to PATH.
MINICONDA_PATH=$1
export PATH="$MINICONDA_PATH/bin:$PATH"
conda activate integration

# Get config file
CONFIG_FILE=$2
PROJECT_ROOT=`cat $CONFIG_FILE | shyaml get-value YELLOW_NET.PROJECT_ROOT`
CONFIG_FILE="$PROJECT_ROOT/$2"

# Get path for gitlab working repo on yellow network
GITLAB_WORKING_REPO_PATH=`cat $CONFIG_FILE | shyaml get-value YELLOW_NET.GITLAB_WORKING_REPO_PATH`
GITLAB_WORKING_REPO_PATH="$PROJECT_ROOT/$GITLAB_WORKING_REPO_PATH"
cd $GITLAB_WORKING_REPO_PATH

# Pull latest code for integration model and push it to turquoise cluster (e.g., badger)
INTEGRATION_REPO=`cat $CONFIG_FILE | shyaml get-value INTEGRATION_REPO`
INTEGRATION_DIR=`echo $INTEGRATION_REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
cd $INTEGRATION_DIR
INTEGRATION_BRANCH=`cat $CONFIG_FILE | shyaml get-value INTEGRATION_BRANCH`
git pull $INTEGRATION_REPO $INTEGRATION_BRANCH
git push Turq-dev
cd $GITLAB_WORKING_REPO_PATH

# Pull latest code for hydropop model and push it to turquoise cluster (e.g., badger)
HYDROPOP_REPO=`cat $CONFIG_FILE | shyaml get-value HYDROPOP_REPO`
HYDROPO_DIR=`echo $HYDROPOP_REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
cd $HYDROPO_DIR
HYDROPO_BRANCH=`cat $CONFIG_FILE | shyaml get-value HYDROPOP_BRANCH`
git pull $HYDROPOP_REPO $HYDROPO_BRANCH
git push Turq-dev
cd $GITLAB_WORKING_REPO_PATH

# Pull latest code for mosquito pop model and push it to turquoise cluster (e.g., badger)
MOSQUITO_POP_REPO=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_REPO`
MOSQUITO_POP_DIR=`echo $MOSQUITO_POP_REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
cd $MOSQUITO_POP_DIR
MOSQUITO_POP_BRANCH=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_BRANCH`
git pull $MOSQUITO_POP_REPO $MOSQUITO_POP_BRANCH
git push Turq-dev
cd $GITLAB_WORKING_REPO_PATH

# Pull latest code for epi model and push it to turquoise cluster (e.g., badger)
EPI_MODEL_REPO=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL_REPO`
EPI_DIR=`echo $EPI_MODEL_REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
cd $EPI_DIR
EPI_MODEL_BRANCH=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL_BRANCH`
git pull $EPI_MODEL_REPO $EPI_MODEL_BRANCH
git push Turq-dev
cd $GITLAB_WORKING_REPO_PATH

conda deactivate
