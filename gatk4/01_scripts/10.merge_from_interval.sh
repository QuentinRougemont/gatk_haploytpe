#!/bin/bash

#script to merge results from intervals for each pop or for a single vcf.

#external paramaeters
if [ $# -ne 1 ]; then
        echo "Error"
        echo "Expecting one variable on the command line"
        echo "This must be a one column file containing the list of all population for which each vcf will be process"
        echo "each population name is on a single line"
else
        #Using values from the command line
        list_pop=$1   
        echo "pop=$list_pop"
fi
mkdir 14-list_variants_files
ls -v 10-genoGVCF_2/*vcf.gz > 14-list_variants_files/${pop}.variant_files.list 
#GLOBAL VARIABLE FOR WRITING THE SCRIPT
DATAFOLDER="/rap/ihv-653-ab/quentin/14.epic4"
LISTFOLDER="14-list_variants_files" 
OUTFOLDER="15-pop_vcf"
mkdir $OUTFOLDER 2>/dev/null
mkdir tmp_MERGE_scripts 2>/dev/null

cd ./tmp_MERGE_scripts
cp ../$list_pop .

for pop in $(cat ${list_pop} ) ; do
    echo "#!/bin/bash" > lanceur_vcf_MERGE.$pop.sh
    echo "#PBS -A ihv-653-aa" >> lanceur_vcf_MERGE.$pop.sh
    echo "#PBS -N gatk #__LIST__" >> lanceur_vcf_MERGE.$pop.sh
    echo "#PBS -l walltime=48:00:00" >> lanceur_vcf_MERGE.$pop.sh
    echo "#PBS -l nodes=1:ppn=8" >> lanceur_vcf_MERGE.$pop.sh
    echo "#PBS -r n" >> lanceur_vcf_MERGE.$pop.sh
    echo "# Move to job submission directory" >> lanceur_vcf_MERGE.$pop.sh
    echo -e "cd \$PBS_O_WORKDIR" >> lanceur_vcf_MERGE.$pop.sh
    echo "source /clumeq/bin/enable_cc_cvmfs" >> lanceur_vcf_MERGE.$pop.sh
    echo "module load gatk/4.1.2.0" >> lanceur_vcf_MERGE.$pop.sh
    echo "module load picard/2.20.6" >> lanceur_vcf_MERGE.$pop.sh
    echo " " >> lanceur_vcf_MERGE.$pop.sh
    echo "#merging pop ${pop} " >> lanceur_vcf_MERGE.$pop.sh
    echo -e "java -jar \$EBROOTPICARD/picard.jar \\" >> lanceur_vcf_MERGE.$pop.sh
    echo "    MergeVcfs \\" >> lanceur_vcf_MERGE.$pop.sh
    echo "    I=${DATAFOLDER}/${LISTFOLDER}/${pop}.variant_files.list \\" >> lanceur_vcf_MERGE.$pop.sh
    echo "    O=${DATAFOLDER}/${OUTFOLDER}/${pop}.vcf.gz  " >> lanceur_vcf_MERGE.$pop.sh

done 
