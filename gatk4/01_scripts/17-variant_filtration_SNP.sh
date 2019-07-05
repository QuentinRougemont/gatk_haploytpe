#!/bin/bash
#SBATCH -J "big_filtration"
#SBATCH -o log_%j
#SBATCH -c 1
#SBATCH -p large
##ATCH -A large
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=YOUREMAIL
#SBATCH --time=08-00:00
#SBATCH --mem=30G

# Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

#########################################################
########################################################
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
LOG_FOLDER="99-log_files"
SCRIPT=$0
NAME=$(basename $0)
cp "$SCRIPT" "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME"

#Global variables
file=13-snp_GVCF/GVCFall_SNPs.vcf.gz #~$1 #name of the bam file 
if [ -z "$file" ]
then
    echo "Error: need vcf "
    exit
fi

name=$(basename $file)

OUTFOLDER="15-snp_filter"
if [ ! -d "OUTFOLDER" ]
then 
    echo "creating out-dir"
    mkdir "$OUTFOLDER"
fi
ROAD=$(pwd)
REF="${ROAD}/03_genome/GCF_002021735.1_Okis_V1_genomic.fasta" 
################## run gatk ########################################
gatk --java-options "-Xmx57G" \
 	 VariantFiltration \
	-R "$REF" \
	-O "$OUTFOLDER"/"${name%.vcf.gz}".filter.vcf.gz \
	-V "$ROAD"/"$file" \
	--filterExpression "QUAL < 0 || MQ < 30.00 || SOR > 4.000 || QD < 2.00 || FS > 60.000 || MQRankSum < -20.000 || ReadPosRankSum < -10.000 || ReadPosRankSum > 10.000" \
	--filterName "snp_filtration" 
	
gunzip "$OUTFOLDER"/"${name%.vcf.gz}".filter.vcf.gz | \
	grep -E '^#|PASS'  > "$OUTFOLDER"/"${name%.vcf.gz}".filterPASSED.vcf
gzip "$OUTFOLDER"/"${name%.vcf.gz}".filterPASSED.vcf

