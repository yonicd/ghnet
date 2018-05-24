#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param user PARAM_DESCRIPTION
#' @param datetime PARAM_DESCRIPTION, Default: gittime(Sys.Date())
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
check_update <- function(user, datetime = gittime(Sys.Date()), verbose = TRUE){
  ret <- httr::GET(sprintf('https://api.github.com/users/%s',user),
            httr::add_headers('If-Modified-Since' = datetime))

  if(ret$status_code==304){
    if(verbose)
    httr::message_for_status(ret)
    return(invisible(FALSE))
  }else{
    return(invisible(TRUE))
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
