#!/bin/bash
#SBATCH -J "coho"
#SBATCH -o log_%j
#SBATCH -c 1
#SBATCH -p medium
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=YOUREMAIL
#SBATCH --time=06-00:00
#SBATCH --mem=20G

# Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

#########################################################
#last update: 10-05-2019
#SCRIPT TO RUN HaplotypeCaller from gatkv4.0.9 in GVCF mode
#INPUT: 1 bam file per individual
#INPUT: fasta file (reference genome)
#OUTPUT : 1 vcf file per individual
########################################################

#Global variables
file=$1 #name of the bam file 
if [ -z "$file" ]
then
    echo "Error: need bam name (eg: sample1.bam)"
    exit
fi

#load module (on beluga only)
#module load java
#module load gatk/4.1.0.0
name=$(basename $file)
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
LOG_FOLDER="99-log_files"
SCRIPT=$0
NAME=$(basename $0)
#cp $SCRIPT $LOG_FOLDER/"$TIMESTAMP"_"$NAME"

OUTFOLDER="10-gatk_GVCF" 
if [ ! -d "$OUTFOLDER" ]
then 
    echo "creating out-dir"
    mkdir "$OUTFOLDER"
fi

#PATH TO ref genome:
file_path=$(pwd)
REF="$file_path/03_genome/GCF_002021735.1_Okis_V1_genomic.fasta"
if [ -z $REF ];
then
    echo "error please provide reference fasta"
    exit
fi
################## run gatk ########################################
echo "#####"
echo "Running GATK for file $name "
echo "######"
java -jar /home/qurou/software/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar \
	-T HaplotypeCaller \
        -R "$REF" \
	-nct 16\
        -I "$file_path"/09_no_overlap/"$name" \
	-ERC GVCF \
	-hets 0.015 \
	-variant_index_type LINEAR -variant_index_parameter 128000\
	-indelHeterozygosity 0.01 \
	-o "$file_path"/gatk38/"$OUTFOLDER"/"${name%.no_overlap.bam}".vcf.gz \
