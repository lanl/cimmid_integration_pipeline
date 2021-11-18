#!/bin/sh

###################################################################################################
Currently, CIMMID code lives on gitlab.lanl.gov (yellow network) which is not accessible from turquoise network (e.g., Badger) where ELM is setup to run. So need to create bare DropZone repos on turquoise cluster. This script needs to be run once before running any experiemnts on turquoise network.

# Usage: sh setup_turuoise_1.sh BARE_DROPZONE_REPO_PATH
# BARE_DROPZONE_REPO_PATH: Path where bare DropZone repo is setup (e.g., /turquoise/users/nidhip/projects/cimmid)

# TO DO: Update above path to a path in project directory instead of in my home directory
###################################################################################################

# Check for correct number of arguments.
if [ "$#" -lt 1 ] || ! [ -d "$1" ] ; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    echo "Usage: sh setup_turuoise_1.sh BARE_DROPZONE_REPO_PATH"
    echo -e "ARE_DROPZONE_REPO_PATH: Path where bare DropZone repo is setup (e.g., /turquoise/users/nidhip/projects/cimmid)\n"
    exit
fi

BARE_DROPZONE_REPO_PATH=$1"

# Create bare DropZone repo for integration model
echo "$(date): creating bare DropZone repo for integration.."
INTEGRATION_BARE_DROPZONE_REPO_PATH="$BARE_DROPZONE_REPO_PATH/toy_model"
mkdir $INTEGRATION_BARE_DROPZONE_REPO_PATH
cd $INTEGRATION_BARE_DROPZONE_REPO_PATH
git --bare init

# Create bare DropZone repo for hydropop
echo "$(date): creating bare DropZone repo for hydropop.."
HYDROPOP_BARE_DROPZONE_REPO_PATH="$BARE_DROPZONE_REPO_PATH/hydropop"
mkdir $HYDROPOP_BARE_DROPZONE_REPO_PATH
cd $HYDROPOP_BARE_DROPZONE_REPO_PATH
git --bare init

# Create bare DropZone repo for mosquito pop model
echo "$(date): creating bare DropZone repo for mosquito pop model.."
MOSQUITO_POP_BARE_DROPZONE_REPO_PATH="$BARE_DROPZONE_REPO_PATH/mosquito-toy-model"
mkdir $MOSQUITO_POP_BARE_DROPZONE_REPO_PATH
cd $MOSQUITO_POP_BARE_DROPZONE_REPO_PATH
git --bare init

# Create bare DropZone repo for epi model
echo "$(date): creating bare DropZone repo for epi model.."
EPI_BARE_DROPZONE_REPO_PATH="$BARE_DROPZONE_REPO_PATH/human_epi_models"
mkdir $EPI_BARE_DROPZONE_REPO_PATH
cd $EPI_BARE_DROPZONE_REPO_PATH
git --bare init

echo "$(date): done."
