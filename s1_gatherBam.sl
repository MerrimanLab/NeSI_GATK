#!/bin/bash
#SBATCH -J s1_gatherBam
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=5:59:00     # Walltime
#SBATCH --mem-per-cpu=24000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH -C sb

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016
echo gather start $(date "+%H:%M:%S %d-%m-%Y")

DIR=$1
sample=$2
export OPENBLAS_MAIN_FREE=1
source ~/NeSI_GATK/gatk_references.sh

module load picard/2.1.0
rm $DIR/input/*fastq.gz
rm $DIR/temp/*.fastq.gz
ls $DIR/temp/${sample}_aligned_reads_*.bam > temp/gather_bams.txt

if ! srun java -Xmx19g -jar $EBROOTPICARD/picard.jar GatherBamFiles I=$DIR/temp/gather_bams.txt OUTPUT=$DIR/temp/${sample}_gathered.bam ; then
	echo "gather failed"
	touch $DIR/final/failed.txt
	exit 1
fi
JOBID=$(sbatch ~/NeSI_GATK/s2_sortSam.sl $DIR $sample)
echo s2_sort $(echo $JOBID | awk '{print $4}' >> $DIR/jobs.txt
rm $DIR/temp/${sample}_aligned_reads_*.bam 
echo gather finish $(date "+%H:%M:%S %d-%m-%Y")

