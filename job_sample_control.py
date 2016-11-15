

"""
    Murray Cadzow
    August 2016
    University of Otago

    requires passwordless ssh for both nesi and globus

"""

import subprocess
import time
import os.path
import logging
import sys
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
                           "Sample file is in format '<sample> <RG> <R1.fastq.gz> <R2.fastq.gz>'"
                           )
    daata_options.add_option('--sample', dest = 'sample_id', help = 'optional: id of single sample to process - must be in the sample file')
    data_options.add_option('--finished-file', dest = 'finished_file', help = 'path to file to record samples as they finish, also used to resume from')
    parser.add_option_group(nesi_options)
    parser.add_option_group(globus_options)
    parser.add_option_group(data_options)
    parser.add_option('--pause', dest = 'pause', help='Number of seconds to wait between checks. Default is 600 - i.e. 10 min')
    parser.add_option('--log', dest = 'logfile', help="Name for log file")
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
    if options.logfile is None:

        options.logfile = 'logfile_' +'_'.join([str(time.localtime().tm_year),
                                           str(time.localtime().tm_mon),
                                           str(time.localtime().tm_mday)]) +'.log'
    return(options)


"""
GLOBUS METHODS
"""
#returns string for transfer_id
def globus_send_file(options,from_ep ,to_ep, sample, file):
    sshCommand = ["ssh",'-t', options.globus_id + "@cli.globusonline.org",
                   "transfer","--encrypt", "--label","'" + sample +"_up" + "'", "--", from_ep + file, to_ep + file]
    return(str(run_ssh(options, sshCommand), 'utf-8').split()[2] )


# returns string of the globus transfer status (ACTIVE, SUCCEEDED, etc)
def check_globus_transfer(options, transfer_id):
    sshCommand = ["ssh",'-t', options.globus_id + "@cli.globusonline.org", "details","-f","status", transfer_id]
    return(str(run_ssh(options,sshCommand),'utf-8').split()[1])


# returns string for transfer_id
def globus_send_dir(options, from_ep, to_ep, sample):
    sshCommand = ["ssh",'-t', options.globus_id + "@cli.globusonline.org",
                   "transfer", "--encrypt","--label", "'" + sample + "_dir_down" + "'", "--", from_ep, to_ep, "-r"]
    return(str(run_ssh(options,sshCommand), 'utf-8').split()[2])


"""
NESI METHODS
"""
def make_nesi_dir_structure(options, sample):
    path = '/gpfs1m/projects/' + options.project + "/" + 'working_dir/' + sample + "/{input,temp,logs,final}"
    sshCommand = ['ssh','-t',options.username + '@login.uoa.nesi.org.nz']
    command = ['mkdir','-p',path,]
    run_ssh(options, sshCommand + command)

def nesi_start(options, sample, read1, read2):
    path = '/gpfs1m/projects/' + options.project + "/working_dir/" + sample + '/'
    sshCommand = ['ssh','-t',options.username + '@login.uoa.nesi.org.nz' ]
    command = ["cd", path , "&&", "sbatch","-A",options.project, "~/NeSI_GATK/s0_split.sl","$(pwd)", read1, read2, sample]
    run_ssh(options, sshCommand + command)

def check_nesi(options, path):
    #path = '/gpfs1m/projects/' + options.project + "/working_dir/" + sample
    sshCommand = ['ssh','-t',options.username + '@login.uoa.nesi.org.nz']
    command = ['ls', path]
    files = str(run_ssh(options, sshCommand + command), 'utf-8').split()
    return(files)


def nesi_sample_rmdir(options, sample):
    sshCommand = ['ssh','-t',options.username + '@login.uoa.nesi.org.nz' , "rm","-r","/gpfs1m/projects/"+options.project+"/working_dir/"+sample]
    run_ssh(options, sshCommand)


def nesi_sample_rg(options, samples_dict, sample):
    sshCommand = ['ssh','-t',options.username + '@login.uoa.nesi.org.nz']
    command = ['echo','\"' + samples_dict[sample][0] +'\"','>', '/gpfs1m/projects/'+ options.project +'/working_dir/'+sample+'/input/rg_info.txt']
    run_ssh(options, sshCommand + command)


"""
LOCAL METHODS
"""

def run_ssh(options,command):
    for attempt in range(100):
        #print(" ".join(command))
        try:
            output = subprocess.check_output(command, stderr = subprocess.PIPE).strip()
            logging.info('ssh command successful: ' + " ".join(command))
        except:
            logging.info('ssh failed retrying in ' + str(options.pause) + ' seconds')
            time.sleep(options.pause)
        else:
            return(output)
    else:
        logging.info('FAILED - all ssh attempts failed - EXITING')
        exit(1)


def check_send(options, transfer_ids):
    transfers_complete = 0
    for transfer_id in transfer_ids:
        stat = check_globus_transfer(options,transfer_id)
        if (stat == 'SUCCEEDED'):
            transfers_complete =  transfers_complete + 1
        elif (stat == 'FAILED'):
            return('FAILED')
    if(transfers_complete ==  len(transfer_ids)):
        return (True)
    else:
        return (False)


def load_finished_samples(finished_file):
    finished_samples = []
    if os.path.isfile(finished_file):
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
    # file should be space delimited: <sample> <RG> {other " "  delim cols} <R1.fastq.gz> <R2.fastq.gz>
    samples_dict = {}
    with open(sampleFile,'r') as f:
        header = next(f)
        for line in f:
            line = line.strip('\n').split(' ')
            if(line[0] != ''):
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
    check = check_nesi(options, path)
    #logging.info('pollfiles - initial_check: ' +' '.join(check))
    if ('failed.txt' in check):
        return("Failed")
    elif ('finished.txt' in check):
        return ("Finished")
    else:
        return (False)


def failed_sample(options, sample, message):
     write_failed_sample(options,sample)
     logging.info('FAILED sample: ' + sample)
     print(sample + ' ' + message)


def process_samples(options, samples_dict):
    #work flow for single sample
    finished = []
    for sample in samples_dict:
        # send fastqs
        make_nesi_dir_structure(options, sample)
        logging.info('nesi file structure made')
        path = '/gpfs1m/projects/' + options.project + "/working_dir/" + sample +'/'
        print(sample)
        fq1 = samples_dict[sample][len(samples_dict[sample])-2]
        fq2 = samples_dict[sample][len(samples_dict[sample])-1]
        sample_fq = [globus_send_file(options, options.globus_source_ep , options.globus_nesi_ep + path + 'input/', sample, fq1),
                 globus_send_file(options, options.globus_source_ep , options.globus_nesi_ep +path+ 'input/', sample,  fq2)]
        logging.info('sample: '+ sample+ " fastq started transfer up")
        # check transfer successful
        transfer = False
        while(transfer == False):
            transfer = check_send(options, sample_fq)
            if( transfer == False):
                time.sleep(options.pause)
        # skip to next sample on transfer fail (or cancel)
        if(transfer == "FAILED"):
            failed_sample(options,sample,"FAILED - Transfer")
            continue
        logging.info('sample: '+ sample + " fastq transfer finished")
        # start nesi job
        nesi_sample_rg(options, samples_dict, sample)
        logging.info('sample: ' + sample + " read group made")
        nesi_start(options, sample, fq1, fq2)
        logging.info('sample: '+sample+ ' GATK pipeline started' )
        # check finished
        finished = False
        while(finished == False):
            finished = poll_files(options, sample)
            #logging.info('checking for finished pollfiles: ' + str(finished))
            if( finished == False):
                time.sleep(options.pause)
        logging.info('sample: '+sample+ ' GATK pipeline finished')
        if(finished != 'Failed'):
            # transfer back
            results = [globus_send_dir(options, options.globus_nesi_ep + path + 'final/', options.globus_results_ep + '/' + sample + '/', sample)]
            transfer = False
            while(transfer == False):
                transfer = check_send(options, results)
                if( transfer == False):
                    time.sleep(options.pause)
            #skip to next sample on transfer fail (or cancel)
            if(transfer == 'FAILED'):
                failed_sample(options,sample,"FAILED - Transfer")
                continue
            # write out finished sample id
            write_finished_sample(options, sample)
            logging.info('sample: ' + sample + ' results transferred back')
            logging.info('sample: '+ sample + ' SUCCEEDED')
            # remove sample directory on nesi
            nesi_sample_rmdir(options, sample)
            logging.info('sample: ' + sample + ' nesi directory removed')
        else:
            failed_sample(options,sample,"FAILED - go and investigate")



def main():
    options = parse_arguments()
    options.pause = int(options.pause)

    logging.basicConfig(filename=options.logfile, level=logging.INFO, format= '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    (samples_dict,sample_header) = load_sample_info(options.sample_file)

    finished_samples = load_finished_samples(options.finished_file)

    samples_dict = exclude_samples(samples_dict, finished_samples)

    samples = get_samples(samples_dict)
    if(options.sample_id is not None):
        if(options.sample_id in samples):
            samples = options.sample_id
            # remove all other samples from sample_dict
            s = sample_dict[options.sample_id]
            sample_dict = {}
            sample_dict[options.sample_id] = s
        else:
            logging.info("Specified sample not in sample file")
            sys.exit()
    if(len(samples) == 0):
        logging.info('No samples to process')
        sys.exit()
    process_samples(options, samples_dict)

if __name__ == "__main__":
    main()


