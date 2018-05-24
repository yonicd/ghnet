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
fetch_gepuro <- function(){

  repos <- as.data.frame(do.call('cbind',jsonlite::fromJSON('http://rpkg.gepuro.net/download')$pkg_list),stringsAsFactors = FALSE)

  repos$user <- gsub('/(.*?)$','',repos$pkg_name)
  repos$repo <- gsub('^(.*?)/','',repos$pkg_name)

  repos <- dplyr::as_tibble(repos)%>%
    dplyr::select(user,repo)%>%
    tidyr::nest(-user)

  d <- repos$data%>%
    purrr::transpose()%>%
    dplyr::as_tibble()

  d$user <- repos$user

  d%>%
    dplyr::select(user,repo)%>%
    dplyr::mutate(n = purrr::map_dbl(repo,length))%>%
    dplyr::arrange(desc(n))
}
