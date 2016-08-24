

"""
    Murray Cadzow
    August 2016
    University of Otago

    requires passwordless ssh for both nesi and globus

"""

import subprocess
import time
from optparse import OptionParser
from optparse import OptionGroup

def parse_arguments():
    """ Parse the commandline arguments

    """
    parser = OptionParser()
    nesi_options = OptionGroup(parser, "NeSI settings")
    nesi_options.add_option('--nesi-username', dest = 'username', help="NeSI ssh username - passwordless ssh access needs" +
                            " to have been setup")
    nesi_options.add_option('--nesi-project', dest = 'project', help='NeSI project account name')

    globus_options = OptionGroup(parser, "Globus options")
    globus_options.add_option('--globus-id', dest = 'globus_id', help = "Globus account id")
    globus_options.add_option('--globus-source-endpoint', dest = 'globus_source_ep', help = "details for source data endpoint and path to dir" +
                              "e.g. user1#ep1/path/to/dir/")
    globus_options.add_option('--globus-nesi-endpoint', dest = 'globus_nesi_ep', help = "globus details for nesi" +
                              "e.g. nz#uoa")
    globus_options.add_option('--globus-results-endpoint', dest = 'globus_results_ep', help = "details for results endpoint and  base path to dir"+
                              "eg user3#ep3/path/to/dir/")

    data_options = OptionGroup(parser,'Input Data settings')
    data_options.add_option('--sample-file', dest='sample_file', help = 'path to file containing sample information\n' +
                           "Sample file is in format <sample>\\t<RG>\\t<R1.fastq.gz>\\t<R2.fastq.gz>"
                           )
    data_options.add_option('--finished-file', dest = 'finished_file', help = 'path to file to record samples as they finish, also used to resume from')
    parser.add_option_group(nesi_options)
    parser.add_option_group(globus_options)
    parser.add_option_group(data_options)
    parser.add_option('--pause', dest = 'pause', help='Number of seconds to wait between checks. Default is 600 - i.e. 10 min')
    (options, args) = parser.parse_args()

    # assert all options are filled in
    assert options.username is not None,         "Need Nesi Username"
    assert options.project is not None,         "Need NeSI project"
    assert options.globus_id is not None,         "Need globus id"
    assert options.globus_source_ep is not None,         "Need globus source endpoint"
    assert options.globus_nesi_ep is not None,         "Need NeSI globus endpoint"
    assert options.globus_results_ep is not None,         "Need globus results endpoint"
    assert options.sample_file is not None,         "Need sample file"
    assert options.finished_file is not None,         "Need finished file"
    if options.pause is None:
        options.pause = 600
    return(options)


"""
GLOBUS METHODS
"""
#returns string for transfer_id
def globus_send_file(globus_id, from_ep, to_ep, sample, file):
    sshCommand = ["ssh",'-t', globus_id + "@cli.globusonline.org",
                   "transfer", "--label","'" + sample +"_up" + "'", "--", from_ep + file, to_ep + file]
    return(str(subprocess.check_output(sshCommand, stderr = subprocess.PIPE).strip(), 'utf-8').split()[2])


# returns string of the globus transfer status (ACTIVE, SUCCEEDED, etc)
def check_globus_transfer(globus_id, transfer_id):
    sshCommand = ["ssh",'-t', globus_id + "@cli.globusonline.org", "details","-f","status", transfer_id]
    return(str(subprocess.check_output(sshCommand, stderr = subprocess.PIPE).strip(),'utf-8').split()[1] )


# returns string for transfer_id
def globus_send_dir(globus_id, from_ep, to_ep, sample):
    sshCommand = ["ssh",'-t', globus_id + "@cli.globusonline.org",
                   "transfer", "--label", "'" + sample + "_dir_down" + "'", "--", from_ep, to_ep, "-r"]
    return(str(subprocess.check_output(sshCommand, stderr = subprocess.PIPE).strip(), 'utf-8').split()[2])



"""
NESI METHODS
"""
def make_nesi_dir_structure(options, samples):
    path = '/gpfs1m/projects/' + options.project + "/" + 'working_dir/' +"{" + ",".join(samples) + "}/{input,temp,logs,final}"
    sshCommand = ['ssh','-t',options.username + '@login.uoa.nesi.org.nz']
    command = ['mkdir','-p',path,]
    subprocess.check_output(sshCommand + command, stderr = subprocess.PIPE).strip()


def nesi_start(options, sample):
    sshCommand = ['ssh','-t',options.username + '@login.uoa.nesi.org.nz' , "'", "touch","testfile.txt'"]
    subprocess.check_output(sshCommand +[file], stderr = subprocess.PIPE).strip()


def check_nesi(options, path):
    #path = '/gpfs1m/projects/' + options.project + "/working_dir/" + sample
    sshCommand = ['ssh','-t',options.username + '@login.uoa.nesi.org.nz']
    command = ['cd', path,'&&', 'bash','~/NeSI_GATK/echo_time_mod.sh', './']
    files = str(subprocess.check_output(sshCommand + command, stderr = subprocess.PIPE).strip(), 'utf-8').split("\n")
    files_dict = {}
    for file in files:
        file = file.split()
        files_dict[file[0]] = file[1:]
    return(files_dict)


def nesi_sample_rmdir(options, sample):
    sshCommand = ['ssh','-t',options.username + '@login.uoa.nesi.org.nz' , "'", "rm","-r","/gpfs1m/projects"+options.project+"/working_dir/"+sample,"'"]
    subprocess.check_output(sshCommand +[file], stderr = subprocess.PIPE).strip()


def nesi_sample_rg(options, samples_dict, sample):
    sshCommand = ['ssh','-t',options.username + '@login.uoa.nesi.org.nz']
    command = ['echo','\"' + samples_dict[sample][0] +'\"','>', '/gpfs1m/projects/'+ options.project +'/working_dir'+sample+'/input/rg_info.txt']
    subprocess.check_output(sshCommand + command, stderr = subprocess.PIPE).strip()


"""
LOCAL METHODS
"""
def check_send(options, transfer_ids):
    transfers_complete = []
    for transfer_id in transfer_ids:
          if (check_globus_transfer(options.globus_id, transfer_id) == 'SUCCEEDED'):
                transfers_complete =  transfers_complete + [True]
    if(sum(transfers_complete ==  len(transfer_ids))):
        return (True)
    else:
        return (False)


def load_finished_samples(finished_file):
    finished_samples = []
    with open(finished_file,'r') as f:
        for line in f:
            line = line.strip()
            finished_samples = finished_samples + [line]
    f.close()
    return(finished_samples)


# returns sample_dict without the finished samples present
def exclude_samples(sample_dict, finished_samples):
    for sample in finished_samples:
        if sample in sample_dict:
            del sample_dict[sample]
    return(sample_dict)


def write_finished_sample(options, sample):
    with open(options.finished_file,'a') as f:
        f.write(sample + '\n')
    f.close()

def write_failed_sample(options, sample):
    with open(options.finished_file + ".FAILED", 'a') as f:
        f.write(sample + '\n')
    f.close()

def load_sample_info(sampleFile):
    # file should be <sample> \t <RG> \t {other \t delim cols} \t <R1.fastq.gz> \t <R2.fastq.gz>
    samples_dict = {}
    with open(sampleFile,'r') as f:
        header = next(f)
        for line in f:
            line = line.split('\t')
            samples_dict[line[0]] = line[1:]
    f.close()
    return(samples_dict, header[1:])


def get_samples(sample_dict):
    samples = []
    for key in sample_dict:
        samples = samples + [key]
    return(samples)


def poll_files(options, sample):
    path =  "/gpfs1m/projects/"+options.project+"/working_dir/"+sample+"/final/"
    # grab initial file sizes and modifications
    initialCheck = check_nesi(options.username, path)
    if 'finished.txt' in initialCheck:
        return ("Finished")
    elif 'failed.txt' in initialCheck:
        return("Failed")
    else:
        return (False)




def process_samples(options, samples_dict):
    #work flow for single sample
    finished = []
    for sample in samples_dict:
        # send fastqs
        fq1 = samples_dict[sample][len(samples_dict[sample])-2]
        fq2 = samples_dict[sample][len(samples_dict[sample])-1]
        sample_fq = [globus_send_file(options.globus_id, options.globus_source_ep , options.globus_nesi_ep ,sample, fq1),
                 globus_send_file(options.globus_id, options.globus_source_ep , options.globus_nesi_ep , sample, fq2)]
        # check transfer successful
        transfer = False
        while(transfer == False):
            transfer = check_send(sample_fq)
            if( transfer == False):
                time.sleep(options.pause)

        # start nesi job
        nesi_sample_rg(options, samples_dict, sample)
        nesi_start(options, sample)

        # check finished
        finished = False
        while(finished == False):
            finished = poll_files(options, sample)
            if( transfer == False):
                time.sleep(options.pause)

        if(finished != 'Failed'):
            # transfer back
            results = globus_send_dir()
            transfer = False
            while(transfer == False):
                transfer = check_send(results)
                if( transfer == False):
                    time.sleep(options.pause)
            # write out finished sample id
            write_finished_sample(options, sample)
        else:
            write_failed_sample(options, sample)

        # remove sample directory on nesi
        nesi_sample_rmdir(options, sample)


def main():
    options = parse_arguments()

    (samples_dict,sample_header) = load_sample_info(options.sample_file)

    finished_samples = load_finished_samples(options.finished_file)

    samples_dict = exclude_samples(samples_dict, finished_samples)

    samples = get_samples(samples_dict)

    make_nesi_dir_structure(options.username, options.project, samples)

    process_samples(options, samples_dict)

if __name__ == "__main__":
    main()


