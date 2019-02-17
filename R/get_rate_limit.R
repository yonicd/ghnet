#' @title Get current Github API rate limit
#' @description Get the current Github API rate limit with time to reset in minutes
#' @param gh_pat character, github pat Default: NULL
#' @return tibble
#' @details using this will not count against the rate limit
#' @examples
#'
#' get_rate_limit()
#'
#' get_rate_limit(gh_pat = Sys.getenv('GITHUB_PAT'))
#'
#' @rdname get_rate_limit
#' @export
#' @import dplyr
#' @import purrr
#' @importFrom httr GET content
#' @importFrom tibble enframe
#' @importFrom rlang !! sym
get_rate_limit <- function(gh_pat = NULL){

  thisurl <- 'https://api.github.com/rate_limit'

  if(!is.null(gh_pat))
    thisurl <- sprintf('%s?access_token=%s',thisurl,gh_pat)

  x <- httr::GET(url = thisurl)%>%
    httr::content()

  ret <- dplyr::bind_cols(
    tibble::enframe(x$rate)%>%
      dplyr::mutate(rate=purrr::flatten_dbl(!!rlang::sym('value')))%>%
      dplyr::select(-(!!rlang::sym('value'))),

    x$resources%>%
      dplyr::as_tibble()%>%
      dplyr::mutate_all(purrr::flatten_dbl)
    )

  out <- ret%>%
    dplyr::select(-(!!rlang::sym('name')))%>%
    t()%>%
    as.data.frame()%>%
    purrr::set_names(ret$name)

  out <- out%>%
    dplyr::mutate(type=rownames(out),
                  reset = difftime(as.POSIXct(!!rlang::sym('reset'),
                                              origin="1970-01-01"),
                                           Sys.time(),
                                           units = 'min'))%>%
    dplyr::select(!!rlang::sym('type'),dplyr::everything())%>%
    dplyr::as_tibble()

  return(out)

}
