#!/bin/bash
#SBATCH -J s2_sortSam.sl
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=11:59:00     # Walltime
#SBATCH --mem-per-cpu=4000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=16   # 12 OpenMP Threads
#SBATCH --nodes=1

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016
echo sort start $(date "+%H:%M:%S %d-%m-%Y")

DIR=$1
sample=$2
export OPENBLAS_MAIN_FREE=1
source ~/NeSI_GATK/gatk_references.sh

#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt

module load picard/2.1.0
if ! srun java -Xmx8g -jar $EBROOTPICARD/picard.jar SortSam INPUT=$DIR/temp/${sample}_gathered.bam OUTPUT=$DIR/temp/${sample}_sorted_reads.bam SORT_ORDER=coordinate TMP_DIR=$DIR ; then
	echo "sort sam failed"
	touch $DIR/final/failed.txt
	exit 1
fi
echo sort finish $(date "+%H:%M:%S %d-%m-%Y")

JOBID=$(sbatch ~/NeSI_GATK/s3_markdup.sl $DIR $sample)
echo s3_markdup $(echo $JOBID | awk '{print $4}') >> $DIR/jobs.txt
rm $DIR/temp/${sample}_gathered.bam
