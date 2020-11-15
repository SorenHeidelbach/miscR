#' hello
#'
#' @param x The name of the person it says hello to
#'
#' @return The output from \code{\link{print}}
#' @export
#'
#' @examples
#' hello('John')
hello <- function(x) {
 print(paste("Hello,", x, ", have a nice day"))
}
