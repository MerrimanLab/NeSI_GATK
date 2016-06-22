#!/bin/bash
#SBATCH -J s8_printReads
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=31024  # memory/cpu (in MB)
#SBATCH --cpus-per-task=1   # 12 OpenMP Threads
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

#DIR=$SLURM_SUBMIT_DIR
DIR=~/uoo00053/working/
GATK=~/uoo00053/GATK3.6/GenomeAnalysisTK.jar
module load Java/1.8.0_5

if ! srun java -Xmx30g -jar $GATK \
	-T PrintReads \
	-R $REF \
	-BQSR ~/uoo00053/working/${sample}_recal_data${i}.grp \
	-I ~/uoo00053/working/${sample}_realigned_reads_${i}.bam \
	-o ~/uoo00053/working/${sample}_baserecal_reads_${i}.bam \
	-l INFO \
	-log ~/uoo00053/working/printreads${i}.log \
	-L ${i} ; then

	echo "print reads on chr $i failed"
	exit 1
fi

JOB=$(sbatch -J s9_haplotypecaller_chr${i} ~/NeSI_GATK/s9_haplotypecaller.sl $sample $i)
echo "chr $i haplotypecaller job submitted $JOB"
