#!/bin/sh

###################################################################################################
Currently, CIMMID code lives on gitlab.lanl.gov (yellow network) which is not accessible from turquoise network (e.g., Badger) where ELM is setup to run. So need to create bare DropZone repos on turquoise cluster. This script needs to be run once before running any experiemnts on turquoise network.

# Usage: sh setup_turuoise_1.sh
###################################################################################################

PROJECT_ROOT=`pwd`
BARE_DROPZONE_REPO_PATH="$PROJECT_ROOT/bare_dropzone_repos"

# Create bare DropZone repo for hydropop
echo "$(date): creating bare DropZone repo for hydropop.."
HYDROPOP_BARE_DROPZONE_REPO_PATH="$BARE_DROPZONE_REPO_PATH/hydropop"
mkdir $HYDROPOP_BARE_DROPZONE_REPO_PATH
cd $HYDROPOP_BARE_DROPZONE_REPO_PATH
git --bare init
cd ..

# Create bare DropZone repo for mosquito pop model
echo "$(date): creating bare DropZone repo for mosquito pop model.."
MOSQUITO_POP_BARE_DROPZONE_REPO_PATH="$BARE_DROPZONE_REPO_PATH/mosquito-toy-model"
mkdir $MOSQUITO_POP_BARE_DROPZONE_REPO_PATH
cd $MOSQUITO_POP_BARE_DROPZONE_REPO_PATH
git --bare init
cd ..

# Create bare DropZone repo for epi model
echo "$(date): creating bare DropZone repo for epi model.."
EPI_BARE_DROPZONE_REPO_PATH="$BARE_DROPZONE_REPO_PATH/human_epi_models"
mkdir $EPI_BARE_DROPZONE_REPO_PATH
cd $EPI_BARE_DROPZONE_REPO_PATH
git --bare init
cd ..

echo "$(date): done."
