#' @title Use github API to return tidy table of commits
#' @description Use github api rest call to fetch commit information
#' for a repository
#' @param repo repository name (user/repo)
#' @param gh_pat character, github pat Default: NULL
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
gh_commit_data <- function(repo,gh_pat = NULL){

  rate <- get_rate_limit(gh_pat = gh_pat)

  if(rate$remaining[1]==0)
    stop(sprintf('rate limit exceeded, wait %s minutes for reset ', round(rate$reset[1],2)))

  if(rate$remaining[1]%in%c(1:5))
    message(sprintf('close to exceeding rate limit, %s are left', rate$remaining[1]))

  thisurl <- sprintf('https://api.github.com/repos/%s/stats/contributors',repo)

  if(!is.null(gh_pat))
    thisurl <- sprintf('%s?access_token=%s',thisurl,gh_pat)

  this <- jsonlite::read_json(path = thisurl)

  this%>%
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
