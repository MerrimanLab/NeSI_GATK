#!/bin/bash
#SBATCH -J s3_merge_bams
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=5:59:00     # Walltime
#SBATCH --mem-per-cpu=24000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=2   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH -C sb
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=FAIL,TIME_LIMIT_90

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
ls $DIR/temp/${sample}_sorted*.bam > temp/sorted_bams.txt

if ! srun java -Xmx19g -jar $EBROOTPICARD/picard.jar MergeSamFiles $(sed 's/^/I=/g' < temp/sorted_bams.txt | tr '\n' ' ') \
                                                            OUTPUT=$DIR/temp/${sample}_gathered.bam \
                                                            USE_THREADING=true \
                                                            CREATE_INDEX=true \
                                                            SORT_ORDER=coordinate ; then
	echo "merge bam failed"
	echo "merge bam failed" >> $DIR/final/failed.txt
	exit 1
fi

JOBID=$(sbatch ~/NeSI_GATK/s4_markdup.sl $DIR $sample)
JOBID=$(echo $JOBID | awk '{print $4}')
echo "s4_markdup $JOBID" >> $DIR/jobs.txt

rm $DIR/temp/${sample}_aligned_reads_*.bam 
echo merge_bam finish $(date "+%H:%M:%S %d-%m-%Y")

