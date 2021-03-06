#!/bin/bash
#SBATCH -J s2_sortSam.sl
#SBATCH -A nesi00319         # Project Account
#SBATCH --time=05:59:00     # Walltime
#SBATCH --mem-per-cpu=24001  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=FAIL,TIME_LIMIT_90

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
i=$SLURM_ARRAY_TASK_ID

#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt

module load picard/2.1.0
if ! srun java -Xmx8g -jar $EBROOTPICARD/picard.jar SortSam \
                                                    INPUT=$DIR/temp/${sample}_aligned_reads_${i}.bam \
                                                    OUTPUT=$DIR/temp/${sample}_sorted_${i}.bam \
                                                    SORT_ORDER=coordinate \
                                                    CREATE_INDEX=true \
                                                    TMP_DIR=$DIR ; then
	echo "sort sam failed chunk ${i}"
	echo "sort failed chunk ${i}" >> $DIR/final/failed.txt
	exit 1
fi
echo sort finish $(date "+%H:%M:%S %d-%m-%Y")

rm $DIR/temp/${sample}_aligned_reads_${i}.bam
