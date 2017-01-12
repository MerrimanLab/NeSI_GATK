### Mergeing of summary files for IDs to create a table to use for Read Groups
if(!require(XML)){install.packages("XML"); require(XML)} 

#### if the above doesn't work, run the following in the terminal for ubuntu
#### sudo apt-get install r-cran-xml

##### set up functions to do parts of the work

### function for generic reading of tables, colclasses read as character vectors and can be corrected in the final table
table.reader <- function(batch,x){
  dir <- paste0("/media/otago_hsc/KCCG-Data/R_151102_MANPHI_FGS_",batch,"/")
  if(!require(XML)){install.packages("XML"); require(XML)} 
  tables <- getNodeSet(htmlParse(paste0(dir,"SequencingProjectReport.html")), "//table") # Read and grab ALL tables
  U <- readHTMLTable(tables[[x]], trim = TRUE, stringsAsFactors = FALSE,colnames=1) # Select the correct table
  Z <- colnames(U)
  Z <- gsub(" |\n|%|>=|<=|\\(|\\)","",Z)
  colnames(U) <- Z
  U <- U[,2:ncol(U)] # remove the 1st column
  return(U)
}

### function to merge TWO tables by all replicated columns
merge.all <- function(x,y){
  U <- colnames(x)[which(colnames(x)%in%colnames(y))]
  merge(x,y,by=U)
}

### function to return ALL the duplicated samples including the 1st instance of it
all.duplicated <- function(x){duplicated(x)|duplicated(x,fromLast=T)}

###  read group information to look like this, a tab delimited parameter file
###  RG="@RG\tID:group1\tSM:${sample}\tPL:illumina\tLB:lib1\tPU:unit1"

read.group <- function(batch,samples=20){
  ## table 3 contains the IDs
  doc.id <- table.reader(batch,3)
  ## table 6 contains the samples and lane information
  doc.lanes <- table.reader(batch,6)
  ## table 7 contains the samples and lane information
  doc.lanequal  <- table.reader(batch,7)
  ## table 8 contains the poor quality read information information
  doc.excluded  <- table.reader(batch,8)
  ## table 9 contains the proportional coverage information
  doc.coverage  <- table.reader(batch,9)
  
  doc.final.lane <- merge.all(doc.lanes,doc.id)
  doc.final.lane <- merge.all(doc.final.lane,doc.lanequal)
  doc.final.lane <- merge.all(doc.final.lane,doc.excluded)
  doc.final.lane <- merge.all(doc.final.lane,doc.coverage)
  
  ## get the duplicate lanes to remove from final, align later
  multiple.lanes <- doc.final.lane[all.duplicated(doc.final.lane$SampleID),]
  if(dim(multiple.lanes)[1]>0){
    doc.final.lane <- doc.final.lane[-which(doc.final.lane$SampleID%in%multiple.lanes$SampleID),]
    write.table(multiple.lanes,file=paste0(outdir,"multiples",batch,".txt"),col.names = T,row.names = F,quote = F,sep=" ")
  }

  doc.final.lane$Batch <- batch
  doc.rg <- data.frame(ID=doc.final.lane$IUS,SM=doc.final.lane$ExternalID,PL="ILLUMINA",LB=batch,PU=doc.final.lane$Lane)
  RG <- paste0("@RG\\tID:",doc.final.lane$IUS,"\\tSM:",doc.final.lane$ExternalID,"\\tPL:ILLUMINA\\tLB:",batch,"\\tPU:",doc.final.lane$Lane) 
 
  submit <- data.frame(sample=doc.final.lane$ExternalID,RG=RG,
                       internal=doc.final.lane$SampleID,
                       file1=paste0(doc.final.lane$IUS,"_R1.fastq.gz"),file2=paste0(doc.final.lane$IUS,"_R2.fastq.gz"))
  
  #### split it up
  N <- floor(nrow(submit)/samples)
  bins <- rep_len(1:N,nrow(submit))             
  x <- split(submit, bins)
  
  ###write out the files
  for (i in 1:N){
    write.table(x[[i]],file=paste0(outdir,batch,"_",i,".txt"),col.names = T,row.names = F,quote = F,sep=" ")
  }
 return(submit)
}


#################################################################################
######## end of functions

# Example run with the output directory, batch 7 and ~30 samples per file

#source("Readgroup.R")
#outdir <- "~/GIT_Repos/NeSI_GATK/SampleFiles/"
#read.group("M007",30)





