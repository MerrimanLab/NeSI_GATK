#!/bin/bash
#SBATCH -J s7_baseRecal
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=00:01:00     # Walltime
#SBATCH --mem-per-cpu=1024  # memory/cpu (in MB)
#SBATCH --cpus-per-task=12   # 12 OpenMP Threads
#SBATCH --array=1-22
export OPENBLAS_MAIN_FREE=1
POP=$1
i=$SLURM_ARRAY_TASK_ID
#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt


DIR=$SLURM_SUBMIT_DIR
module load GATK/3.4-46


DBSNP=~/Murray/Bioinformatics/Reference_Files/ALL.wgs.dbsnp.build135.snps.sites.vcf.gz
MILLS=~/Murray/Bioinformatics/Reference_Files/ALL.wgs.indels_mills_devine_hg19_leftAligned_collapsed_double_hit.indels.sites.vcf.gz
INDELS=~/Murray/Bioinformatics/Reference_Files/ALL.wgs.low_coverage_vqsr.20101123.indels.sites.vcf.gz
REF=~/Murray/Bioinformatics/Reference_Files/FASTA/hs37d5/hs37d5.fa



echo "srun java -Xmx30g -jar $GATK \
	-T BaseRecalibrator \
	-R $REF \
	-I realigned_reads_${i}.bam \
	-o recal_data${i}.grp \
	-knownSites $DBSNP \
	-knownSites $MILLS \
	-knownSites $INDELS \
	-l INFO \
	-cov ReadGroupCovariate \
	-cov QualityScoreCovariate \
	-cov CycleCovariate \
	-cov ContextCovariate \
	-log baserecal${i}.log \
	-L ${i} "

