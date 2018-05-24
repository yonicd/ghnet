#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param user PARAM_DESCRIPTION
#' @param datetime PARAM_DESCRIPTION, Default: gittime(Sys.Date()-1)
#' @param gh_pat character, github pat Default: NULL
#' @param verbose PARAM_DESCRIPTION, Default: TRUE
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso
#'  \code{\link[httr]{GET}},\code{\link[httr]{add_headers}},\code{\link[httr]{stop_for_status}}
#' @rdname check_update
#' @export
#' @importFrom httr GET add_headers message_for_status
check_update <- function(user, datetime = gittime(Sys.Date()-1), gh_pat = NULL, verbose = TRUE){

  thisurl <- sprintf('https://api.github.com/users/%s',user)

  if(!is.null(gh_pat))
    thisurl <- sprintf('%s?access_token=%s',thisurl,gh_pat)

  ret <- httr::GET(thisurl,
            httr::add_headers('If-Modified-Since' = datetime))

  if(ret$status_code==304){
    if(verbose)
    httr::message_for_status(ret)
    return(invisible(TRUE))
  }else{
    return(invisible(FALSE))
  }

}

#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param datetime PARAM_DESCRIPTION, Default: Sys.time()
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname gittime
#' @export

gittime <- function(datetime=Sys.time()){

  x <- as.POSIXct(datetime)

  x <- structure(as.integer(x), class = class(x), tzone = 'GMT')

  format(x,format = '%a, %d %b %Y %T',usetz = TRUE)

}
