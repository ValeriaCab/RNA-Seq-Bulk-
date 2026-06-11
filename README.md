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

[Artículo original](https://doi.org/10.1126/scitranslmed.adp6864)

## Reporte renderizado
En la siguiente página se presenta una descripción detallada de la motivación del proyecto, la obtención y procesamiento de los datos, la metodología empleada en el análisis, los resultados obtenidos, su comparación con los reportados en el estudio original y una discusión de las principales observaciones y hallazgos.

-> [Reporte de análisis RNA-seq Bulk](https://valeriacab.github.io/RNA-Seq-Bulk-/)


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
   
> Datos tomados del paper: "Identificación y caracterización de células madre de la retina humana capaces de regeneración retiniana" [link](https://doi.org/10.1126/scitranslmed.adp6864)
> 
> **NCBI Link:** <https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE279113>
>
> **Bioproject:** PRJNA1170898

**Objetivo:** Descaraga de datos crudos

**Script:** [Paso 1](scripts/01_download_sra.slurm)

**Log:** [Paso 1](logs/Download_data.zip)


**Herramienta:** WGET

**Descripción:** Usando *WGET* se descargaron dos archivos FASTQ comprimidos (.gz) por cada muestra (TOTAL = 6 muestras), estos archivos contienen las lecturas *paired-end unstranded* obtenidas por secuenciación mediante la plataforma Illumina HiSeq 4000, con  una profundidad de secuenciación aproximada de entre 20 y 30 millones de lecturas por muestra.

El estudio incluye un total de seis muestras biológicas, distribuidas en dos condiciones experimentales: 

| Caso | control |
|----------|:-------:|
| Organoides con knockout de MECOM (KO) | Organoides de retina tipo wild type (WT) |
|   3  |    3    |


### 2. Control de calidad inicial (FASTQC)

**Objetivo:** Evaluar el control de calidad incial de las lecturas crudas obtenidas de la secuenciación.

**Script:** [Paso 2](scripts/02_fastqc_raw.slurm)

**Herramienta:** FastQC

**Descripción:** Posterior a la descarga de datos, se realia un control de calidad de las lecturas para detectar posibles problemas como adaptadores, baja calidad de la secuenciación, entre otros aspectos importantes. ESta herramienta, toma cada lectura (las 2 de cada muestra) y evalúa la calidad por posición de base, contenido de GC, secuencias duplicadas, adaptadores, longitu de lecturas y sobre-representación de secuencias.

Antes de alinear las lecturas, es importante que tengan uena calidad para no introducir ruido o sesgos a los siguientes análisis.

### 3, 4, 5. Corrección de errores, Trimming, FASTQC

**Objetivo:**: Corrección de errores en lecturas, fitrado de lecturas no corregibles, recorte y limpieza de lecturas y evaluación de calidad posterior al alineamiento.

**Script:** [Paso 3,4 y 5](scripts/03_04_05.slurm)

**Herramientas:** Rcorrector, FilterUncorrectabledPEfastq.py, TRimmomatic, FASTQC

Se analizaron las lecturas utilizando Rcorrector, el cual trabaja con las frecuencias de k-mers para identificar y corregir errores de secuenciación antes del alineamiento, de esta forma genera archivos .cor.fq con las lecturas corregidas. Posteriormente, se identificaron y eliminaron las lecturas marcadas como no corregibles para despues ser filtradas y procesadas con Trimmomatic, eliminando secuencias adaptadoras TruSeq y recortando bases de baja calidad. Además, se aplicó una ventana deslizante para controlar la calidad promedio de las lecturas y se descartaron las que tenían una longitud final inferior a 50 pb. Los parámetros utilizados fueron:

| Parámetro | Valor | Función |
|----------|:-------:|:-------:|
| ILUMINACLIP| TruSeq3-PE.fa:2:30:10 | Elimina adaptadores de Illumina |
|   LEADING  |    3    | Elimina bases al inicio de cada lectura con calidad menor a 3 |
| TRAILING   |    3    | Elimina bases al final de cada lectura con calidad menor a 3 |
| SLIDINGWINDOW |  4:25 | Evalúa ventanas de 4 bases y corta cuando la calidad promedio está por debajo de 25 |
| MINLEN     |   50     |  Descarta lecturas con longitud final menor a 50 pb |
| HEADCROP   |   10     |  Elimina las primeras 10 bases de cada lectura |


### 6. Alineamiento 

**Objetivo:** Alinear las lecturas al genoma humano de referencia y cuantificar la expresión génica.

**Script:** [Paso 6](scripts/06_aligment/)

**Herramienta:** STAR v2.7.9a

Una vez que las lecturas ya pasaron por el control de calidad y correción, se tienen millones de ellas, por lo que es necesario identificar de que gen proviene cada una. Para ello, las lecturas en formato FASTQ fueron alineadas al genoma de referencia GRCh38, para determinar la posición de esa lectura en el cromosoma en que se alineó. De este prceso se generarn archivos BAM ordenados por coordenadas genómicas. Adicionalmente, se utilizó la opción --quantMode GeneCounts para obtener conteos de lecturas por gen, los cuales fueron empleados posteriormente en el análisis de expresión diferencial mediante DESeq2.

### 7, 8. Análisis de expresión diferencial y análisis de enriquecimiento funcional 

**Objetivo:** El análisis de expresión diferencial busca identificar genes donde la expresión cambia significativamente entre MECOM KO y control. Mientras que, el análisis de enriquecimiento funcional trata de identificar que procesos biológicos están sobrerrepresentados entre los genes diferencialmente expresados.

**Script:** [Paso 7 y 8](scripts/07_08_DEG_Enriquecimiento.R)

**Herramientas:** DESeq 2 y clusterProfiler (GO y GSEA)

Los conteos obtenidos a partir de STAR fueron utilizados para construir una matriz de expresión, la cual fue analizada mediante el paquete DESeq2 en R. Primero, se eliminaron los genes con baja expresión, conservando únicamente aquellos que presentaban al menos 10 lecturas en un mínimo de tres muestras. Posteriormente, los conteos fueron normalizados y se ajustó para comparar las condiciones MECOM_KO y control. Los genes diferencialmente expresados se identificaron utilizando un valor de p ajustado (padj < 0.05) y un cambio de expresión absoluto mayor a dos veces (|log₂FoldChange| > 1). Finalmente, los identificadores de Ensembl fueron anotados con información funcional y simbología génica empleando la base de datos org.Hs.eg.db.

A lo largo de este paso, creamos imagenes para visulizar estos análisis. 

En terminos generales, se siguió el presente pipeline y se utilizaron las herramientas descritas para reproducir un análisis de RNA-seq bulk. Para obtener una descripción más detallada de los scripts, la visualización de los resultados y su discusión biológica, se recomienda consultar el reporte de análisis: [Reporte de análisis RNA-seq Bulk](https://valeriacab.github.io/RNA-Seq-Bulk-/)



## Infografia 
<img width="800" height="2000" alt="Infografía - RNA-seq Bulk Workflow(1)" src="https://github.com/user-attachments/assets/67c41a42-56af-44ea-bdce-6dce49687106" />




## Referencias
* Liu, H., Ma, Y., Gao, N., Zhou, Y., Li, G., Zhu, Q., Liu, X., Li, S., Deng, C., Chen, C., Yang, Y., Ren, Q., Hu, H., Cai, Y., Chen, M., Xue, Y., Zhang, K., Qu, J., & Su, J. (2025). Identification and characterization of human retinal stem cells capable of retinal regeneration. Science Translational Medicine, 17(791), eadp6864. https://doi.org/10.1126/scitranslmed.adp6864
* Analysis workflow. (s. f.). https://biocorecrg.github.io/RNAseq_course_2019/workflow.html
* Eldred, K. C., Edgerton, S. J., Ortuño-Lizarán, I., Wohlschlegel, J., Sherman, S. M., Petter, S., Wyatt-Draher, G., Hoffer, D., Glass, I., La Torre, A., & Reh, T. A. (2025). Ciliary marginal zone of the developing human retina maintains retinal progenitor cells until late gestational stages. Cell Reports, 44(4), 115460. https://doi.org/10.1016/j.celrep.2025.115460
* Mao, X., An, Q., Xi, H., Yang, X., Zhang, X., Yuan, S., Wang, J., Hu, Y., Liu, Q., & Fan, G. (2019). Single-Cell RNA Sequencing of hESC-Derived 3D Retinal Organoids Reveals Novel Genes Regulating RPC Commitment in Early Human Retinogenesis. Stem Cell Reports, 13(4), 747-760. https://doi.org/10.1016/j.stemcr.2019.08.012
* Zuo, Z., Cheng, X., Ferdous, S., Shao, J., Li, J., Bao, Y., Li, J., Lu, J., Lopez, A. J., Wohlschlegel, J., Prieve, A., Thomas, M. G., Reh, T. A., Li, Y., Moshiri, A., & Chen, R. (2024). Single cell dual-omic atlas of the human developing retina. Nature Communications, 15(1), 6792. https://doi.org/10.1038/s41467-024-50853-5





