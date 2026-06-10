# "Evaluación del perfil de expresión génica diferencial por bulk RNA-seq para identificar el papel de *MECOM* en el potencial de regeneración en organoides de retina."

>*10 Junio 2026*
>
> Proyecto Final

---

## Datos del equipo
Licenciatura en Ciencias Genómicas
* Martinez Cuevas Valeria - 8vo semestre
* Cabrera Rojas Valeria - 6to semestre

**Clase:** Bioinformática aplicada al análisis de transcriptómica diferencial


## Abstract
MECOM ha sido propuesto como un factor de transcripción involucrado en la regulación del potencial regenerativo de células madre neurales retinianas humanas. Con el objetivo de evaluar su función y reproducir los hallazgos reportados previamente, se realizó un análisis de expresión génica diferencial mediante *bulk RNA-seq* en organoides retinianos humanos, comparando muestras control tipo Wild Type con organoides con un knockout de *MECOM*.

El procesamiento de los datos incluyó la descarga de lecturas, evaluación de calidad mediante *FastQC* y *MultiQC*, corrección de errores con *Rcorrector*, filtrado y recorte de secuencias utilizando *Trimmomatic*, alineamiento al genoma de referencia con *STAR* y cuantificación de lecturas. El análisis de expresión diferencial se realizó con *DESeq2*, mientras que el enriquecimiento funcional se llevó a cabo mediante *clusterProfiler*.

Los resultados mostraron una clara separación entre las condiciones WT y *MECOM* KO, así como una reducción significativa en la expresión de *MECOM* en las muestras knockout. Además, se identificó una disminución en la expresión de genes asociados con el desarrollo y la función de la retina, incluyendo procesos relacionados con la percepción visual y la conservación de la identidad celular retinal. A diferencia de ello, los genes sobreexpresados en la condición knockout se asociaron principalmente con procesos de desarrollo embrionario, organización tisular y morfogénesis. Finalmente, los análisis de expresión diferencial y enriquecimiento funcional mostraron una alta relación con los resultados reportados en el estudio original.

En conjunto, los hallazgos obtenidos respaldan la hipótesis de que *MECOM* participa en la regulación de programas transcripcionales asociados con el desarrollo y mantenimiento de la retina, además demuestran la reproducibilidad de los principales resultados biológicos reportados para este modelo experimental.



## Reporte renderizado
-> https://valeriacab.github.io/RNA-Seq-Bulk-/


## Pipeline

El procesamiento y análisis de los datos de RNA-seq se llevó a cabo mediante el siguiente pipeline bioinformático:

<img width="1387" height="813" alt="pipeline" src="https://github.com/user-attachments/assets/bb15b80c-6940-46fe-bc04-ec4d588f6c8b" />


## Scripts

- [Descarga de datos SRA](scripts/01_download_sra.slurm)
- [FASTQC](scripts/02_fastqc_raw.slurm)
- [Corrección de errores - Trimming - FASTQC](scripts/03_04_05.slurm)
- [Alineamiento](scripts/06_aligment/)
- [Análisis de expresión diferencial y de enriquecimiento](scripts/07_08_DEG_Enriquecimiento.R)


### 1. Descargar los datos crudos de RNA-seq desde la base de datos SRA
   
> Datos tomados del paper: "Identificación y caracterización de células madre de la retina humana capaces de regeneración retiniana"
> 
> **NCBI Link:** <https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE279113>
>
> **Bioproject:** PRJNA1170898

**Objetivo:** Descaraga de datos crudos

**Script:** [Paso 1](scripts/01_download_sra.slurm)

**Herramienta:** WGET

**Descripción:** Usando *WGET* se descargaron dos archivos FASTQ comprimidos (.gz) por cada muestra (TOTAL = 6 muestras), estos archivos contienen las lecturas *paired-end unstranded* obtenidas por secuenciación mediante la plataforma Illumina HiSeq 4000, con  una profundidad de secuenciación aproximada de entre 20 y 30 millones de lecturas por muestra.

El estudio incluye un total de seis muestras biológicas, distribuidas en dos condiciones experimentales: 

| Caso | control |
|----------|:-------:|
| Organoides con knockout de MECOM (KO) | Organoides de retina tipo wild type (WT) |
|   3  |    3    |






## Infografia 



## Referencias
* Liu, H., Ma, Y., Gao, N., Zhou, Y., Li, G., Zhu, Q., Liu, X., Li, S., Deng, C., Chen, C., Yang, Y., Ren, Q., Hu, H., Cai, Y., Chen, M., Xue, Y., Zhang, K., Qu, J., & Su, J. (2025). Identification and characterization of human retinal stem cells capable of retinal regeneration. Science Translational Medicine, 17(791), eadp6864. https://doi.org/10.1126/scitranslmed.adp6864
* Analysis workflow. (s. f.). https://biocorecrg.github.io/RNAseq_course_2019/workflow.html
* Eldred, K. C., Edgerton, S. J., Ortuño-Lizarán, I., Wohlschlegel, J., Sherman, S. M., Petter, S., Wyatt-Draher, G., Hoffer, D., Glass, I., La Torre, A., & Reh, T. A. (2025). Ciliary marginal zone of the developing human retina maintains retinal progenitor cells until late gestational stages. Cell Reports, 44(4), 115460. https://doi.org/10.1016/j.celrep.2025.115460
* Mao, X., An, Q., Xi, H., Yang, X., Zhang, X., Yuan, S., Wang, J., Hu, Y., Liu, Q., & Fan, G. (2019). Single-Cell RNA Sequencing of hESC-Derived 3D Retinal Organoids Reveals Novel Genes Regulating RPC Commitment in Early Human Retinogenesis. Stem Cell Reports, 13(4), 747-760. https://doi.org/10.1016/j.stemcr.2019.08.012
* Zuo, Z., Cheng, X., Ferdous, S., Shao, J., Li, J., Bao, Y., Li, J., Lu, J., Lopez, A. J., Wohlschlegel, J., Prieve, A., Thomas, M. G., Reh, T. A., Li, Y., Moshiri, A., & Chen, R. (2024). Single cell dual-omic atlas of the human developing retina. Nature Communications, 15(1), 6792. https://doi.org/10.1038/s41467-024-50853-5





