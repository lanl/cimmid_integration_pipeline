#!/bin/sh

###################################################################################################################################################################################
# Currently, CIMMID code lives on gitlab.lanl.gov (yellow network) which is not accessible from turquoise network (e.g., Badger) where ELM is setup to run. So need to create working repos on a yellow network machine (e.g., your laptop or Darwin) from where code can be pulled on turquoise network. This script needs to be run once before running any experiemnts on yellow network.

# Usage: sh setup_yellow.sh PATH_TO_MINICONDA_INSTALLATION CONFIG_FILE
# PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3')
# CONFIG_FILE: Config file (e.g., cimmid.yaml)
##################################################################################################################################################################################

# load/unload modules
module load gcc

# Check for correct number of arguments.
if [ "$#" -lt 2 ] || ! [ -d "$1" ] || ! [ -f "$2" ]; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    echo "Usage: sh setup_yellow.sh PATH_TO_MINICONDA_INSTALLATION CONFIG_FILE"
    echo "PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/projects/cimmid/miniconda3')"
    echo -e "CONFIG_FILE: Config file (e.g., cimmid.yaml)\n"
    exit
fi

# ADD CIMMID miniconda path to PATH.
MINICONDA_PATH=$1
export PATH="$MINICONDA_PATH/bin:$PATH"
conda config --prepend envs_dirs "$MINICONDA_PATH/envs"
# Create virtual environment for integration
conda create --name integration python=3.8
#conda activate integration
source activate integration
conda install -c conda-forge shyaml

# Get config file
CONFIG_FILE=$2
PROJECT_ROOT=`cat $CONFIG_FILE | shyaml get-value YELLOW_NET.PROJECT_ROOT`
CONFIG_FILE="$PROJECT_ROOT/$2"

# Get turquoise cluster login node and paths info
TURQUOISE_CLUSTER_LOGIN_NODE=`cat $CONFIG_FILE | shyaml get-value TURQUOISE_NET.LOGIN_NODE`
PROJECT_ROOT_ON_TURQUOISE_CLUSTER=`cat $CONFIG_FILE | shyaml get-value TURQUOISE_NET.PROJECT_ROOT`
PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER=`cat $CONFIG_FILE | shyaml get-value TURQUOISE_NET.BARE_DROPZONE_REPO_PATH`
PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER="$PROJECT_ROOT_ON_TURQUOISE_CLUSTER/$PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER"

# Get path for gitlab working repo on yellow network
GITLAB_WORKING_REPO_PATH=`cat $CONFIG_FILE | shyaml get-value YELLOW_NET.GITLAB_WORKING_REPO_PATH`
GITLAB_WORKING_REPO_PATH="$PROJECT_ROOT/$GITLAB_WORKING_REPO_PATH"

# Make gitlab working repo
mkdir $GITLAB_WORKING_REPO_PATH
cd $GITLAB_WORKING_REPO_PATH

# Git clone integration model
echo "$(date): cloning integration model.."
INTEGRATION_REPO=`cat $CONFIG_FILE | shyaml get-value INTEGRATION_MODEL.REPO`
git clone $INTEGRATION_REPO
INTEGRATION_DIR=`echo $INTEGRATION_REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
cd $INTEGRATION_DIR
git config pull.rebase false
# Add mirror
git remote add --mirror Turq-dev "$TURQUOISE_CLUSTER_LOGIN_NODE:$PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER/$INTEGRATION_DIR"
export GIT_SSH="$PROJECT_ROOT/turq-ssh-hop.sh"
git push Turq-dev
cd $GITLAB_WORKING_REPO_PATH
echo "$(date): done setting up working repo for integration.."
echo ""

# Git clone hydropop model
echo "$(date): cloning hydropop model.."
HYDROPOP_REPO=`cat $CONFIG_FILE | shyaml get-value HYDROPOP_MODEL.REPO`
git clone $HYDROPOP_REPO
HYDROPO_DIR=`echo $HYDROPOP_REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
cd $HYDROPO_DIR
git config pull.rebase false
# Add mirror
git remote add --mirror Turq-dev "$TURQUOISE_CLUSTER_LOGIN_NODE:$PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER/$HYDROPO_DIR" 
git push Turq-dev
cd $GITLAB_WORKING_REPO_PATH
echo "$(date): done setting up working repo for hydropop.."
echo ""

# Git clone mosquito pop model
echo "$(date): cloning mosquito pop model.."
MOSQUITO_POP_REPO=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_MODEL.REPO`
git clone $MOSQUITO_POP_REPO
MOSQUITO_POP_DIR=`echo $MOSQUITO_POP_REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
cd $MOSQUITO_POP_DIR
git config pull.rebase false
# Add mirror
git remote add --mirror Turq-dev "$TURQUOISE_CLUSTER_LOGIN_NODE:$PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER/$MOSQUITO_POP_DIR"
git push Turq-dev
cd $GITLAB_WORKING_REPO_PATH
echo "$(date): done setting up working repo for mosquito pop.."
echo ""

# Git clone epi model
echo "$(date): cloning epi model.."
EPI_MODEL_REPO=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.REPO`
git clone $EPI_MODEL_REPO
EPI_DIR=`echo $EPI_MODEL_REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
cd $EPI_DIR
git config pull.rebase false
# Add mirror
git remote add --mirror Turq-dev "$TURQUOISE_CLUSTER_LOGIN_NODE:$PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER/$EPI_DIR"
git push Turq-dev
cd $GITLAB_WORKING_REPO_PATH
echo "$(date): done setting up working repo for epi model .."
echo ""

conda deactivate
