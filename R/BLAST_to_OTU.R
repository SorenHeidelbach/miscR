#' Take a blast out put and count number of unique hits
#'
#' @param df Dataframe with BLAST data. Should contain query name and output accesion ID.
#' @param query Vector of character to subset and merge by
#'
#' @return Dataframe with unique blast results and number of hits
#' @export
#' @import tidyr
#' @import stringr
#'
#' @examples
BLAST_to_OTU <- function(df, query = NA){
  if (class(query) == "character" && length(query) > 1){
    d <- condense_blast(df ,query[1])
    for (q in query[2:length(query)]){
      d_temp <- condense_blast(df, q)
      d <- merge(d, d_temp, by = colnames(d_temp)[1], all = TRUE)
    }
    colnames(d) <- c("OTU", query)
  } else if(class(query) == "character"){
    d <- condense_blast(df, query)
    colnames(d) <- c("OTU", query)
  } else if (is.na(query)){
    d <- condense_blast(df)
    colnames(d) <- c("OTU", "Count")
  } else {
    print("Please make sure 'query' is a character vector")
    break
  }
  return(d)
}

