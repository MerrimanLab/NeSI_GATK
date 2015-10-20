#!/bin/bash
#SBATCH -J s9_haplotypeCaller
#SBATCH -A uoo00008         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=4048  # memory/cpu (in MB)
#SBATCH --cpus-per-task=12   # 12 OpenMP Threads
#SBATCH --mail-user=murray.cadzow@otago.ac.nz
#SBATCH --mail-type=ALL


# Murray Cadzow
# University of Otago
# 20 Oct 2015


export OPENBLAS_MAIN_FREE=1

#i=$SLURM_ARRAY_TASK_ID
sample=$1
i=$2
#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt



DBSNP=~/nesi00225/reference_files/resource_bundle2014/dbsnp_138.b37.vcf.gz
MILLS=~/nesi00225/reference_files/resource_bundle2014/Mills_and_1000G_gold_standard.indels.b37.vcf
INDELS=~/nesi00225/reference_files/resource_bundle2014/1000G_phase1.indels.b37.vcf
REF=~/nesi00225/reference_files/hs37d5/hs37d5.fa

DIR=$SLURM_SUBMIT_DIR
module load GATK/3.4-46

srun java -jar -Xmx30g $GATK \
	-T HaplotypeCaller \
	-R $REF \
	-I ${sample}_baserecal_reads_${i}.bam \
	-L ${i} \
	--emitRefConfidence GVCF \
	--variant_index_type LINEAR \
	--variant_index_parameter 128000 \
	--dbsnp $DBSNP \
	-o ~/nesi00225/${sample}_${i}.raw.snps.indels.g.vcf \
	-nct 12

file=~/nesi00225/${sample}_${i}.raw.snps.indels.g.vcf
label=${sample}_${i}_vcf
echo "transfer --perf-cc 4 --perf-p 8 --label '$label' -- nz#uoa/~/nesi225/${file} murraycadzow#biochemcompute/~/Murray/finished/${file} " | ssh -i ~/.ssh/git murraycadzow@cli.globusonline.org
echo "file transfer begun"
