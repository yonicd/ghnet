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
get_rate_limit <- function(gh_pat = NULL){

  thisurl <- 'https://api.github.com/rate_limit'

  if(!is.null(gh_pat))
    thisurl <- sprintf('%s?access_token=%s',thisurl,gh_pat)

  x <- httr::GET(url = thisurl)%>%
    httr::content()

  ret <- dplyr::bind_cols(
    tibble::enframe(x$rate)%>%
      dplyr::mutate(rate=purrr::flatten_dbl(value))%>%
      dplyr::select(-value),

    x$resources%>%
      dplyr::as_tibble()%>%
      dplyr::mutate_all(purrr::flatten_dbl)
    )

  out <- ret%>%
    dplyr::select(-name)%>%
    t()%>%
    as.data.frame()%>%
    purrr::set_names(ret$name)%>%
    dplyr::mutate(type=rownames(.),
                  reset = difftime(as.POSIXct(reset,
                                                      origin="1970-01-01"),
                                           Sys.time(),
                                           units = 'min'))%>%
    dplyr::select(type,dplyr::everything())%>%
    dplyr::as_tibble()

  return(out)

}
