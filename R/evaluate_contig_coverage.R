#' Evaluate the coverage of contigs from depth file
#' @description The depth file should created by the following bash script: \cr
#'     minimap2 -ax sr contigs.fasta reads.fastq | samtools view -Sb - | samtools sort - -o file.bam \cr
#'     samtools depth file.bam > depth_file.txt
#' @param path Path to depth file
#' @param log10_axis Normal or logarithmic scale for axis
#' @param parametric FALSE: median, Q97.5/2.5 and Q100/0. TRUE: mean, SD and 95 confidence interval
#'
#' @import tidyr
#' @import ggplot2
#' @import data.table
#' @return Plot with coverage distrubution for each contig
#' @export
#'
#' @examples
evaluate_contig_coverage <-  function(path,
                                      log10_axis = TRUE,
                                      parametric = FALSE){

 cov = fread(path, header = F, col.names = c("scaffold", "position", "coverage"))
 cov = cov[, .(mean = mean(coverage),
               SD = sd(coverage),
               size = max(position),
               t = qt(0.975, max(position)),
               Q0 = quantile(coverage)[1],
               Q25 = quantile(coverage)[2],
               Q50 = quantile(coverage)[3],
               Q75 = quantile(coverage)[4],
               Q100 = quantile(coverage)[5],
               Q97.5 = quantile(coverage, .975)[1],
               Q2.5 = quantile(coverage, .025)[1]),
           by = scaffold]
 cov$node <- cov$scaffold %>%
  strsplit("_") %>%
  sapply(function(x) paste(x[1:2], collapse = "_"))
 cov$nodeNR <- cov$scaffold %>%
  strsplit("_") %>%
  sapply(function(x) x[2])
 # plot
 if (!parametric){
  p <- ggplot(cov, aes(x=size, y=Q50)) +
   geom_errorbar(aes(ymin=Q0,   ymax=Q100 ),  size=0.4, alpha = 0.2) +
   geom_errorbar(aes(ymin=Q2.5, ymax=Q97.5 ), size=0.4)
 } else{
  p <- ggplot(cov, aes(x=size, y=mean)) +
   geom_errorbar(aes(ymin=(mean-SD*t) , ymax=(mean+SD*t)), alpha=0.2) +
   geom_errorbar(aes(ymin=(mean-SD) , ymax=(mean+SD)))
 }
 if (log10_axis){
  p <- p + scale_x_log10(limits = c(min(cov$size), max(cov$size)*1.1)) +
   scale_y_log10(limits = c(min(cov$Q0), max(cov$Q100)*1.1)) +
   annotation_logticks(base = 10)
 }
 p <- p + ylab(element_text("Coverage")) +
  xlab(element_text("Contig size [bp]")) +
  theme_classic() +
  theme(axis.title = element_text(size=15),
        axis.text = element_text(size=8)) +
  geom_point(colour="gray1", size=2, fill="gray70", pch=21)
 return(p)
}
