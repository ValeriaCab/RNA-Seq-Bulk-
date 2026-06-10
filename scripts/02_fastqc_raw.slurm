#!/bin/bash
# Run job through bash shell
#
# Your job name
#SBATCH -J fastqc_raw
#
# Use current working directory
#SBATCH --chdir=./
#
# stdout and stderr
#SBATCH --output=%x.o%j
#
# Send an email after the job has finished
#SBATCH --mail-user=valery2602v@gmail.com
#SBATCH --mail-type=END
#
# Load modules environment
. /etc/profile.d/modules.sh
#
# Modules
module load fastqc/0.11.3
#
#SBATCH -p node
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=72:00:00


#------------- 1.Directories --------------

INPUT_DIR="/mnt/data/transcriptomica/vmartinez/proyecto_final/01_download_data"
OUTPUT_DIR="/mnt/data/transcriptomica/vmartinez/proyecto_final/02_fastqc_raw"

# Create output directory if it doesn't exist
mkdir -p ${OUTPUT_DIR}

#-------------- 2.Sample IDs --------------

samples=(
SRR30921769
SRR30921770
SRR30921771
SRR30921772
SRR30921773
SRR30921774
)

#-------------- 3.Run FastQC --------------

for sample in "${samples[@]}"
do

    echo "Processing ${sample}"

    fastqc \
        ${INPUT_DIR}/${sample}_1.fastq.gz \
        ${INPUT_DIR}/${sample}_2.fastq.gz \
        --outdir ${OUTPUT_DIR} \
        --threads 8

done

echo "FastQC finished"
