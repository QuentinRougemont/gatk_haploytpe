#!/bin/bash
#SBATCH --account=def-blouis
#SBATCH --time=06:00:00
#SBATCH --job-name=ldhat
#SBATCH --output=genot-%J.out
##SBATCH --array=1-33%33
#SBATCH --mem=125G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
##SBATCH --gres=cpu:32
##SBATCH --mail-user=yourmail
##PBS -l nodes=1:ppn=8
##SBATCH --mail-type=EA 

# Move to directory where job was submitted
#cd $SLURM_SUBMIT_DIR

NCPUS=30

input=$1 #ls 10-gatk_parallel/*gz > inputlist 
#input should be the list of all g.vcf 

cat $input |\
    parallel -j $NCPUS ./09_genotype_iteration.sh {} 

