#-----------------------------------------------
# 01. package loading
#-----------------------------------------------
library(DESeq2)
library(ComplexHeatmap)
library(ggplot2)
library(pheatmap)
library(RNAseqQC)
library(ensembldb)
library(dplyr)
library(purrr)
library(magrittr)
library(EnhancedVolcano)
library(RColorBrewer)
library(AnnotationDbi)
library(tidyr)
library(tibble)
library(rnaseqGene)
library(stringr)
library(apeglm)
library(limma)
library(vegan)
library(SummarizedExperiment)
library(ggplot2)
library(pheatmap)
library(dplyr) 
library(ggrepel)
library(org.Hs.eg.db)
#-----------------------------------------------
# 02. Configuración de directorio
#----------------------------------------------

directory <- "/home/user/Documents/octavo_semestre/Transcriptomica/proyecto_final1/counts"
setwd(directory)
sampleFiles <- list.files(directory, pattern="*.out.tab")

# ------------------------------------------------
# leer todos los archivos
# ------------------------------------------------
count_list <- lapply(sampleFiles, function(file){
  
  # leer archivo STAR
  df <- read.delim(
    file,
    header = FALSE,
    skip = 4
  )
  
  # extraer nombre SRR
  sample_name <- sub(
    "alignment_(SRR[0-9]+)_ReadsPerGene.out.tab",
    "\\1",
    basename(file)
  )
  
  # quedarnos con GeneID + columna 2 (unstranded)
  counts_df <- data.frame(
    Geneid = df$V1,
    counts = df$V2
  )
  
  # renombrar columna de conteos
  colnames(counts_df)[2] <- sample_name
  
  return(counts_df)
})

#unir muestras 
count_table <- Reduce(function(x, y){
  
  full_join(x, y, by = "Geneid")
  
}, count_list)

#Pasar a matriz 
rownames(count_table) <- count_table$Geneid

count_table <- count_table[, -1]

count_matrix <- as.matrix(count_table)

mode(count_matrix) <- "integer" 


#Sample table 
# Leer sample table 
sampletable <- read.csv("/home/user/Documents/octavo_semestre/Transcriptomica/proyecto_final1/DEA/sample_table.csv")
sampletable$condition <- as.factor(sampletable$condition) 
rownames(sampletable) <- sampletable$sample
#Construir objeto dds 
dds <- DESeqDataSetFromMatrix(
  countData = count_matrix,
  colData = sampletable,
  design = ~ condition
)  


#Quitar genes con menos de 10 cuentas 
smallestGroupSize <- 3
keep <- rowSums(counts(dds) >= 10) >= smallestGroupSize
dds <- dds[keep,]
dds

# Definir referencia 
dds$condition <- relevel(dds$condition, ref = "control") 
any(is.na(dds$control))
any(is.na(dds$MECOM_KO))

#Exploramos datos 
head(assay(dds), 3)
colSums(assay(dds)) 

#Deseq
dds <- DESeq(dds)

#Resultados de deseq2 
res <- results(dds)
res

resultsNames(dds)
head(res)

res<-res[order(res$padj),]
head(res,20)
dim(res)
rownames(res)

summary(res)

#exploring results by adjust pvalue
#number of genes with padj < 0.1
sum(res$padj <0.1, na.rm= T)  
#number of genes with padj < 0.05
sum(res$padj <0.05, na.rm= T)  
#number of genes with padj < 0.05  and abs(res$log2FoldChange) > 1
sum(res$padj <0.05 & abs(res$log2FoldChange) > 1, na.rm= T)

# Upregulated
sum(res$padj < 0.05 & res$log2FoldChange > 1, na.rm = TRUE)

# Downregulated
sum(res$padj < 0.05 & res$log2FoldChange < -1, na.rm = TRUE)

# Anotar resultados 
deseq_Results<-res 
head(deseq_Results)
row.names(deseq_Results)

columns(org.Hs.eg.db) 

deseq_Results$symbol <- mapIds(org.Hs.eg.db, keys=row.names(deseq_Results),column="SYMBOL", keytype="ENSEMBL", multiVals="first")
deseq_Results$entrez_id <- mapIds(org.Hs.eg.db, keys=row.names(deseq_Results),column="ENTREZID", keytype="ENSEMBL", multiVals="first")
deseq_Results$entrez <- mapIds(org.Hs.eg.db, keys=row.names(deseq_Results), column="GENENAME",keytype="ENSEMBL",multiVals="first")
deseq_Results$go <- mapIds(org.Hs.eg.db, keys=row.names(deseq_Results), column="GO",keytype="ENSEMBL",multiVals="first")
deseq_Results$path <- mapIds(org.Hs.eg.db, keys=row.names(deseq_Results), column="PATH",keytype="ENSEMBL",multiVals="first")

Sort <- deseq_Results[order(deseq_Results$padj),]
head(Sort, 10)  

# write.csv(Sort, file= "/home/user/Documents/octavo_semestre/Transcriptomica/proyecto_final1/DEA/outputs/DEA_MECOM_KO_vs_control.csv")

# # Filtrar genes significativos
# res <- read.csv("/home/user/Documents/octavo_semestre/Transcriptomica/proyecto_final1/DEA/outputs/DEA_MECOM_KO_vs_control.csv", header = TRUE)
# genes_sig <- res[res$padj < 0.05 & abs(res$log2FoldChange) > 1, ]
# 
# # Ver cuántos son
# nrow(genes_sig)
# 
# write.csv(as.data.frame(genes_sig),
          # file = "/home/user/Documents/octavo_semestre/Transcriptomica/proyecto_final1/DEA/outputs/genes_diferencialmente_expresados.csv",
#           row.names = TRUE)

#----10 graphs after differential expression----
#boxplot
cm = data.frame(counts(dds, normalized = T))
cm
boxplot(cm)

#MAplot 
DESeq2::plotMA(dds,
               alpha=0.05,
               main= "MECOM_KO vs control",
               xlab= "mean of normalized counts",
               returnData=T) 

#PCA
#LOGARITHMIC TRANSFORMATIONS
vds<-vst(dds,blind = FALSE)
pcadata <- plotPCA(vds, intgroup = "condition", returnData = TRUE)
percentVar <- round(100 * attr(pcadata, "percentVar"))

p1 <- ggplot(
  pcadata,
  aes(PC1, PC2, fill = condition)
) +
  
  geom_jitter(
    shape = 21,
    color = "black",
    size = 6,
    stroke = 1.5,
    width = 0.4,
    height = 0.4,
    alpha = 0.9
  ) +
  
  xlab(
    paste0(
      "PC1: ",
      percentVar[1],
      "% varianza"
    )
  ) +
  
  ylab(
    paste0(
      "PC2: ",
      percentVar[2],
      "% varianza"
    )
  ) +
  
  ggtitle("PCA: MECOM KO vs control") +
  
  theme_classic(base_size = 14)

p1
#----12 Heatmap of correlation of samples----
#Calculate the distances between samples 
sampleDists <- as.matrix(dist(t(assay(vds))))

#par(mar=c(bottom,left,top,right))
par(oma=c(10,3,3,10)) 

heatmap(as.matrix(sampleDists),
        main = 'Heatmap de distancias',
        cexCol = 0.4,
        cexRow = 0.4) 

# Heat map 
library("ComplexHeatmap")
library("circlize")
library("RColorBrewer")
library("magick")
library("RColorBrewer")
library("gplots") 
library("genefilter") 
topVarGenes <- head( order( rowVars( assay(vds) ), decreasing=TRUE ), 500)

#heatmap without annotation 
Heatmap(assay(vds)[topVarGenes,],
        name = "differential expression", #title of legend
        column_title = "Samples", row_title = "Genes",
        column_names_gp = gpar(fontsize= 4),
        col = colorRamp2(c(16, 10, 4), brewer.pal(n=3, name="RdBu")),
        show_row_dend = FALSE,
        use_raster=FALSE,
        show_row_names = FALSE
)

# Define colors for each levels of qualitative variables
# Define gradient color for continuous variable (mpg)

col <- list(lesion_site = c("control" = "#FF6EB4", "MECOM_KO" = "purple"))

# Create the heatmap annotation
names(sampletable)
ha <- HeatmapAnnotation(condition= sampletable$condition,
                        col = col
)

# Combine the heatmap and the annotation
Heatmap(assay(vds)[topVarGenes,],
        name = "expression", #title ENSRNOG00000001926of legend
        column_title = "Samples", row_title = "Genes",
        column_names_gp = gpar(fontsize= 4),
        col = colorRamp2(c(16, 10, 4), brewer.pal(n=3, name="RdBu")),
        show_row_dend = FALSE,
        use_raster=FALSE,
        show_row_names = FALSE,
        top_annotation = ha,
        #show_heatmap_legend=FALSE
)

#Volcano plot 
head(res)

#using variable
head(deseq_Results)
names(deseq_Results)

EnhancedVolcano(deseq_Results,
                lab = deseq_Results$symbol,
                x = 'log2FoldChange',
                y = 'padj',
                title = 'MECOM KO vs control',
                subtitle = "Reference= control",
                labSize = 3.0,
                pCutoff = 0.05,
                FCcutoff = 1
) 

EnhancedVolcano(
  deseq_Results,
  lab = deseq_Results$symbol,
  x = 'log2FoldChange',
  y = 'padj',
  title = 'MECOM KO vs control',
  subtitle = "Reference = control",
  labSize = 5,              # aumentar tamaño
  pCutoff = 0.05,
  FCcutoff = 1,
  selectLab = c("MECOM"),
  
  boxedLabels = TRUE,       # poner etiqueta en caja
  drawConnectors = TRUE,    # línea al punto
  widthConnectors = 0.8
)

#Heat map con los 30 genes mas expresados 
library(pheatmap)
library(dplyr)
library(tibble)

volcano_df <- read.csv(
  "/home/user/Documents/octavo_semestre/Transcriptomica/proyecto_final1/DEA/outputs/DEA_MECOM_KO_vs_control.csv",
  row.names = 1
)

# guardar IDs
volcano_df$gene_id <- rownames(volcano_df)

# usar símbolo si existe
volcano_df$label <- ifelse(
  is.na(volcano_df$symbol),
  volcano_df$gene_id,
  volcano_df$symbol
)

# top genes por padj
top_genes <- volcano_df %>%
  filter(!is.na(padj)) %>%
  arrange(padj) %>%
  head(30) %>%
  pull(gene_id)

# extraer matriz VST
mat_top <- assay(vds)[top_genes, ]

# cambiar nombres de filas a símbolos
gene_labels <- volcano_df$label[
  match(top_genes, volcano_df$gene_id)
]

rownames(mat_top) <- gene_labels

# escalar por gen
mat_top_scaled <- t(scale(t(mat_top)))

# anotación columnas
annotation_col <- data.frame(
  condition = vds$condition
)

rownames(annotation_col) <- colnames(mat_top_scaled)

# heatmap
pheatmap(
  mat_top_scaled,
  annotation_col = annotation_col,
  show_rownames = TRUE,
  fontsize_row = 7,
  fontsize_col = 10,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  scale = "none",
  main = "Top 30 DE genes: MECOM KO vs control"
)

#-------------------------------------------------- 
library(pheatmap)
library(dplyr)
library(tibble)

volcano_df <- read.csv(
  "/home/user/Documents/octavo_semestre/Transcriptomica/proyecto_final1/DEA/outputs/DEA_MECOM_KO_vs_control.csv",
  row.names = 1
)

# guardar IDs
volcano_df$gene_id <- rownames(volcano_df)

# usar símbolo si existe
volcano_df$label <- ifelse(
  is.na(volcano_df$symbol),
  volcano_df$gene_id,
  volcano_df$symbol
)

# genes de interés
genes_interest <- c(
  "MECOM",
  "ZIC1",
  "CPAMD8",
  "SOX2",
  "ASCL1",
  "POU4F2",
  "NEFM",
  "ONECUT3",
  "PROX1",
  "PCP2",
  "VSX1",
  "RCVRN",
  "CRX",
  "PDE6C",
  "NRL",
  "RLBP1",
  "CA2"
)

# seleccionar genes presentes
selected_genes <- volcano_df %>%
  filter(symbol %in% genes_interest)

# extraer gene IDs
gene_ids <- selected_genes$gene_id

# extraer matriz VST
mat_sel <- assay(vds)[gene_ids, ]

# cambiar rownames a símbolos
rownames(mat_sel) <- selected_genes$symbol

# escalar por gen
mat_sel_scaled <- t(scale(t(mat_sel)))

# anotación de columnas
annotation_col <- data.frame(
  condition = vds$condition
)

rownames(annotation_col) <- colnames(mat_sel_scaled)

# heatmap
pheatmap(
  mat_sel_scaled,
  annotation_col = annotation_col,
  show_rownames = TRUE,
  fontsize_row = 10,
  fontsize_col = 10,
  cluster_rows = TRUE,
  cluster_cols = TRUE,
  scale = "none",
  main = "Selected genes: MECOM KO vs control"
)

# revisar genes faltantes
setdiff(genes_interest, volcano_df$symbol)
#---------------------------------------------------

#Analisis de enriquesimientos 
dea <- read.csv("/home/user/Documents/octavo_semestre/Transcriptomica/proyecto_final1/DEA/outputs/DEA_MECOM_KO_vs_control.csv")

library(R.utils)
# R.utils::setOption("clusterProfiler.download.method","wget")# Load libraries
library(DOSE)
library(pathview)
library(ggnewscale)
library(clusterProfiler)
library(org.Rn.eg.db)
library(tidyverse)

str(dea)
names(dea) 
rownames(dea)<- dea$X  
dea<- dea[,-1]
res_table <- dea %>%
  data.frame() %>%
  rownames_to_column(var="gene") %>%
  as_tibble() 

table(is.na(res_table$padj))  

all_genes <- as.character(res_table$gene)
head(all_genes) 

sigOE <- dplyr::filter(res_table, padj < 0.05)
sigOE_genes <- as.character(sigOE$gene) 
write.csv(sigOE_genes, file = "/home/user/Documents/octavo_semestre/Transcriptomica/proyecto_final1/DEA/outputs/sig_genes_ids.csv")

library(org.Hs.eg.db)
egoBP <- enrichGO(gene = sigOE_genes, universe = all_genes, keyType = "ENSEMBL",
                  OrgDb = org.Hs.eg.db, ont = "BP",pAdjustMethod = "fdr",  qvalueCutoff  = 0.1, pvalueCutoff  = 0.05)
head(egoBP)

dotplot(egoBP, showCategory = 20)
library(forcats)
goplot <- ggplot(egoBP, aes(x = Count, y = fct_reorder(Description, GeneRatio)),
                 showCategory = 30) +
  geom_point(aes(size = Count, color = p.adjust)) +
  theme_bw(base_size = 12) +
  scale_colour_gradient(limits=c(0, 0.05), low="red") +
  ylab(NULL) +
  ggtitle("MECOM KO vs control")

goplot


#Enrichment analysis 
library(clusterProfiler)
library(org.Hs.eg.db)
library(enrichplot)
library(ggplot2)

# preparar tabla
res_table <- dea %>%
  data.frame() %>%
  tibble::rownames_to_column(var = "gene") %>%
  as_tibble()

# quitar NAs
res_table <- dplyr::filter(
  res_table,
  !is.na(log2FoldChange)
)

# crear ranking para GSEA
gene_list <- res_table$log2FoldChange
names(gene_list) <- res_table$gene

# ordenar
gene_list <- sort(gene_list, decreasing = TRUE)

# correr GSEA GO
gse <- gseGO(
  geneList = gene_list,
  ont = "ALL",
  keyType = "ENSEMBL",
  OrgDb = org.Hs.eg.db,
  pAdjustMethod = "BH",
  pvalueCutoff = 0.05,
  minGSSize = 10,
  maxGSSize = 800,
  verbose = TRUE
)

# plot doble UP/DOWN
p_gsea <- dotplot(
  gse,
  showCategory = 15,
  split = ".sign"
) +
  facet_grid(. ~ .sign) +
  theme_bw(base_size = 12) +
  theme(
    axis.text.y = element_text(size = 7)
  ) +
  ggtitle("GSEA GO: MECOM KO vs control")

p_gsea

