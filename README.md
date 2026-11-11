# rnaseq_adipose_pipeline

Reanalysis of human subcutaneous adipose tissue RNA-seq from Cifarelli et al.,
*J Clin Invest* 2020 (GEO GSE152991), comparing metabolically healthy lean (MHL),
metabolically healthy obese (MHO) and metabolically unhealthy obese (MUO) groups.

## Data
- 9 samples (3 MHL, 3 MHO, 3 MUO) from GSE152991 / PRJNA641129
- Each sample was uploaded to SRA as two runs (read 1 and read 2); this project uses
  **read 1 only** (single-end, 101 bp, stranded TruSeq total RNA)
- Run IDs: `config/ids.csv`; sample groups: `config/metadata.csv`

## Software
| Component | Version |
|---|---|
| HPC | SDSC Expanse (Slurm, Lustre project storage) |
| Nextflow | 25.04.8 |
| Java | OpenJDK 17 (conda environment) |
| Containers | SingularityPRO 4.1.2 |
| Pipeline | nf-core/rnaseq 3.26.0 |
| Data download | SRA Toolkit 2.10.9 |
| Reference | GRCh38 primary assembly + GENCODE release 50 |

nf-core/rnaseq 3.27.0 requires Nextflow ≥ 25.10.4, so 3.26.0 is the newest
release compatible with Nextflow 25.04.8.

## Repository layout
```
config/     run IDs, sample metadata, nf-core samplesheet, Nextflow configs
scripts/    Slurm job scripts (download, pipeline runs)
tests/      validated Expanse smoke test (Nextflow + Singularity + Slurm)
```

## Usage (SDSC Expanse)
1. **Validate the setup:** `sbatch tests/smoke/run_singularity_nextflow_test.sh`
2. **Download FASTQs:** `sbatch scripts/download_fastq.sbatch config/ids.csv`
   (read counts are checked against `config/all_runs.tsv`)
3. **Pipeline test:** `sbatch scripts/rnaseq_test.sbatch`
4. **Full run:** *(in progress)*
5. **Analysis:** *(in progress)*

## Notes
- Job scripts set `PS1` before loading conda, because the Anaconda module's
  `conda.sh` fails under `set -u` in batch jobs.
- Per-sample pO2 is not available on GEO; analyses use the group means reported
  in the paper (MHL 64.7, MHO 56.7, MUO 48.6 mmHg) as a group-level proxy.
