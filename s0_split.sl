#!/bin/bash
#SBATCH -J s0_split.sl
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=5:59:00     # Walltime
#SBATCH --mem-per-cpu=20000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --nodes=1
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
export OPENBLAS_MAIN_FREE=1

echo split start $(date "+%H:%M:%S %d-%m-%Y")
# won't  work on NeSI with current installed split

zcat $DIR/input/$file1 |awk 'NR%10000000==1{x="temp/R1_"++i;}{print | "gzip > " x ".fastq.gz"}'
zcat $DIR/input/$file2 |awk 'NR%10000000==1{x="temp/R2_"++i;}{print | "gzip > " x ".fastq.gz"}'


#zcat $DIR/input/$file1 | ~/bin/parallel -k -J 1 --pipe -N40000000 cat \|gzip -c \> \'$DIR/temp/${file1_pre}\'_{#}.fastq.gz
#zcat $DIR/input/$file2 | ~/bin/parallel -k -J 1 --pipe -N40000000 cat \|gzip -c \> \'$DIR/temp/${file2_pre}\'_{#}.fastq.gz


file1Num=$(ls $DIR/temp/$file1_pre*[0-9]*fastq.gz | wc -l)
file2Num=$(ls $DIR/temp/$file2_pre*[0-9]*fastq.gz | wc -l)

#check same number of splits
if [ $file1Num -eq $file2Num ]
then
    JOBID=$(sbatch --array=1-$file1Num ~/NeSI_GATK/s1_align.sl $DIR $sample $file1 $file2)
    JOBID=$(echo $JOBID | awk '{print $4}')
    sleep 2
    sbatch -d $JOBID ~/NeSI_GATK/s1_gatherBam.sl $DIR $sample
fi

echo split finish $(date "+%H:%M:%S %d-%m-%Y")

