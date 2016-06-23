#!/bin/bash
#SBATCH -J ss2_call_SNVs.sl
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=4000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=16   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH --mail-user=matt.bixley@otago.ac.nz
#SBATCH --mail-type=ALL
#SBATCH -C sb

# Matt Bixley
# University of Otago
# Jun 2016

sample=FR07921700
export OPENBLAS_MAIN_FREE=1

#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#DIR=$SLURM_SUBMIT_DIR
DIR=~/uoo00053/speedwork/
REF=~/uoo00053/reference_files/hs37d5/hs37d5.fa

module load SpeedSeq/20160531-foss-2015a

speedseq var \
    -o ~/uoo00053/speedwork/${sample} \
    -w ~/uoo00053/reference_files/hs37d5/hs37d5cs.bed \
    $REF \
    ~/uoo00053/speedwork/${sample}.bam
  
