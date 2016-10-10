# NeSI_GATK

TESTING IN PROGRESS

need to have pigz installed (path is currently hard coded in s0_split.sl)


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


How to run job_sample_control.py (tested on python v3.5):

```
python NeSI_GATK/job_sample_control.py \
    --nesi-username=user.name \
    --nesi-project=project_code \
    --globus-id=globusid \
    --globus-source-endpoint=username\#endpointname/path/to/fastqs/ \
    --globus-nesi-endpoint=nz\#uoa \
    --globus-results-endpoint=username\#endpointname/path/to/download/results/to/ \
    --sample-file=sample_file.txt \
    --finished-file=finished_samples.txt \
    --pause=600 \
    --log=logfile.log
```
