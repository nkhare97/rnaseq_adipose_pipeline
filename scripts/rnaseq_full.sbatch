#!/bin/bash
#SBATCH -J rnaseq_full
#SBATCH -A gtw111
#SBATCH -p shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=128G
#SBATCH -t 24:00:00
#SBATCH --constraint=lustre
#SBATCH -o /expanse/lustre/projects/gtw111/%u/adipose/logs/rnaseq_full.%j.out
#SBATCH -e /expanse/lustre/projects/gtw111/%u/adipose/logs/rnaseq_full.%j.err
#SBATCH --export=ALL

set -euo pipefail

PIPELINE_VERSION=3.26.0
REPO=$HOME/rnaseq_adipose_pipeline
USER_ROOT=/expanse/lustre/projects/gtw111/$USER
RUN_DIR=$USER_ROOT/adipose/rnaseq_full

module purge
module load cpu
module load singularitypro/4.1.2
module load anaconda3/2021.05/q4munrg
export PS1="${PS1:-}"
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$USER_ROOT/envs/nextflow_env"

export PATH="$HOME/bin:$PATH"
export NXF_HOME="$HOME/.nextflow"
export NXF_WORK="$USER_ROOT/nf_work"
export NXF_SINGULARITY_CACHEDIR="$USER_ROOT/nf_singularity_cache"
export NXF_DISABLE_CHECK_LATEST=true

mkdir -p "$RUN_DIR"
cd "$RUN_DIR"

nextflow run nf-core/rnaseq -r "$PIPELINE_VERSION" \
    -profile singularity \
    -c "$REPO/config/expanse_full.config" \
    -params-file "$REPO/config/params.yaml" \
    -work-dir "$NXF_WORK/rnaseq_full" \
    -resume
