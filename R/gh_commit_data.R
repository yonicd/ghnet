#' @title Use github API to return tidy table of commits
#' @description Use github api rest call to fetch commit information
#' for a repository
#' @param user user name
#' @param repo repository name
#' @param gh_pat character, github pat Default: NULL
#' @return tibble
#' @examples
#'
#' \dontrun{
#'
#' gh_data <- get_commit(user = 'thinkr-open', repo = 'remedy')
#'
#' }
#'
#' @seealso
#'  \code{\link[httr]{GET}}
#' @rdname get_commit
#' @export
#' @importFrom httr GET content http_error
#' @import purrr
#' @import dplyr
get_commit <- function(user, repo, gh_pat = NULL){

  if(httr::http_error(sprintf('https://github.com/%s/%s',user,repo)))
    return(NULL)

  rate <- get_rate_limit(gh_pat = gh_pat)

  if(rate$remaining[1]==0)
    stop(sprintf('rate limit exceeded, wait %s minutes for reset ', round(rate$reset[1],2)))

  if(rate$remaining[1]%in%c(1:5))
    message(sprintf('close to exceeding rate limit, %s are left', rate$remaining[1]))

  thisurl <- sprintf('https://api.github.com/repos/%s/%s/stats/contributors',user,repo)

  if(!is.null(gh_pat))
    thisurl <- sprintf('%s?access_token=%s',thisurl,gh_pat)

  this <- httr::GET(thisurl)%>%
    httr::content()

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

#' @title get multiple commit stats
#' @description get multiple commit statistics for repositories under a user name
#' @param user character, user to query
#' @param repo character, repositories to get, Default: NULL
#' @param gh_pat character, github pat Default: NULL
#' @param gepuro tibble, output from fetch_gepuro, Default=NULL
#' @param \dots parameters passed to check_update
#' @return tibble
#' @details if repos are null then list from fetch_gepuro output is used
#' @rdname get_commit_user
#' @examples
#'
#' gh_data <- get_commit_user(user='yonicd')
#'
#' @export
#' @import dplyr
#' @import purrr

get_commit_user <- function(user, repo=NULL, gh_pat = NULL, gepuro = NULL, ...){

  user_lgl <- purrr::map_lgl(user,check_update,...)

  if(all(user_lgl))
    return(invisible(NULL))

  user_ <- user[!user_lgl]

  rate <- get_rate_limit(gh_pat = gh_pat)

  if(rate$remaining[1]==0)
    stop(sprintf('rate limit exceeded, wait %s minutes for reset ', round(rate$reset[1],2)))

  if(rate$remaining[1]%in%c(1:5))
    message(sprintf('close to exceeding rate limit, %s are left', rate$remaining[1]))

  if(!is.null(gepuro)){

    repos <- gepuro%>%
        dplyr::filter(user%in%user_)%>%
        dplyr::select(-n)%>%
        tidyr::unnest(repo)

  }else{

    repos <- dplyr::tibble(user=user,repo=repo)

  }

  if(!is.null(repo)){
    repos <- repos%>%
      dplyr::filter(repo%in%repo)
  }

    purrr::map2_df(repos$user,
                   repos$repo,
                   get_commit,
                   gh_pat = gh_pat)

}

#' @title re-export purrr pipe operators
#'
#' @importFrom dplyr %>%
#' @name %>%
#' @rdname pipe
#' @export
NULL
