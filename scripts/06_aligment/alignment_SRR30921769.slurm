#!/bin/bash
# Run job through bash shell
#
# Your job name
#SBATCH -J index_star
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
module load star/2.7.9a

# here.
#
#SBATCH -p node
#SBATCH --cpus-per-task=16
#SBATCH --mem=32G
#SBATCH --time=72:00:00
##
# Write your commands in the next line

cd /mnt/data/transcriptomica/vmartinez/proyecto_final/06_alignment_and_counts

STAR \
--genomeDir /mnt/data/transcriptomica/vmartinez/proyecto_final/index_star \
--readFilesIn /mnt/data/transcriptomica/vmartinez/proyecto_final/04_trimmomatic/SRR30921769_1.paired.fastq.gz /mnt/data/transcriptomica/vmartinez/proyecto_final/04_trimmomatic/SRR30921769_2.paired.fastq.gz \
--outFileNamePrefix SRR30921769_ \
--outSAMtype BAM SortedByCoordinate \
--quantMode GeneCounts \
--readFilesCommand zcat
