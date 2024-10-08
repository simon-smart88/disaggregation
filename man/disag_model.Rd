% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fit_model.R
\name{disag_model}
\alias{disag_model}
\title{Fit the disaggregation model}
\usage{
disag_model(
  data,
  priors = NULL,
  family = "gaussian",
  link = "identity",
  iterations = 100,
  field = TRUE,
  iid = TRUE,
  hess_control_parscale = NULL,
  hess_control_ndeps = 1e-04,
  silent = TRUE
)
}
\arguments{
\item{data}{disag_data object returned by \code{\link{prepare_data}} function that contains all the necessary objects for the model fitting}

\item{priors}{list of prior values:
\itemize{
\item \code{priormean_intercept}
\item \code{priorsd_intercept}
\item \code{priormean_slope}
\item \code{priorsd_slope}
\item \code{prior_rho_min}
\item \code{prior_rho_prob}
\item \code{prior_sigma_max}
\item \code{prior_sigma_prob}
\item \code{prior_iideffect_sd_max}
\item \code{prior_iideffect_sd_prob}
 }}

\item{family}{likelihood function: \emph{gaussian}, \emph{binomial} or \emph{poisson}}

\item{link}{link function: \emph{logit}, \emph{log} or \emph{identity}}

\item{iterations}{number of iterations to run the optimisation for}

\item{field}{logical. Flag the spatial field on or off}

\item{iid}{logical. Flag the iid effect on or off}

\item{hess_control_parscale}{Argument to scale parameters during the calculation of the Hessian.
Must be the same length as the number of parameters. See \code{\link[stats]{optimHess}} for details.}

\item{hess_control_ndeps}{Argument to control step sizes during the calculation of the Hessian.
Either length 1 (same step size applied to all parameters) or the same length as the number of parameters.
Default is 1e-3, try setting a smaller value if you get NaNs in the standard error of the parameters.
See \code{\link[stats]{optimHess}} for details.}

\item{silent}{logical. Suppress verbose output.}
}
\value{
A list is returned of class \code{disag_model}.
The functions \emph{summary}, \emph{print} and \emph{plot} can be used on \code{disag_model}.
The list  of class \code{disag_model} contains:
 \item{obj }{The TMB model object returned by \code{\link[TMB]{MakeADFun}}.}
 \item{opt }{The optimized model object returned by \code{\link[stats]{nlminb}}.}
 \item{sd_out }{The TMB object returned by \code{\link[TMB]{sdreport}}.}
 \item{data }{The \emph{disag_data} object used as an input to the model.}
 \item{model_setup }{A list of information on the model setup. Likelihood function (\emph{family}), link function(\emph{link}), logical: whether a field was used (\emph{field}) and logical: whether an iid effect was used (\emph{iid}).}
}
\description{
\emph{disag_model} function takes a \emph{disag_data} object created by
\code{\link{prepare_data}} and performs a Bayesian disaggregation fit.
}
\details{
\strong{The model definition}

The disaggregation model makes predictions at the pixel level:
\deqn{link(pred_i) = \beta_0 + \beta X + GP(s_i) + u_i}{ link(predi) = \beta 0 + \beta X + GP + u}

And then aggregates these predictions to the polygon level using the weighted sum (via the aggregation raster, \eqn{agg_i}{aggi}):
\deqn{cases_j = \sum_{i \epsilon j} pred_i \times agg_i}{ casesj = \sum (predi x aggi)}
\deqn{rate_j = \frac{\sum_{i \epsilon j} pred_i \times agg_i}{\sum_{i \epsilon j} agg_i}}{ratej = \sum(predi x aggi) / \sum (aggi)}

The different likelihood correspond to slightly different models (\eqn{y_j}{yi} is the response count data):
\itemize{
  \item Gaussian:
   If \eqn{\sigma} is the dispersion of the pixel data, \eqn{\sigma_j}{\sigmaj} is the dispersion of the polygon data, where
   \eqn{\sigma_j = \sigma \sqrt{\sum agg_i^2} / \sum agg_i }{\sigmaj = \sigma x { \sqrt \sum (aggi ^ 2) } / \sum aggi}
   \deqn{dnorm(y_j/\sum agg_i, rate_j, \sigma_j)}{dnorm(yj / \sum aggi, ratej, \sigmaj)} - predicts incidence rate.
  \item Binomial:
   For a survey in polygon j, \eqn{y_j}{yj} is the number positive and \eqn{N_j}{Nj} is the number tested.
   \deqn{dbinom(y_j, N_j, rate_j)}{dbinom(yj, Nj, ratej)} - predicts prevalence rate.
  \item Poisson:
   \deqn{dpois(y_j, cases_j)}{dpois(yj, casesj)} - predicts incidence count.
}

Specify priors for the regression parameters, field and iid effect as a single list. Hyperpriors for the field
are given as penalised complexity priors you specify \eqn{\rho_{min}} and \eqn{\rho_{prob}} for the range of the field
where \eqn{P(\rho < \rho_{min}) = \rho_{prob}}, and \eqn{\sigma_{min}} and \eqn{\sigma_{prob}} for the variation of the field
where \eqn{P(\sigma > \sigma_{min}) = \sigma_{prob}}. Also, specify pc priors for the iid effect

The \emph{family} and \emph{link} arguments are used to specify the likelihood and link function respectively.
The likelihood function can be one of \emph{gaussian}, \emph{poisson} or \emph{binomial}.
The link function can be one of \emph{logit}, \emph{log} or \emph{identity}.
These are specified as strings.

The field and iid effect can be turned on or off via the \emph{field} and \emph{iid} logical flags. Both are default TRUE.

The \emph{iterations} argument specifies the maximum number of iterations the model can run for to find an optimal point.

The \emph{silent} argument can be used to publish/suppress verbose output. Default TRUE.
}
\examples{
\dontrun{
polygons <- list()
n_polygon_per_side <- 10
n_polygons <- n_polygon_per_side * n_polygon_per_side
n_pixels_per_side <- n_polygon_per_side * 2

for(i in 1:n_polygons) {
  row <- ceiling(i/n_polygon_per_side)
  col <- ifelse(i \%\% n_polygon_per_side != 0, i \%\% n_polygon_per_side, n_polygon_per_side)
  xmin = 2*(col - 1); xmax = 2*col; ymin = 2*(row - 1); ymax = 2*row
  polygons[[i]] <- list(cbind(c(xmin, xmax, xmax, xmin, xmin),
                              c(ymax, ymax, ymin, ymin, ymax)))
}

polys <- lapply(polygons,sf::st_polygon)
N <- floor(runif(n_polygons, min = 1, max = 100))
response_df <- data.frame(area_id = 1:n_polygons, response = runif(n_polygons, min = 0, max = 1000))

spdf <- sf::st_sf(response_df, geometry = polys)

# Create raster stack
r <- terra::rast(ncol=n_pixels_per_side, nrow=n_pixels_per_side)
terra::ext(r) <- terra::ext(spdf)
r[] <- sapply(1:terra::ncell(r), function(x){
rnorm(1, ifelse(x \%\% n_pixels_per_side != 0, x \%\% n_pixels_per_side, n_pixels_per_side), 3))}
r2 <- terra::rast(ncol=n_pixels_per_side, nrow=n_pixels_per_side)
terra::ext(r2) <- terra::ext(spdf)
r2[] <- sapply(1:terra::ncell(r), function(x) rnorm(1, ceiling(x/n_pixels_per_side), 3))
cov_stack <- c(r, r2)
names(cov_stack) <- c('layer1', 'layer2')

test_data <- prepare_data(polygon_shapefile = spdf,
                          covariate_rasters = cov_stack)

 result <- disag_model(test_data, iterations = 2)
 }

}
\references{
Nanda et al. (2023) disaggregation: An R Package for Bayesian
Spatial Disaggregation Modeling. <doi:10.18637/jss.v106.i11>
}
