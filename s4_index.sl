#!/bin/bash
#SBATCH -J s4_Index 
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=5:59:00     # Walltime
#SBATCH --mem-per-cpu=9048  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
#SBATCH -C sb

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016
echo index start $(date "+%H:%M:%S %d-%m-%Y")

export OPENBLAS_MAIN_FREE=1
DIR=$1
sample=$2
source ~/NeSI_GATK/gatk_references.sh

module load picard/2.1.0
module load SAMtools/1.2-goolf-1.5.14

if ! srun java -Xmx8g -jar $EBROOTPICARD/picard.jar BuildBamIndex INPUT=$DIR/temp/${sample}_dedup_reads.bam ; then
	echo "index failed"
	touch $DIR/final/failed.txt
	exit 1
fi

#if ! sortsam view -f 4 $DIR/temp/${sample}_dedup_reads.bam > $DIR/final/${sample}_unmapped_reads.bam ; then
#	echo "unmapped read failed"
#	touch $DIR/final/failed.txt
#	exit 1
#fi

#sbatch ~/NeSI_GATK/s5_indelTarget.sl $sample

Ncontigs=$(cat ~/NeSI_GATK/contigs_h37.txt | wc -l)
JOBID=$(sbatch -J s7_baserecal --array=1-$Ncontigs ~/NeSI_GATK/s7_baserecal.sl $DIR $sample)
JOBID2=$(sbatch -d $(echo $JOBID | awk '{print $4}') -J s8_applyrecal --array=1-$Ncontigs ~/NeSI_GATK/s8_applyrecal.sl $DIR $sample)
JOBID3=$(sbatch -d $(echo $JOBID2 | awk '{print $4}') -J s9_haplotypecaller --array=1-$Ncontigs ~/NeSI_GATK/s9_haplotypecaller.sl $DIR $sample)
JOBID4=$(sbatch -d $(echo $JOBID3 | awk '{print $4}') ~/NeSI_GATK/s10_finish.sl $DIR)

echo baserecal $(echo $JOBID | awk '{print $4}') >> $DIR/jobs.txt
echo applyrecal $(echo $JOBID2 | awk '{print $4}') >> $DIR/jobs.txt
echo haplotypecaller $(echo $JOBID3 | awk '{print $4}') >> $DIR/jobs.txt
echo finish $(echo $JOBID4 | awk '{print $4}') >> $DIR/jobs.txt
echo index finish $(date "+%H:%M:%S %d-%m-%Y")

