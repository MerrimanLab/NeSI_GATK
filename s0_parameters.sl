#!/bin/bash
#SBATCH -J s0_parameters.sl
#SBATCH -A uoo00053         # Project Account
#SBATCH --time=15:00:00     # Walltime
#SBATCH --mem-per-cpu=4000  # memory/cpu (in MB)
#SBATCH --cpus-per-task=16   # 12 OpenMP Threads
#SBATCH --nodes=1
#SBATCH --mail-user=matt.bixley@otago.ac.nz
#SBATCH --mail-type=ALL
#SBATCH -C sb

# Matt Bixley
# University of Otago
# Jun 2016

#sample=$1
#file1=$2
#file2=$3
sample=FR07921700
file1=~/uoo00053/RawSeq/HHKLKCCXX_1_151126_FR07921700_Homo-sapiens__R_151102_MANPHI_FGS_M001_R1.fastq.gz
file2=~/uoo00053/RawSeq/HHKLKCCXX_1_151126_FR07921700_Homo-sapiens__R_151102_MANPHI_FGS_M001_R2.fastq.gz

export OPENBLAS_MAIN_FREE=1

#echo slurm jobib = $SLURM_JOBID > $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm submit dir = $SLURM_SUBMIT_DIR >> $SLURM_SUBMIT_DIR/dirs.txt
#echo slurm tmp dir = $TMP_DIR >> $SLURM_SUBMIT_DIR/dirs.txt

DIR=$SLURM_SUBMIT_DIR
GATK=~/uoo00053/GATK3.6/GenomeAnalysisTK.jar
module load Java/1.8.0_5
module load BWA/0.7.12-goolf-1.5.14
module load SAMtools/1.3-foss-2015a
module load picard/2.1.0

REF=~/uoo00053/reference_files/hs37d5/hs37d5.fa
SAMPWORK=~/uoo00053/working/${sample}/working/
SAMPFIN=~/uoo00053/working/${sample}/final/

sbatch ~/s1_align.sl $sample  
### currently only sends $sample across to next script
