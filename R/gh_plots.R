#' @title create network plots of the tidied commit data
#' @description use ggraph to create logitudinal network plots by year
#' @param plots output from \code{\link{create_plot}}
#' @param freq character, frequency to facet, Default: 'Y'
#' @param add_labels character, add labels to graph nodes, Default: 'none'
#' @param touch add highlight for a user, Default: NULL
#' @param title character title of plot, Default: NULL
#' @param \dots arguments to pass to \code{\link[patchwork]{plot_layout}}
#' @details add_labels can be c('both','repo','user','none')
#' @return plot
#' @examples
#' \dontrun{
#' gh_data%>%
#'   gh_plots(title = 'Github Repository Contribution Network')
#'
#' gh_data%>%
#'   gh_plots(
#'     title = 'Github Repository Contribution Network',
#'     add_labels = 'both'
#'     )
#' }
#'
#' @rdname gh_plots
#' @export
#' @import dplyr
#' @import purrr
#' @import patchwork
#' @importFrom rlang !! sym
gh_plots <- function(plots, freq = '%Y', add_labels = 'none',touch = NULL, title = NULL, ...){

  dat <- plots%>%
    dplyr::mutate(freq_var=format(!!rlang::sym('date'),freq))%>%
    dplyr::group_split(!!rlang::sym('freq_var'))

  gh_plots <- dat%>%
    purrr::map(.f=function(x, add_labels, touch){
      x%>%
        ghnet::create_graph_data(touch = touch)%>%
        ghnet::create_plot(add_labels = add_labels)
    },
    add_labels = add_labels,
    touch = touch)%>%
    purrr::reduce(`+`)

  if(length(dat)>1)
    gh_plots <- gh_plots +
      patchwork::plot_layout(...)

  ret <- patchwork::wrap_elements(gh_plots)

  if(!is.null(title))
    ret <- ret + ggplot2::ggtitle(title)

  return(ret)
}
