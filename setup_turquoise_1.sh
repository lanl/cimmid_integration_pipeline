#!/bin/sh

###################################################################################################
# Currently, CIMMID code lives on gitlab.lanl.gov (yellow network) which is not accessible from turquoise network (e.g., Badger) where ELM is setup to run. So need to create bare DropZone repos on turquoise cluster. This script needs to be run once before running any experiemnts on turquoise network.

# Usage: sh setup_turuoise_1.sh PATH_TO_MINICONDA_INSTALLATION CONFIG_FILE
# PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/turquoise/users/nidhip/miniconda3')
# CONFIG_FILE: Config file (e.g., cimmid.yaml)

# TO DO: Update above path to a path in project directory instead of in my home directory
###################################################################################################

# Check for correct number of arguments.
if [ "$#" -lt 2 ] || ! [ -d "$1" ] || ! [ -f "$2" ]; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    echo "Usage: sh setup_turuoise_1.sh PATH_TO_MINICONDA_INSTALLATION CONFIG_FILE"
    echo "PATH_TO_MINICONDA_INSTALLATION: Path where miniconda3 is installed (e.g., '/turquoise/users/nidhip/miniconda3')"
    echo -e "CONFIG_FILE: Config file (e..g, cimmid.yaml)\n"
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
PROJECT_ROOT=`cat $CONFIG_FILE | shyaml get-value TURQUOISE_NET.PROJECT_ROOT`
CONFIG_FILE="$PROJECT_ROOT/$2"

# Create bare DropZone repo directory
BARE_DROPZONE_REPO_PATH=`cat $CONFIG_FILE | shyaml get-value TURQUOISE_NET.BARE_DROPZONE_REPO_PATH`
# If directory $BARE_DROPZONE_REPO_PATH does not exist, create it
if [ ! -d "$BARE_DROPZONE_REPO_PATH" ]; then
    mkdir $BARE_DROPZONE_REPO_PATH
fi
# Store path for bare DropZone repo directory
cd $BARE_DROPZONE_REPO_PATH
BARE_DROPZONE_REPO_PATH=`pwd`

# Create bare DropZone repo for integration model
INTEGRATION_DIR=`cat $CONFIG_FILE | shyaml get-value INTEGRATION_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
echo "$(date): creating bare DropZone repo for integration.."
INTEGRATION_BARE_DROPZONE_REPO_PATH="$BARE_DROPZONE_REPO_PATH/$INTEGRATION_DIR"
mkdir $INTEGRATION_BARE_DROPZONE_REPO_PATH
cd $INTEGRATION_BARE_DROPZONE_REPO_PATH
git --bare init

# Create bare DropZone repo for hydropop
HYDROPO_DIR=`cat $CONFIG_FILE | shyaml get-value HYDROPOP_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
echo "$(date): creating bare DropZone repo for hydropop.."
HYDROPOP_BARE_DROPZONE_REPO_PATH="$BARE_DROPZONE_REPO_PATH/$HYDROPO_DIR"
mkdir $HYDROPOP_BARE_DROPZONE_REPO_PATH
cd $HYDROPOP_BARE_DROPZONE_REPO_PATH
git --bare init

# Create bare DropZone repo for mosquito pop model
MOSQUITO_POP_DIR=`cat $CONFIG_FILE | shyaml get-value MOSQUITO_POP_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
echo "$(date): creating bare DropZone repo for mosquito pop model.."
MOSQUITO_POP_BARE_DROPZONE_REPO_PATH="$BARE_DROPZONE_REPO_PATH/$MOSQUITO_POP_DIR"
mkdir $MOSQUITO_POP_BARE_DROPZONE_REPO_PATH
cd $MOSQUITO_POP_BARE_DROPZONE_REPO_PATH
git --bare init

# Create bare DropZone repo for epi model
EPI_DIR=`cat $CONFIG_FILE | shyaml get-value EPI_MODEL.REPO | rev | cut -d"/" -f1 | rev | cut -d"." -f1`
echo "$(date): creating bare DropZone repo for epi model.."
EPI_BARE_DROPZONE_REPO_PATH="$BARE_DROPZONE_REPO_PATH/$EPI_DIR"
mkdir $EPI_BARE_DROPZONE_REPO_PATH
cd $EPI_BARE_DROPZONE_REPO_PATH
git --bare init

conda deactivate
echo "$(date): done."
