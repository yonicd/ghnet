% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gh_commit_data.R
\name{get_commit_user}
\alias{get_commit_user}
\title{get multiple commit stats}
\usage{
get_commit_user(owner, repo = NULL, gh_pat = Sys.getenv("GITHUB_PAT"),
  gepuro = TRUE, ...)
}
\arguments{
\item{owner}{character, user to query}

\item{repo}{character, repositories to get, Default: NULL}

\item{gh_pat}{character, github pat Default:  Sys.getenv('GITHUB_PAT')}

\item{gepuro}{tibble, output from fetch_gepuro, Default=NULL}

\item{\dots}{parameters passed to check_update}
}
\value{
tibble
}
\description{
get multiple commit statistics for repositories under a user name
}
\details{
if repos are null then list from fetch_gepuro output is used
}
\examples{

\dontrun{
gh_data <- get_commit_user(owner='yonicd')
}

}
