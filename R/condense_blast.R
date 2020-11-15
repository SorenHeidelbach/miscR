#' Take a blast out put and count number of unique hits
#'
#' @param df Data frame of the BLAST output
#' @param query_subset Subset results by character string in query name
#'
#' @return Dataframe with unique blast results and number of hits
#' @import tidyr
#' @import stringr
#' @examples
condense_blast <- function(df, query_subset = NA){
 if (class(query_subset) == "character"){
  d <- df[grepl(query_subset, df$V1),]
 }
 # Save accesion column only
 d <-  as.data.frame(d[,2])
 # Condense and count number of accesion numbers
 d <- d %>%
  table() %>%
  as.data.frame()
 return(d)
}
