#!/bin/bash
#SBATCH -J s0_split.sl
#SBATCH -A nesi00319         # Project Account
#SBATCH --time=5:59:00     # Walltime
#SBATCH --mem-per-cpu=1000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=8   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH -C sb
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=FAIL,TIME_LIMIT_90

# Murray Cadzow
# University of Otago
# 29 Jul 2016

# Matt Bixley
# University of Otago
# Jun 2016
DIR=$1 #sample dir
file1=$2
file2=$3
sample=$4


echo split start $(date "+%H:%M:%S %d-%m-%Y")




srun zcat $DIR/input/$file1 | awk 'BEGIN{i=1} NR%50000000==1{if(i>1){close(x)} x="~/pigz-2.3.3/pigz -p 8 -c > temp/R1_"i++".fastq.gz"}{print | x}'
srun zcat $DIR/input/$file2 | awk 'BEGIN{i=1} NR%50000000==1{if(i>1){close(x)} x="~/pigz-2.3.3/pigz -p 8 -c > temp/R2_"i++".fastq.gz"}{print | x}'

file1Num=$(ls $DIR/temp/R1*fastq.gz | wc -l)
file2Num=$(ls $DIR/temp/R2*fastq.gz | wc -l)

#check same number of splits
if [[ $file1Num -eq $file2Num && $file1Num > 0 && $file2Num > 0 ]]
then
    JOBID=$(sbatch --array=1-$file1Num ~/NeSI_GATK/s1_align.sl $DIR $sample)
    JOBID=$(echo $JOBID | awk '{print $4}')
    sleep 20
    JOBID2=$(sbatch -d $JOBID --array=1-$file1Num ~/NeSI_GATK/s2_sortSam.sl $DIR $sample)
    JOBID2=$(echo $JOBID2 | awk '{print $4}')
    JOBID3=$(sbatch -d $JOBID2 ~/NeSI_GATK/s3_merge_bams.sl $DIR $sample)
    JOBID3=$(echo $JOBID3 | awk '{print $4}')
    echo s1_align $JOBID >> $DIR/jobs.txt
    echo s2_sortSam $JOBID2 >> $DIR/jobs.txt
    echo s3_merge_bam $JOBID3 >> $DIR/jobs.txt
fi

rm $DIR/input/$file2 $DIR/input/$file1

echo $DIR $file1 $file2 $sample > $DIR/final/s0_args.txt
echo split finish $(date "+%H:%M:%S %d-%m-%Y")

