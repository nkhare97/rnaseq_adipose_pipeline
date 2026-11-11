#!/bin/bash
#SBATCH -p shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH -t 02:00:00
#SBATCH -J nf_sing_test
#SBATCH -A gtw111
#SBATCH --constraint=lustre
#SBATCH -o nf_sing_test.%j.out
#SBATCH -e nf_sing_test.%j.err
#SBATCH --export=ALL
set -euo pipefail
module purge
module load cpu
module load singularitypro/4.1.2
module load anaconda3/2021.05/q4munrg
export PS1="${PS1:-}"
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate /expanse/lustre/projects/gtw111/$USER/envs/nextflow_env
export PATH="$HOME/bin:$PATH"
export NXF_HOME="$HOME/.nextflow"
export NXF_WORK=/expanse/lustre/projects/gtw111/$USER/nf_work
export NXF_SINGULARITY_CACHEDIR=/expanse/lustre/projects/gtw111/$USER/nf_singularity_cache
mkdir -p "$NXF_WORK" "$NXF_SINGULARITY_CACHEDIR"
nextflow run test_singularity_nextflow.nf -c nextflow_test.config -work-dir "$NXF_WORK/test_singularity"
