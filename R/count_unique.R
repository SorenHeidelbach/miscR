#' Takes a dataframe and count_col unique entries of a column
#' by grouping of id in another column.
#'
#' @param data Dataframe.
#' @param subset Character vector with entries to subset by.
#' @param subset_col Column to group counting by
#' @param count_col Column ID to count unique entries from.
#'
#' @return Dataframe with number of unique entries in each subgroup
#' @export
#' @import tidyr
#' @import stringr
#'
#' @examples
count_unique <- function(data, subset_col, count_col, subset_values = NA){
  subset_data <- subset(data, select = subset_col)
  if (is.na(subset_values)){
    subset_values <- unique(subset_data)[,1]
  }
  if (all(subset_values %in% subset_data[,1])){
    d <- data.frame()
    for (q in subset_values){
      if (ncol(d) == 0){
        d <- data %>%
          condense_blast(subset_values = q, subset_col = subset_col, count_col = count_col)
      } else{
        d <- data %>%
          condense_blast(subset_values = q, subset_col = subset_col, count_col = count_col) %>%
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

