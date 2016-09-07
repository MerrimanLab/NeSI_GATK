#!/bin/bash
#SBATCH -J s1_align.sl
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=5:59:00     # Walltime
#SBATCH --mem-per-cpu=4000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=16   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH -C sb

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016
echo align start $(date "+%H:%M:%S %d-%m-%Y")
source ~/NeSI_GATK/gatk_references.sh

DIR=$1
sample=$2
RG=$(head -1 $DIR/input/rg_info.txt)
export OPENBLAS_MAIN_FREE=1

i=$SLURM_ARRAY_TASK_ID
module load BWA/0.7.12-goolf-1.5.14
module load SAMtools/1.2-goolf-1.5.14


#RG="@RG\tID:group1\tSM:${sample}\tPL:illumina\tLB:lib1\tPU:unit1"
if ! srun bwa mem -M -t ${SLURM_JOB_CPUS_PER_NODE} -R ${RG} $REF $DIR/temp/R1_${i}.fastq.gz $DIR/temp/R2_${i}.fastq.gz 2> $DIR/logs/${sample}_${i}_bwa.log | samtools view -bh - > $DIR/temp/${sample}_aligned_reads_${i}.bam ; then
        echo "BWA failed"
	touch $DIR/final/failed.txt
        exit 1
fi

rm $DIR/temp/R1_${i}.fastq.gz $DIR/temp/R2_${i}.fastq.gz

echo align finish $(date "+%H:%M:%S %d-%m-%Y")


