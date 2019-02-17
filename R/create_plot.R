#' @title create network plot
#' @description creates a ggpraph object using the tidied commit data
#' @param data tibble, tidied commit data from \code{\link{get_commit}}
#' @param add_labels character, add labels to graph nodes, Default: 'none'
#' @return ggraph plot
#' @details add_labels can be c('both','repo','user','none')
#' @examples
#'
#' \dontrun{
#' gh_data_2018 <- gh_data%>%
#' dplyr::filter(format(date,'%Y')=='2018')%>%
#' dplyr::mutate(freq_var = format(date,'%Y'))%>%
#' create_graph_data()
#'
#' gh_data_2018%>%create_plot()
#'
#' gh_data_2018%>%create_plot(add_labels='user')
#'
#' gh_data_2018%>%create_plot(add_labels='repo')
#'
#' gh_data_2018%>%create_plot(add_labels='both')
#'
#' }
#'
#' @seealso
#'  \code{\link[tidygraph]{as_tbl_graph.data.frame}},\code{\link[tidygraph]{centrality}}
#' @rdname create_plot
#' @export
#' @import dplyr
#' @importFrom tidygraph as_tbl_graph centrality_degree
#' @import ggraph
#' @import ggplot2
#' @importFrom rlang !! sym
create_plot <- function(data,add_labels = 'none'){

  ret <- data%>%
    ggraph::ggraph(layout = 'kk') +
    ggraph::geom_edge_link(ggplot2::aes(alpha = !!rlang::sym('total_commits'))) +
    ggraph::facet_edges(~freq_var) +
    ggraph::theme_graph(foreground = 'steelblue', fg_text_colour = 'white')

  ret <- switch(add_labels,

    'both' = {
      ret +
        ggraph::geom_node_point(ggplot2::aes(size=!!rlang::sym('Popularity')),alpha = 0.5, show.legend = FALSE) +
        ggraph::geom_node_label(ggplot2::aes(label=!!rlang::sym('name'),fill=!!rlang::sym('origin')),repel = TRUE, show.legend = FALSE)
    },

    'user' = {
      ret +
        ggraph::geom_node_point(ggplot2::aes(size=!!rlang::sym('Popularity')),alpha = 0.5, show.legend = FALSE) +
        ggraph::geom_node_label(ggplot2::aes(label=!!rlang::sym('user'),fill=!!rlang::sym('origin')),show.legend = FALSE)
    },

    'repo' = {
      ret +
        ggraph::geom_node_point(ggplot2::aes(size=!!rlang::sym('Popularity')),alpha = 0.5, show.legend = FALSE) +
        ggraph::geom_node_label(ggplot2::aes(label=!!rlang::sym('repo'),fill=!!rlang::sym('origin')),repel = TRUE,show.legend = FALSE)
    },
    {
      ret +
        ggraph::geom_node_point(ggplot2::aes(size=!!rlang::sym('Popularity')),alpha = 0.5, show.legend = FALSE)
    })

    return(ret)

}

#' @title create data for network plot
#' @description creates tidied commit data to pass into plot
#' @param data data.frame, tidied commit data from \code{\link{get_commit}}
#' @param touch highlight a user, Default: NULL
#' @return tibble
#' @seealso
#'  \code{\link[tidygraph]{as_tbl_graph.data.frame}},\code{\link[tidygraph]{centrality}}
#' @rdname create_plot_data
#' @export
#' @import dplyr
#' @importFrom tidygraph as_tbl_graph centrality_degree
#' @importFrom rlang !! !!! sym syms
create_graph_data <- function(data, touch=NULL){

  x_freq_commit <- data%>%
    dplyr::group_by(!!!rlang::syms(c('repo','freq_var','user')))%>%
    dplyr::summarise(total_commits=sum(!!rlang::sym('c')))%>%
    dplyr::ungroup()%>%
    dplyr::select(from=!!rlang::sym('user'), to=!!rlang::sym('repo'),
                  !!rlang::sym('freq_var'),!!rlang::sym('total_commits'))%>%
    dplyr::mutate(origin = !!rlang::sym('to'))

  x_freq_commit%>%
    tidygraph::as_tbl_graph()%>%
    dplyr::mutate(Popularity = tidygraph::centrality_degree(mode = 'in'),
                  origin = dplyr::if_else(!!rlang::sym('name')%in%data$repo,'repo','user'),
                  force = !!rlang::sym('name')%in%touch,
                  repo = dplyr::if_else(!!rlang::sym('origin')=='repo'|!!rlang::sym('force'),!!rlang::sym('name'),NA),
                  user = dplyr::if_else(!!rlang::sym('origin')=='user'|!!rlang::sym('force'),!!rlang::sym('name'),NA),
                  user = dplyr::if_else(!!rlang::sym('name')%in%touch|!!rlang::sym('force'),!!rlang::sym('name'),!!rlang::sym('user')))
}
