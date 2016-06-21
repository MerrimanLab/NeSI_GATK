#!/bin/bash
#SBATCH -J s9_haplotypeCaller
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=4048  # memory/cpu (in MB)
#SBATCH --cpus-per-task=16   # 12 OpenMP Threads
#SBATCH --mail-user=matt.bixley@otago.ac.nz
#SBATCH --mail-type=ALL
#SBATCH -C sb

# Murray Cadzow
# University of Otago
# 20 Oct 2015

# Matt Bixley
# University of Otago
# Jun 2016

export OPENBLAS_MAIN_FREE=1

#i=$SLURM_ARRAY_TASK_ID
sample=$1
i=$2
#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt

DBSNP=~/uoo00053/reference_files/dbsnp_138.b37.vcf
MILLS=~/uoo00053/reference_files/Mills_and_1000G_gold_standard.indels.b37.vcf
INDELS=~/uoo00053/reference_files/1000G_phase1.indels.b37.vcf
REF=~/uoo00053/reference_files/hs37d5/hs37d5.fa

DIR=$SLURM_SUBMIT_DIR
GATK=~/uoo00053/GATK3.6/GenomeAnalysisTK.jar
module load Java/1.8.0_5

if ! srun java -jar -Xmx30g $GATK \
	-T HaplotypeCaller \
	-R $REF \
	-I ~/uoo00053/working/${sample}_baserecal_reads_${i}.bam \
	-L ${i} \
	--emitRefConfidence GVCF \
	--variant_index_type LINEAR \
	--variant_index_parameter 128000 \
	--dbsnp $DBSNP \
	-o ~/uoo00053/final/${sample}_${i}.raw.snps.indels.g.vcf \
	-nct 16 ; then

	echo "haplotypecalled on chr $i failed"
	exit 1
fi

filename=${sample}_${i}.raw.snps.indels.g.vcf

label=${sample}_${i}_vcf
#echo "transfer --perf-cc 4 --perf-p 8 --label '$label' -- nz#uoa/~/uoo00053/final/${filename} murraycadzow#biochemcompute/~/Murray/Bioinformatics/working_dir/nesi_retrieved/sb/${filename} " | ssh -i ~/.ssh/git murraycadzow@cli.globusonline.org
echo "file transfer begun"
