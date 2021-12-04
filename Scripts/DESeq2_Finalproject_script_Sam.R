################################################################################
#htseq-count input
directory <- "~/Desktop/GDC/all"
sampleFiles <- grep("group",list.files(directory),value=TRUE)
sampleCondition <- sub("(.*group).*","\\1",sampleFiles)
sampleTable <- data.frame(sampleName = sampleFiles,
                          fileName = sampleFiles,
                          condition = sampleCondition)
sampleTable$condition <- factor(sampleTable$condition)
library("DESeq2")
dds <- DESeqDataSetFromHTSeqCount(sampleTable = sampleTable,
                                  directory = directory,
                                  design= ~ condition)
################################################################################
##Pre_filtering: remove rows in which there are reads less than 10.
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]
################################################################################
##Note on factor levels: tell results which comparison to make.
dds$condition <- factor(dds$condition, levels = c("younggroup","oldgroup"))
################################################################################
##Speed-up and parallelization thoughts
library("BiocParallel")
register(MulticoreParam(4))
################################################################################
#Differential expression analysis
###The standard differential expression analysis steps are wrapped into a single function, DESeq.
dds <- DESeq(dds)
################################################################################
##specify the contrast and build a results table.
res <- results(dds, contrast=c("condition","younggroup","oldgroup"))
##summarize some basic tallies using the summary function.
summary(res)
##check how many adjusted p-values were less than 0.01.
sum(res$padj < 0.01, na.rm=TRUE)

##Log fold change shrinkage for visualization and ranking
resultsNames(dds)
library(apeglm)
resLFC <- lfcShrink(dds, coef="condition_oldgroup_vs_younggroup", type="apeglm")

##p-values and adjusted p-values
resOrdered <- res[order(res$pvalue),]

##set the adjusted p value cutoff to 0.05.
res05 <- results(dds, alpha=0.05)
summary(res05)

##Independent hypothesis weighting: A generalization of the idea of p value filtering is to weight hypotheses to optimize power.
library("IHW")
resIHW <- results(dds, filterFun=ihw, contrast=c("condition","younggroup","oldgroup"), alpha=0.05,)
summary(resIHW)
################################################################################

#Exploring and exporting results

##MA-plot
plotMA(res, ylim=c(-2,2))

##remove the noise associated with log2-fold changes from low count genes without requiring arbitrary filtering thresholds.
plotMA(resLFC, ylim=c(-2,2))

#Alternative shrinkage estimators
resultsNames(dds)

##Due to being interested in younggroup vs oldgroup, I set 'coef=2'.
resNorm  <- lfcShrink(dds, coef=2, type="normal")
resAsh <- lfcShrink(dds, coef=2, type="ashr")

par(mfrow=c(1,3), mar=c(4,4,2,1))
xlim <- c(1,1e5); ylim <- c(-3,3)
plotMA(resLFC, xlim=xlim, ylim=ylim, main="apeglm")
plotMA(resNorm, xlim=xlim, ylim=ylim, main="normal")
plotMA(resAsh, xlim=xlim, ylim=ylim, main="ashr")

##Plot counts: examine the counts of reads for a single gene across the groups.
plotCounts(dds, "ENSG00000004809.12", intgroup="condition")#padj<0.01
plotCounts(dds, "ENSG00000205853.9", intgroup="condition")#RFPL3S

##an argument returnData specifies that the function should only return a data.frame for plotting with ggplot.
d <- plotCounts(dds, "ENSG00000205853.9", intgroup="condition", 
                returnData=TRUE)
library("ggplot2")
ggplot(d, aes(x=condition, y=count)) + 
  geom_point(position=position_jitter(w=0.1,h=0)) + 
  scale_y_log10(breaks=c(25,100,400))

##More information on results columns
mcols(res)$description
################################################################################

# Data transformations and visualization
## Count data transformations
### Extracting transformed values
vsd <- vst(dds, blind=FALSE)
head(assay(vsd), 3)
### this gives log2(n + 1)
ntd <- normTransform(dds)
library("vsn")
meanSdPlot(assay(ntd))
meanSdPlot(assay(vsd))

# Data quality assessment by sample clustering and visualization
## Heatmap of the count matrix
library("pheatmap")
select <- order(rowMeans(counts(dds,normalized=TRUE)),
                decreasing=TRUE)[1:20]
df <- as.data.frame(colData(dds)[,c("condition", "sizeFactor")])
pheatmap(assay(ntd)[select,], cluster_rows=FALSE, show_rownames=FALSE,
         cluster_cols=FALSE, annotation_col=df, show_colnames = FALSE)
pheatmap(assay(vsd)[select,], cluster_rows=FALSE, show_rownames=FALSE,
         cluster_cols=FALSE, annotation_col=df, show_colnames = FALSE)

## Heatmap of the sample-to-sample distances
sampleDists <- dist(t(assay(vsd)))
library("RColorBrewer")
sampleDistMatrix <- as.matrix(sampleDists)
rownames(sampleDistMatrix) <- paste(vsd$condition, vsd$type, sep="-")
colnames(sampleDistMatrix) <- NULL
colors <- colorRampPalette( rev(brewer.pal(9, "Blues")) )(255)
pheatmap(sampleDistMatrix,
         clustering_distance_rows=sampleDists,
         clustering_distance_cols=sampleDists,
         col=colors, show_rownames=FALSE)

##Principal component plot.
plotPCA(vsd, intgroup=c("condition"))

##customize the PCA plot using the ggplot function.
pcaData <- plotPCA(vsd, intgroup=c("condition"), returnData=TRUE)
percentVar <- round(100 * attr(pcaData, "percentVar"))
ggplot(pcaData, aes(PC1, PC2, color=condition, shape=condition)) +
  geom_point(size=2) +
  xlab(paste0("PC1: ",percentVar[1],"% variance")) +
  ylab(paste0("PC2: ",percentVar[2],"% variance")) + 
  coord_fixed()
################################################################################
#Independent hypothesis weighting: A generalization of the idea of p-value filtering is to weight hypotheses to optimize power. 
#(The result table that I select to manage my data.)
library("IHW")
resIHW <- results(dds, filterFun=ihw, contrast=c("condition","younggroup","oldgroup"), alpha=0.05,)
summary(resIHW)
##ensembl_id to gene_name
ens_id<- substr(row.names(resIHW),1 ,15)
rownames(resIHW) <- ens_id
rawcount<- resIHW
Ensembl_ID <- data.frame(Ensembl_ID = row.names(rawcount))
rownames(Ensembl_ID) <- Ensembl_ID[,1]
rawcount <-cbind(Ensembl_ID, rawcount)

##change Ensembl_id to symble_ name_id.
get_map = function(input) {
  if (is.character(input)) {
    if(!file.exists(input)) stop("Bad input file.")
    message("Treat input as file")
    input = data.table::fread(input, header = FALSE)
  } else{
    data.table::setDT(input)
  }
  input = input[input[[3]] == "gene", ]
  
  pattern_id = ".*gene_id \"([^;]+)\";.*"
  pattern_name = ".*gene_name \"([^;]+)\";.*"
  
  gene_id = sub(pattern_id, "\\1", input[[9]])
  gene_name = sub(pattern_name, "\\1", input[[9]])
  
  Ensembl_ID_TO_Genename <- data.frame(gene_id = gene_id,
                                       gene_name = gene_name,
                                       stringsAsFactors = FALSE)
  return(Ensembl_ID_TO_Genename)
}
Ensembl_ID_TO_Genename <- get_map("~/Desktop/GDC/gencode.v38lift37.annotation.gtf")
gtf_Ens_ID <- substr(Ensembl_ID_TO_Genename[,1],1,15)
Ensembl_ID_TO_Genename <- data.frame(gtf_Ens_ID, Ensembl_ID_TO_Genename[,2])
colnames(Ensembl_ID_TO_Genename) <- c("Ensembl_ID","gene_id")
write.csv(Ensembl_ID_TO_Genename, file = "~/Desktop/GDC/Ensembl_ID_TO_Genename.csv")

##merge data with "Ensembl_ID".
mergeRawCounts <- merge(Ensembl_ID_TO_Genename, rawcount ,by = "Ensembl_ID")

##remove duplicate data by "gene_id.
index <- duplicated(mergeRawCounts$gene_id)
mergeRawCounts <- mergeRawCounts[!index,]

##use gene_id as rownames.
rownames(mergeRawCounts) <- mergeRawCounts[,"gene_id"]
res_new <- mergeRawCounts[,-c(1:2)]

##save files.
write.csv(as.data.frame(res_new), file = "~/Desktop/GDC/res_new.csv")

################################################################################
summary(res_new)
res_df <- as.data.frame(res_new)
get_upregulated <- function(df){
  
  key <- intersect(rownames(df)[which(df$log2FoldChange>=1)], rownames(df)[which(df$pvalue<=0.05)])
  
  results <- as.data.frame((df)[which(rownames(df) %in% key),])
  return(results)
}

get_downregulated <- function(df){
  
  key <- intersect(rownames(df)[which(df$log2FoldChange<=-1)], rownames(df)[which(df$pvalue<=0.05)])
  
  results <- as.data.frame((df)[which(rownames(df) %in% key),])
  return(results)
}
up <- get_upregulated(res_df)
write.csv(as.data.frame(up), file = "~/Desktop/GDC/up.csv")
down <- get_downregulated(res_df)
write.csv(as.data.frame(down), file = "~/Desktop/GDC/down.csv")
################################################################################