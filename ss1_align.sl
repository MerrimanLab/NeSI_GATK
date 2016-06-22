#!/bin/bash
#SBATCH -J ss1_align.sl
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
file1=~/uoo00053/RawSeq/HHKLKCCXX_1_151126_FR07921700_Homo-sapiens__R_151102_MANPHI_FGS_M001_R1.fastq.gz
file2=~/uoo00053/RawSeq/HHKLKCCXX_1_151126_FR07921700_Homo-sapiens__R_151102_MANPHI_FGS_M001_R2.fastq.gz
export OPENBLAS_MAIN_FREE=1

#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
DIR=$SLURM_SUBMIT_DIR

module load SpeedSeq/20160531-foss-2015a

REF=~/uoo00053/reference_files/hs37d5/hs37d5.fa
RG="@RG\tID:group1\tSM:${sample}\tPL:illumina\tLB:lib1\tPU:unit1"

speedseq align \
    -o ~/uoo00053/speedwork/${sample} \
    -R $RG \
    $REF \
    $file1 \
    $file2
    
    
