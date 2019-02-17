#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @rdname fetch_gepuro
#' @export
#' @import dplyr
#' @import purrr
#' @importFrom jsonlite fromJSON
#' @importFrom tidyr nest
#' @importFrom tibble as_tibble
#' @importFrom rlang !! !!! sym syms
fetch_gepuro <- function(){

  repos <- as.data.frame(do.call('cbind',jsonlite::fromJSON('http://rpkg.gepuro.net/download')$pkg_list),stringsAsFactors = FALSE)

  repos$user <- gsub('/(.*?)$','',repos$pkg_name)
  repos$repo <- gsub('^(.*?)/','',repos$pkg_name)

  repos <- repos%>%
    tibble::as_tibble()%>%
    dplyr::select(!!! rlang::syms(c('user','repo')))%>%
    tidyr::nest(-c(!!rlang::sym('user')))

  d <- repos$data%>%
    purrr::transpose()%>%
    tibble::as_tibble()

  d$owner <- repos$user

  d%>%
    dplyr::select(!!! rlang::syms(c('owner','repo')))%>%
    dplyr::mutate(n = purrr::map_dbl(!!rlang::sym('repo'),length))%>%
    dplyr::arrange(desc(!!rlang::sym('n')))
}
