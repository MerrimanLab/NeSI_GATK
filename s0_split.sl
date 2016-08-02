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
DIR=$1 #sample dir
sample=$2
file1=$3
file1_pre=$(basename $(basename $file1 .gz) .fastq)
file2=$4
file2_pre=$(basename $(basename $file2 .gz) .fastq)
RG=$5
export OPENBLAS_MAIN_FREE=1


# won't  work on NeSI with current installed split
zcat $DIR/input/$file1 | ~/bin/parallel -J 1 --pipe -N10000000 'cat |gzip -c > \$\{file1_pre\}_{#}.fastq.gz'
zcat $DIR/input/$file2 | ~/bin/parallel -J 1 --pipe -N10000000 'cat |gzip -c > \$\{file2_pre\}_{#}.fastq.gz'
#zcat $DIR/input/$file1 | split -l 10000000 --suffix-length=3 --numeric-suffixes=1 --filter='gzip > $FILE.gz' - $DIR/temp/$file1
#zcat $DIR/input/$file2 | split -l 10000000 --suffix-length=3 --numeric-suffixes=1 --filter='gzip > $FILE.gz' - $DIR/temp/$file2


file1Num=$(ls $file1 | wc -l)
file2Num=$(ls $file2 | wc -l)

#check same number of splits
if [ $file1Num -eq $file2Num ]
then
    sbatch --array=1-$fileNum ~/NeSI_GATK/s1_align.sl $DIR $sample $file1 $file2 $RG
fi
