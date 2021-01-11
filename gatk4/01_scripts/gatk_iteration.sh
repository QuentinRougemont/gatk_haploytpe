#!/bin/bash

## GLOBAL VARIABLE
id=$[ $1  ]
intervals=chr_"$id".intervals 
echo "id is : $id"
file=$2 #name of the bam file 
echo "file is $file"
name=$(basename $file)

## FICHIER
OUTFOLDER="10-gatk_parallel"
if [ ! -d "$OUTFOLDER" ]
then 
    echo "creating out-dir"
    mkdir "$OUTFOLDER"
fi

file_path=$(pwd)

## GENOME
REF="$file_path/03_genome/GCF_002021735.2_Okis_V2_genomic.fna"

## GATK
################## run gatk ########################################
echo "Running GATK for file $name "
gatk  \
    HaplotypeCaller \
    -R "$REF" \
    -I "$file_path"/"$file" \
    -ERC GVCF \
    --heterozygosity 0.0015 \
    --indel-heterozygosity 0.001 \
    --intervals "$file_path"/INTERVAL/$intervals \
    -O "$file_path"/"$OUTFOLDER"/"${name%.dedup.bam}".$intervals.g.vcf.gz 
