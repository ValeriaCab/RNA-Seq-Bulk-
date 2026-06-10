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

