#!/bin/bash
# Run job through bash shell
#
# Your job name
#SBATCH -J rna_full
#
# Use current working directory
#SBATCH --chdir=./
#
#stdout and stderr
#SBATCH --output=%x.o%j
#
# Send an email after the job has finished
#SBATCH --mail-user=valery2602v.rod@gmail.com
#SBATCH --mail-type=END
#
# If modules are needed, source modules environment (Do not delete the next line):
. /etc/profile.d/modules.sh
#
# Add any modules you might require:
module load fastqc/0.11.3
module load subread/1.6.2
module load trimmomatic/0.33
#
# here.
#
#SBATCH -p node
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=72:00:00
##
# Write your commands in the next line
##############################################################################
# DIRECTORIES
##############################################################################

RAW_DIR="/mnt/data/transcriptomica/vmartinez/proyecto_final/01_download_data"

RCORRECTOR_DIR="/mnt/data/transcriptomica/vmartinez/proyecto_final/02_rcorrector"

TRIM_DIR="/mnt/data/transcriptomica/vmartinez/proyecto_final/03_trimmomatic"

FASTQC_TRIM_DIR="/mnt/data/transcriptomica/vmartinez/proyecto_final/04_fastqc_trimmed"

mkdir -p ${RCORRECTOR_DIR}
mkdir -p ${TRIM_DIR}
mkdir -p ${FASTQC_TRIM_DIR}

##############################################################################
# ADAPTERS
##############################################################################

ADAPTERS="/mnt/data/transcriptomica/database/TruSeq3-PE.fa"

##############################################################################
# SAMPLES
##############################################################################

samples=(
SRR30921769
SRR30921770
SRR30921771
SRR30921772
SRR30921773
SRR30921774
)

##############################################################################
# STEP 1 — RCORRECTOR
##############################################################################

echo "==============================="
echo "STEP 1 — RCORRECTOR"
echo "==============================="

source /home/wgutierrez/miniconda3/etc/profile.d/conda.sh
conda activate rcorrector_env

echo "Using jellyfish:"
which jellyfish

R1_FILES=""
R2_FILES=""

for sample in "${samples[@]}"
do

R1_FILES+="${RAW_DIR}/${sample}_1.fastq,"
R2_FILES+="${RAW_DIR}/${sample}_2.fastq,"

done

R1_FILES=${R1_FILES%,}
R2_FILES=${R2_FILES%,}

perl /mnt/data/transcriptomica/database/Rcorrector-1.0.5/run_rcorrector.pl \
-t 16 \
-1 ${R1_FILES} \
-2 ${R2_FILES}

mv *.cor.fq ${RCORRECTOR_DIR}/

##############################################################################
# FILTER UNCORRECTABLE READS
##############################################################################

echo "==============================="
echo "FILTERING UNCORRECTABLE READS"
echo "==============================="

for sample in "${samples[@]}"
do

echo "Filtering ${sample}"

python /mnt/data/transcriptomica/database/TranscriptomeAssemblyTools/FilterUncorrectabledPEfastq.py \
-1 ${RCORRECTOR_DIR}/${sample}_1.cor.fq \
-2 ${RCORRECTOR_DIR}/${sample}_2.cor.fq \
-s ${RCORRECTOR_DIR}

done

conda deactivate

##############################################################################
# STEP 2 — TRIMMOMATIC
##############################################################################

echo "==============================="
echo "STEP 2 — TRIMMOMATIC"
echo "==============================="

for sample in "${samples[@]}"
do

echo "Running Trimmomatic for ${sample}"

trimmomatic PE \
-threads 16 \
${RCORRECTOR_DIR}/${sample}_1.cor.fq \
${RCORRECTOR_DIR}/${sample}_2.cor.fq \
${TRIM_DIR}/${sample}_1.paired.fastq.gz \
${TRIM_DIR}/${sample}_1.unpaired.fastq.gz \
${TRIM_DIR}/${sample}_2.paired.fastq.gz \
${TRIM_DIR}/${sample}_2.unpaired.fastq.gz \
ILLUMINACLIP:${ADAPTERS}:2:30:10 \
LEADING:3 \
TRAILING:3 \
SLIDINGWINDOW:4:25 \
MINLEN:50 \
HEADCROP:10

done

##############################################################################
# STEP 3 — FASTQC TRIMMED
##############################################################################

echo "==============================="
echo "STEP 3 — FASTQC TRIMMED"
echo "==============================="

for sample in "${samples[@]}"
do

echo "Running FastQC trimmed for ${sample}"

fastqc -t 8 \
${TRIM_DIR}/${sample}_1.paired.fastq.gz \
${TRIM_DIR}/${sample}_2.paired.fastq.gz \
-o ${FASTQC_TRIM_DIR}

done

