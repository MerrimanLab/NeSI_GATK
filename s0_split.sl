#!/bin/bash
#SBATCH -J s0_split.sl
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=2:00:00     # Walltime
#SBATCH --mem-per-cpu=4000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH --mail-user=matt.bixley@otago.ac.nz
#SBATCH --mail-type=ALL
#SBATCH -C sb

# Murray Cadzow
# University of Otago
# 29 Jul 2016

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
zcat $file1 | split -l 10000000 --suffix-length=3 --numeric-suffixes=1 --filter='gzip > $FILE.gz' - $file1
zcat $file2 | split -l 10000000 --suffix-length=3 --numeric-suffixes=1 --filter='gzip > $FILE.gz' - $file2


file1Num=$(ls $file1 | wc -l)
file2Num=$(ls $file2 | wc -l)

#check same number of splits
if [ $file1Num -eq $file2Num ]
then
    sbatch --array=1-$fileNum ~/NeSI_GATK/s1_align.sl $sample
fi
