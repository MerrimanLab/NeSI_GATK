#!/bin/bash
#SBATCH -J s0_split.sl
#SBATCH --time=2:59:00     # Walltime
#SBATCH --mem-per-cpu=1000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=8   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=FAIL,TIME_LIMIT_90

# Murray Cadzow
# University of Otago
# 29 Jul 2016

# Matt Bixley
# University of Otago
# Jun 2016
DIR=$1 #sample dir
file=$2
sample=$3

i=$SLURM_ARRAY_TASK_ID

echo split start $(date "+%H:%M:%S %d-%m-%Y")



if [[ $i -eq 1 ]]
then
	srun zcat $DIR/input/${file}_R${i}.fastq.gz | awk 'BEGIN{i=1} NR%50000000==1{if(i>1){close(x)} x="~/uoo02378/pigz-2.4/pigz -p 8 -c > temp/R1_"i++".fastq.gz"}{print | x}'
fi

if [[ $i -eq 2 ]]
then
	srun zcat $DIR/input/${file}_R${i}.fastq.gz | awk 'BEGIN{i=1} NR%50000000==1{if(i>1){close(x)} x="~/uoo02378/pigz-2.4/pigz -p 8 -c > temp/R2_"i++".fastq.gz"}{print | x}'
fi

#rm $DIR/input/$file2 $DIR/input/$file1

echo $DIR $file $sample > $DIR/final/s0_args_${i}.txt
echo split finish $(date "+%H:%M:%S %d-%m-%Y")

