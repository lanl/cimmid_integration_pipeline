#!/bin/sh

###################################################################################################################################################################################
# Currently, CIMMID code lives on gitlab.lanl.gov (yellow network) which is not accessible from turquoise network (e.g., Badger) where ELM is setup to run. So need to create working repos on a yellow network machine (e.g., your laptop or Darwin) from where code can be pulled on turquoise network. This script needs to be run once before running any experiemnts on yellow network.

# Usage: sh setup_yellow.sh TURQUOISE_CLUSTER_LOGIN_NODE PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER
# TURQUOISE_CLUSTER_LOGIN_NODE: Login node on turquoise network (e.g., ba-fe.lanl.gov)
# PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER: Path where bare DropZone repositories are created on turquoise network (e.g., /turquoise/users/nidhip/projects/cimmid/integration/bare_dropzone_repos)

# TO DO: Need to  update above path in my home directory to one under CIMMID project directory once it is created.
##################################################################################################################################################################################

PROJECT_ROOT=`pwd`
GITLAB_WORKING_REPO_NAME='gitlab_working_repo'

# Check for correct number of arguments.
if [ "$#" -lt 2 ]; then
    echo -e "ERROR!! Incorrect number or type of arguments. See usage information below:\n"
    echo "Usage: sh setup_yellow.sh TURQUOISE_CLUSTER_LOGIN_NODE PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER\n"
    echo "TURQUOISE_CLUSTER_LOGIN_NODE: Login node on turquoise network (e.g., ba-fe.lanl.gov)\n"
    echo -e "PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER: Path where bare DropZone repositories are created on turquoise network (e.g., /turquoise/users/nidhip/projects/cimmid/integration/bare_dropzone_repos)\n"
    exit
fi

TURQUOISE_CLUSTER_LOGIN_NODE=$1
PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER=$2

mkdir $GITLAB_WORKING_REPO_NAME
cd $GITLAB_WORKING_REPO_NAME

# Git clone integration model
echo "$(date): cloning integration model.."
git clone git@gitlab.lanl.gov:cimmid/integration/toy_model.git
cd toy_model
# Add mirror
git remote add --mirror Turq-dev "$TURQUOISE_CLUSTER_LOGIN_NODE:$PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER/toy_model"
export GIT_SSH="$PROJECT_ROOT/turq-ssh-hop.sh"
git push Turq-dev
cd "$PROJECT_ROOT/$GITLAB_WORKING_REPO_NAME"
echo "$(date): done setting up working repo for integration.."
echo ""

# Git clone hydropop model
echo "$(date): cloning hydropop model.."
git clone git@gitlab.lanl.gov:cimmid/hydropop.git
cd hydropop
# Add mirror
git remote add --mirror Turq-dev "$TURQUOISE_CLUSTER_LOGIN_NODE:$PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER/hydropop" 
git push Turq-dev
cd "$PROJECT_ROOT/$GITLAB_WORKING_REPO_NAME"
echo "$(date): done setting up working repo for hydropop.."
echo ""

# Git clone mosquito pop model
echo "$(date): cloning mosquito pop model.."
git clone git@gitlab.lanl.gov:cimmid/earth_system_modeling/mosquito-toy-model.git
cd mosquito-toy-model
# Add mirror
git remote add --mirror Turq-dev "$TURQUOISE_CLUSTER_LOGIN_NODE:$PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER/mosquito-toy-model"
git push Turq-dev
cd "$PROJECT_ROOT/$GITLAB_WORKING_REPO_NAME"
echo "$(date): done setting up working repo for mosquito pop.."
echo ""

# Git clone epi model
echo "$(date): cloning epi model.."
git clone git@gitlab.lanl.gov:cimmid/disease_and_human_modeling/human_epi_models.git
cd human_epi_models
# Add mirror
git remote add --mirror Turq-dev "$TURQUOISE_CLUSTER_LOGIN_NODE:$PATH_TO_BARE_DROPZONE_REPO_ON_TURQUOISE_CLUSTER/human_epi_models"
git push Turq-dev
cd "$PROJECT_ROOT/$GITLAB_WORKING_REPO_NAME"
echo "$(date): done setting up working repo for epi model .."
echo ""
