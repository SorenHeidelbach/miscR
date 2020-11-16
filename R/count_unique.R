#' Count unique entries of one column in grouping of another column
#'
#'
#' @param data Dataframe.
#' @param subset_by Column to group by
#' @param count_col Column ID to count unique entries from.
#' @param subset_values Entries in `subset_by` to group by. If NA, then all entries are used
#'
#' @return Dataframe with number of unique entries in each subgroup
#' @export
#' @import tidyr
#' @import stringr
#'
#' @examples
count_unique <- function(data, subset_by, count_col, subset_values = NA){
  subset_data <- subset(data, select = subset_by)
  if (is.na(subset_values)){
    subset_values <- unique(subset_data)[,1]
  }
  if (all(subset_values %in% subset_data[,1])){
    d <- data.frame()
    for (q in subset_values){
      if (ncol(d) == 0){
        d <- data %>%
          condense_blast(subset_values = q, subset_by = subset_by, count_col = count_col)
      } else{
        d <- data %>%
          condense_blast(subset_values = q, subset_by = subset_by, count_col = count_col) %>%
          merge(d, by = "Counted", all = TRUE)
      }
    }
  } else{
    stop("Not everything is in the subset vector")
  }
  colnames(d) <- c(colnames(subset(data, select = count_col)), as.character(subset_values))
  d[is.na(d)] <- 0
  return(d)
}
condense_blast <- function(data, subset_values = NA, subset_by = 1, count_col = 2){
  if (!is.data.frame(data)){
    stop("`data` is not given as a dataframe")
  }
  if (class(subset_values) == "character"){
    d <- data[grepl(subset_values, data[, subset_by]),]
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
