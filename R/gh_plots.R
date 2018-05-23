#' @title create network plots of the tidied commit data
#' @description use ggraph to create logitudinal network plots by year
#' @param plots output from \code{\link{create_plot}}
#' @param add_label character, add labels to graph nodes, Default: 'none'
#' @param title character title of plot, Default: NULL
#' @details add_labels can be c('both','repo','user','none')
#' @return plot
#' @examples
#'
#' gh_data%>%gh_plots(title = 'Github Repository Contribution Network')
#'
#' gh_data%>%gh_plots(title = 'Github Repository Contribution Network',add_labels='both')
#'
#' @rdname gh_plots
#' @export
#' @import dplyr
#' @import purrr
#' @import patchwork
gh_plots <- function(plots, add_labels = 'none', title = NULL){

  dat <- plots%>%
    dplyr::mutate(year=format(date,'%Y'))%>%
    split(.$year)

  gh_plots <- dat%>%
      purrr::map(create_plot,add_labels = add_labels)%>%
      purrr::reduce(`+`)

  if(length(dat)<=2){
    gh_plot <- gh_plots +
      patchwork::plot_layout(nrow=length(dat))
  }else{
    gh_plot <- gh_plots +
      patchwork::plot_layout(ncol=3)
  }


  ret <- patchwork::wrap_elements(gh_plot)

  if(!is.null(title))
    ret <- ret + ggplot2::ggtitle(title)

  return(ret)
}