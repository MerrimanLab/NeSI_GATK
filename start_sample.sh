
DIR=$1
FILE=$2
sample=$3

JOBID=$(sbatch -A uoo02378 --array=1,2 --partition=prepost ~/uoo02378/NeSI_GATK/s0_split.sl $DIR $FILE $sample)
echo "sbatch -A uoo02378 --array=1,2 ~/uoo02378/NeSI_GATK/s0_split.sl $DIR $FILE $sample"
JOBID=$(echo $JOBID | awk '{print $4}')
JOBID2=$(sbatch -A uoo02378 -d afterok:$JOBID --partition=prepost --hint=nomultithread ~/uoo02378/NeSI_GATK/s1_check_split.sl $DIR $sample)
echo "sbatch -A uoo02378 -d afterok:$JOBID --partition=prepost --hint=nomultithread ~/uoo02378/NeSI_GATK/s1_check_split.sl $DIR $sample"

