#!/bin/bash
#SBATCH -J s1_check_split.sl
#SBATCH --time=0:10:00     # Walltime
#SBATCH --mem-per-cpu=1000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=FAIL,TIME_LIMIT_90

DIR=$1
sample=$2 

file1Num=$(ls $DIR/temp/R1*fastq.gz | wc -l)
file2Num=$(ls $DIR/temp/R2*fastq.gz | wc -l)



if [[ $file1Num -eq $file2Num && $file1Num > 0 && $file2Num > 0 ]]
then
    JOBID=$(sbatch -A uoo02378 --array=1-$file1Num ~/uoo02378/NeSI_GATK/s2_align.sl $DIR $sample)
    JOBID=$(echo $JOBID | awk '{print $4}')
    sleep 20
    JOBID2=$(sbatch -A uoo02378 -d afterok:$JOBID --array=1-$file1Num ~/uoo02378/NeSI_GATK/s3_sortSam.sl $DIR $sample)
    JOBID2=$(echo $JOBID2 | awk '{print $4}')
    JOBID3=$(sbatch -d afterok:$JOBID2 ~/uoo02378/NeSI_GATK/s4_markdup.sl $DIR $sample)
    JOBID3=$(echo $JOBID3 | awk '{print $4}')
    echo s2_align $JOBID >> $DIR/jobs.txt
    echo s3_sortSam $JOBID2 >> $DIR/jobs.txt
    echo s4_merge_bam $JOBID3 >> $DIR/jobs.txt

    echo "sbatch -A uoo02378 --array=1-$file1Num ~/uoo02378/NeSI_GATK/s2_align.sl $DIR $sample"
    echo "sbatch -A uoo02378 -d afterok:$JOBID --array=1-$file1Num ~/uoo02378/NeSI_GATK/s3_sortSam.sl $DIR $sample"
    echo "sbatch -A uoo02378 -d afterok:$JOBID2 ~/uoo02378/NeSI_GATK/s4_markdup.sl $DIR $sample"

fi

