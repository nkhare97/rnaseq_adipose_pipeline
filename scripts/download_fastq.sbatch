#!/bin/bash
#SBATCH -J fastq_dl
#SBATCH -A gtw111
#SBATCH -p shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH -t 06:00:00
#SBATCH --constraint=lustre
#SBATCH -o /expanse/lustre/projects/gtw111/%u/adipose/logs/fastq_dl.%j.out
#SBATCH -e /expanse/lustre/projects/gtw111/%u/adipose/logs/fastq_dl.%j.err
#SBATCH --export=ALL

# Download SRA runs and convert them to gzipped FASTQ.
# Usage: sbatch scripts/download_fastq.sbatch config/ids.csv
set -eo pipefail

REPO=$HOME/rnaseq_adipose_pipeline
IDS=$REPO/${1:-config/ids.csv}
RUNTABLE=$REPO/config/all_runs.tsv
USER_ROOT=/expanse/lustre/projects/gtw111/$USER
SRA_DIR=$USER_ROOT/adipose/sra
FASTQ_DIR=$USER_ROOT/adipose/fastq
TMP_DIR=$USER_ROOT/sra_tmp
THREADS=${SLURM_CPUS_PER_TASK:-8}

module purge
module load cpu
module load sratoolkit/2.10.9/rn4humf
mkdir -p "$SRA_DIR" "$FASTQ_DIR" "$TMP_DIR"

echo "Node: $(hostname)  Start: $(date)"
echo "Run list: $IDS"

while read -r ID; do
    [ -z "$ID" ] && continue
    OUT="$FASTQ_DIR/${ID}.fastq.gz"

    # Skip runs that are already finished
    if [ -s "$OUT" ]; then
        echo "[$ID] already done, skipping"
        continue
    fi

    echo "[$ID] prefetch: $(date)"
    prefetch "$ID" --output-directory "$SRA_DIR" --max-size 50G

    echo "[$ID] fasterq-dump: $(date)"
    fasterq-dump "$SRA_DIR/$ID/$ID.sra" \
        --outdir "$FASTQ_DIR" --temp "$TMP_DIR" --threads "$THREADS"

    echo "[$ID] gzip: $(date)"
    gzip "$FASTQ_DIR/${ID}.fastq"

    # Check the read count against the SRA run table
    EXPECTED=$(awk -v r="$ID" '$1==r {print $4}' "$RUNTABLE")
    ACTUAL=$(( $(zcat "$OUT" | wc -l) / 4 ))
    echo "[$ID] reads: expected $EXPECTED, got $ACTUAL"
    if [ "$EXPECTED" != "$ACTUAL" ]; then
        echo "[$ID] WARNING: read count mismatch"
    fi

    # Remove the intermediate SRA file to save space
    rm -rf "${SRA_DIR:?}/$ID"
    echo "[$ID] done: $(date)"
done < "$IDS"

echo "All done: $(date)"
ls -lh "$FASTQ_DIR"
