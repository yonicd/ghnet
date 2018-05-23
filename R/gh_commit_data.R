#' @title Use github API to return tidy table of commits
#' @description Use github api rest call to fetch commit information
#' for a repository
#' @param repo repository name (user/repo)
#' @return dataframe
#' @details beware of the rate limit for the api
#' @examples
#'
#' \dontrun{
#' repos <- c(
#' 'thinkr-open/remedy',
#' 'hrbrmstr/slackr',
#' 'hrbrmstr/ggalt',
#' 'hrbrmstr/hrbrthemes',
#' 'metrumresearchgroup/sinew')
#'
#' #single
#'
#' gh_data <- gh_commit_data(repos[1])
#'
#'
#' #multiple
#' gh_data <- purrr::map_df(repos,gh_commit_data)
#'
#' }
#'
#' @seealso
#'  \code{\link[jsonlite]{read_json}}
#' @rdname gh_commit_data
#' @export
#' @importFrom jsonlite read_json
#' @import purrr
#' @import dplyr
gh_commit_data <- function(repo){

  on.exit({Sys.sleep(5)},add = TRUE)

  jsonlite::read_json(path = sprintf('https://api.github.com/repos/%s/stats/contributors',repo))%>%
    purrr::map_df(.f=function(x){
      dplyr::as_tibble(purrr::transpose(x$weeks))%>%
        dplyr::mutate_all(.funs = dplyr::funs(purrr::flatten_dbl))%>%
        dplyr::mutate(user = x$author$login,
               date = as.Date(as.POSIXct(w, origin="1970-01-01")))
    })%>%
    dplyr::mutate(repo = repo)%>%
    dplyr::filter(c!=0)%>%
    dplyr::arrange(dplyr::desc(date),user)

}

#' @title re-export purrr pipe operators
#'
#' @importFrom dplyr %>%
#' @name %>%
#' @rdname pipe
#' @export
NULL
