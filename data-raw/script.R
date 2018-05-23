library(dplyr)
library(purrr)
library(igraph)
library(ggraph)
library(tidygraph)
library(patchwork) # (from remote)

gh_commit_data <- function(repo){

  on.exit({Sys.sleep(5)},add = TRUE)

  jsonlite::read_json(path = sprintf('https://api.github.com/repos/%s/stats/contributors',repo))%>%
    purrr::map_df(.f=function(x){
      dplyr::as_tibble(purrr::transpose(x$weeks))%>%
        dplyr::mutate_all(.funs = funs(purrr::flatten_dbl))%>%
        mutate(user = x$author$login,
               date = as.Date(as.POSIXct(w, origin="1970-01-01")))
    })%>%
    dplyr::mutate(repo = repo)%>%
    dplyr::filter(c!=0)%>%
    dplyr::arrange(desc(date),user)


}

gh_commit_plot <- function(data){

  x_year_commit <- data%>%
    dplyr::mutate(year=format(date,'%Y'))%>%
    dplyr::group_by(repo,year,user)%>%
    dplyr::summarise(total_commits=sum(c))%>%
    dplyr::ungroup()%>%
    dplyr::select(from=user, to=repo,year,total_commits)%>%
    dplyr::mutate(origin = to)

  graph_year_commit <- x_year_commit%>%
    tidygraph::as_tbl_graph()%>%
    mutate(Popularity = centrality_degree(mode = 'in'),
           origin = ifelse(grepl('/',name),'repo','user'),
           name = gsub('^(.*?)/','',name))

  graph_year_commit%>%
    ggraph(layout = 'kk') +
    geom_edge_link(aes(alpha = total_commits)) +
    geom_node_point(aes(size=Popularity),show.legend = FALSE) +
    geom_node_label(aes(label=name,fill=origin),show.legend = FALSE) +
    facet_edges(~year) +
    theme_graph(foreground = 'steelblue', fg_text_colour = 'white')

}

repos <- c('hrbrmstr/slackr',
           'hrbrmstr/ggalt',
           'hrbrmstr/hrbrthemes',
           'thinkr-open/remedy',
           'metrumresearchgroup/sinew')

#all repos for a user
# repos <- vcs::list_repos('ropenscilabs')%>%
#  purrr::flatten_chr()

gh_data <- purrr::map_df(repos,gh_commit_data)

gh_plot <- gh_data%>%
  dplyr::mutate(year=format(date,'%Y'))%>%
  split(.$year)%>%
  purrr::map(gh_commit_plot)%>%
  reduce(`+`) +
  plot_layout(ncol=3)

wrap_elements(gh_plot) +
  ggtitle('Github Repository Contribution Network')
