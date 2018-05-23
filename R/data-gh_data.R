#' @title github commit data
#' @description tidied output from github API REST
#' @format A data frame with 130 rows and 7 variables:
#' \describe{
#'   \item{\code{w}}{double Start of the week in epoch time}
#'   \item{\code{a}}{double lines added}
#'   \item{\code{d}}{double lines deleted}
#'   \item{\code{c}}{double number of commits}
#'   \item{\code{user}}{character username}
#'   \item{\code{date}}{double w as.Date}
#'   \item{\code{repo}}{character repository name}
#'}
"gh_data"
