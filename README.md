# NeSI_GATK


Designed on GATK best practices for GATK 3.4

Updating for GATK 3.6 in progress (AUG 2016)


requires:

passwordless ssh login setup for nesi

passwordless ssh login for globus cli

globus endpoint access for source data, nesi and, final storage 


master python control script will create the following directory structure:
$project_dir/working_dir/$sample/{input,temp,logs,final}

fastqs are stored in input/

all 'middle files' are stored in temp/

all logs are stored in logs/

final bams and g.vcf files are stored in final/
