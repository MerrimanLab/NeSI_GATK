#!/bin/bash
#SBATCH -J s1_gatherBam
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=4000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH --mail-user=matt.bixley@otago.ac.nz
#SBATCH --mail-type=ALL
#SBATCH -C sb

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016

DIR=$1
sample=$2
export OPENBLAS_MAIN_FREE=1
source ~/NeSI_GATK/gatk_references.sh

module load picard/2.1.0

ARGS=$(ls $DIR/temp/{sample}*.bam | tr '\n' ' ' | sed 's/ / -I=/g' | sed 's/^/-I=/g' |sed 's/-I=$/ /g')

if ! srun java -Xmx19g -jar $EBROOTPICARD/picard.jar GatherBamFiles $ARGS OUTPUT=$DIR/temp/${sample}_gathered.bam METRICS_FILE=$DIR/logs/metrics.txt TMP_DIR=$DIR ; then
	echo "markdup failed"
	exit 1
fi
sbatch ~/NeSI_GATK/s2_sortSam.sl $DIR $sample
#rm ${sample}_sorted_reads.bam #### uncomment later
