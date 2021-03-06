#!/bin/bash

#script to realign indels
#########################################################
#WARNINGS: THESE TWO STEPS BELOWs ARE NO LONGER NECESARRY WITH HaplotyCaller but requirer with UnifiedGenotyper
bam=$1
if [ $# -eq 0 ]
then
        echo "error need bam file"
	echo "bam should be in 06_deduplicated folder"
        exit
fi

# Global variables
GATK="/home/qurou/software/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar"
REALIGNFOLDER="07_realigned"
GENOMEFOLDER="02_genome"
GENOME="GCF_002021735.1_Okis_V1_genomic.fasta"

# Load needed modules
module load java/jdk/1.8.0_102

# Copy script to log folder
TIMESTAMP=$(date +%Y-%m-%d_%Hh%Mm%Ss)
SCRIPT=$0
NAME=$(basename $0)
LOG_FOLDER="99_log_files"
cp "$SCRIPT" "$LOG_FOLDER"/"$TIMESTAMP"_"$NAME"

# Realign around target previously identified
for file in "$bam" 
do
java -Xmx8g -jar $GATK\
        -T RealignerTargetCreator \
	-nct 16 \
        -R "$GENOMEFOLDER"/"$GENOME" \
        -I "$file" \
        -o "${file%.dedup.bam}".intervals
	-log "${file%.dedup.bam}".log 
done

for file in "$bam"
do
    java -jar $GATK \
        -T IndelRealigner \
        -R "$GENOMEFOLDER"/"$GENOME" \
        -I "$file" \
        -targetIntervals "${file%.dedup.bam}".intervals \
        --consensusDeterminationModel USE_READS  \
        -o "$REALIGNFOLDER"/$(basename "$file" .dedup.bam).realigned.bam
done
