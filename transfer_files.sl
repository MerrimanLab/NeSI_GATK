#!/bin/bash
#SBATCH -J transfer_files
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=00:05:00     # Walltime
#SBATCH --mem-per-cpu=1040  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=ALL

# Murray Cadzow
# University of Otago
# 20 Oct 2015


file=$1
label=$2
export OPENBLAS_MAIN_FREE=1

#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt

DIR=$SLURM_SUBMIT_DIR

echo "globus endpoint1 endpoint2 $file"
echo "transfer --perf-cc 4 --perf-p 8 --label '$label' -- nz#uoa/~/nesi00225/${file} murraycadzow#biochemcompute/~/Murray/Bioinformatics/working_dir/nesi_retrieved/gatk_pipeline/${file} " | ssh -i ~/.ssh/git murraycadzow@cli.globusonline.org


