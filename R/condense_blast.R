#' Take a blast out put and count_col number of unique hits
#'
#' @param data Data frame of the BLAST output
#' @param subset_values Subset results by character string in query name
#' @param count_col The countumn to count unique entries from. Can be countumn name or index
#'
#' @return Dataframe with unique blast results and number of hits
#' @import tidyr
#' @import stringr
#' @examples
condense_blast <- function(data, subset_values = NA, subset_col = 1, count_col = 2){
 if (!is.data.frame(data)){
   stop("'data' is not given as a dataframe")
 }
 if (class(subset_values) == "character"){
  d <- data[grepl(subset_values, data[, subset_col]),]
 } else if(!is.na(subset_values)){
   stop("Something went wrong")
 }
 # save accession countumn only
 d <-  as.data.frame(d[, count_col])
 # condense and count number of accession numbers
 d <- d %>%
  table() %>%
  as.data.frame()
 if (nrow(d) == 0){
   stop(paste(subset_values,"was not found, please remove it from the query vector"))
 }
 colnames(d) <- c("Counted", "Count")
 return(d)
}
