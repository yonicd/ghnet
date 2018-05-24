#' @title create network plot
#' @description creates a ggpraph object using the tidied commit data
#' @param data data.frame, tidied commit data from \code{\link{gh_commit_data}}
#' @param add_label character, add labels to graph nodes, Default: 'none'
#' @return ggraph plot
#' @details add_labels can be c('both','repo','user','none')
#' @examples
#'
#' gh_data_2018 <- gh_data%>%dplyr::filter(format(date,'%Y')=='2018')
#'
#' gh_data_2018%>%create_plot()
#'
#' gh_data_2018%>%create_plot(add_labels='user')
#'
#' gh_data_2018%>%create_plot(add_labels='repo')
#'
#' gh_data_2018%>%create_plot(add_labels='both')
#'
#' @seealso
#'  \code{\link[tidygraph]{as_tbl_graph.data.frame}},\code{\link[tidygraph]{centrality}}
#' @rdname create_plot
#' @export
#' @import dplyr
#' @importFrom tidygraph as_tbl_graph centrality_degree
#' @import ggraph
#' @import ggplot2
create_plot <- function(data, add_labels = 'none',touch=NULL){

  x_year_commit <- data%>%
    dplyr::mutate(year=format(date,'%Y'))%>%
    dplyr::group_by(repo,year,user)%>%
    dplyr::summarise(total_commits=sum(c))%>%
    dplyr::ungroup()%>%
    dplyr::select(from=user, to=repo,year,total_commits)%>%
    dplyr::mutate(origin = to)

  graph_year_commit <- x_year_commit%>%
    tidygraph::as_tbl_graph()%>%
    dplyr::mutate(Popularity = tidygraph::centrality_degree(mode = 'in'),
                  origin = ifelse(name%in%data$repo,'repo','user'),
                  force = name%in%touch,
                  repo = ifelse(origin=='repo'|force,name,NA),
                  user = ifelse(origin=='user'|force,name,NA),
                  user = ifelse(name%in%touch|force,name,user))

  ret <- graph_year_commit%>%
    ggraph::ggraph(layout = 'kk') +
    ggraph::geom_edge_link(ggplot2::aes(alpha = total_commits)) +
    ggraph::facet_edges(~year) +
    ggraph::theme_graph(foreground = 'steelblue', fg_text_colour = 'white')

  ret <- switch(add_labels,

    'both' = {
      ret +
        ggraph::geom_node_label(ggplot2::aes(label=name,fill=origin),repel = TRUE, show.legend = FALSE) +
        ggraph::geom_node_point(ggplot2::aes(size=Popularity),alpha = 0.5, show.legend = FALSE)
    },

    'user' = {
      ret +
        ggraph::geom_node_point(ggplot2::aes(size=Popularity),alpha = 0.5, show.legend = FALSE) +
        ggraph::geom_node_label(ggplot2::aes(label=user,fill=origin),show.legend = FALSE)
    },

    'repo' = {
      ret +
        ggraph::geom_node_label(ggplot2::aes(label=repo,fill=origin),repel = TRUE,show.legend = FALSE) +
        ggraph::geom_node_point(ggplot2::aes(size=Popularity),alpha = 0.5, show.legend = FALSE)
    },
    {
      ret +
        ggraph::geom_node_point(ggplot2::aes(size=Popularity),alpha = 0.5, show.legend = FALSE)
    })

    return(ret)

}
