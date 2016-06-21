#!/bin/bash
#SBATCH -J s1_align.sl
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=4000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=16   # 12 OpenMP Threads
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

#sample=$1
#file1=$2
#file2=$3
sample=FR07921700
file1=HHKLKCCXX_1_151126_FR07921700_Homo-sapiens__R_151102_MANPHI_FGS_M001_R1.fastq.gz
file2=HHKLKCCXX_1_151126_FR07921700_Homo-sapiens__R_151102_MANPHI_FGS_M001_R2.fastq.gz
export OPENBLAS_MAIN_FREE=1

#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt

DIR=$SLURM_SUBMIT_DIR
module load BWA/0.7.12-goolf-1.5.14
module load SAMtools/1.2-goolf-1.5.14
module load picard/2.1.0

REF=~/uoo00053/reference_files/hs37d5/hs37d5.fa

RG="@RG\tID:group1\tSM:${sample}\tPL:illumina\tLB:lib1\tPU:unit1"
if ! bwa mem -M -t 16 -R $RG $REF $file1 $file2 2> ~/uoo00053/working/${sample}_bwa.log | samtools view -bh - > ~/uoo00053/working/${sample}_aligned_reads.bam ; then
        echo "BWA failed"

java -Xmx8g -jar picard.jar CollectAlignmentSummaryMetrics \
        REFERENCE=$REF \
        INPUT=~/uoo00053/working/${sample}_aligned_reads.bam \
        OUTPUT=~/uoo00053/working/${sample}_bam_summary.txt

        exit 1
fi

sbatch ~/s2_sortSam.sl $sample

