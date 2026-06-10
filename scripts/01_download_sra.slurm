#!/bin/bash
#SBATCH --job-name=sra_download
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=sra_%j.log
#SBATCH --error=sra_%j.err

# Lista de SRR IDs
#GSE279113
#
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR309/074/SRR30921774/SRR30921774_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR309/074/SRR30921774/SRR30921774_2.fastq.gz
#
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR309/070/SRR30921770/SRR30921770_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR309/070/SRR30921770/SRR30921770_2.fastq.gz
#
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR309/071/SRR30921771/SRR30921771_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR309/071/SRR30921771/SRR30921771_2.fastq.gz
#
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR309/069/SRR30921769/SRR30921769_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR309/069/SRR30921769/SRR30921769_2.fastq.gz
#
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR309/072/SRR30921772/SRR30921772_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR309/072/SRR30921772/SRR30921772_2.fastq.gz
#
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR309/073/SRR30921773/SRR30921773_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR309/073/SRR30921773/SRR30921773_2.fastq.gz
