% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/predict.R
\name{predict_model}
\alias{predict_model}
\title{Function to predict mean from the model result}
\usage{
predict_model(
  model_output,
  new_data = NULL,
  predict_iid = FALSE,
  newdata = NULL
)
}
\arguments{
\item{model_output}{disag_model object returned by disag_model function}

\item{new_data}{If NULL, predictions are made using the data in model_output.
If this is a SpatRaster, predictions will be made over this data. Default NULL.}

\item{predict_iid}{If TRUE, any polygon iid effect from the model will be used in the prediction. Default FALSE.}

\item{newdata}{Deprecated.}
}
\value{
The mean prediction, which is a list of:
  \itemize{
   \item \emph{prediction} Raster of mean predictions based.
   \item \emph{field} Raster of the field component of the linear predictor.
   \item \emph{iid} Raster of the iid component of the linear predictor.
   \item \emph{covariates} Raster of the covariate component of the linear predictor.
  }
}
\description{
\emph{predict_model} function takes a \emph{disag_model} object created by
\emph{disaggregation::disag_model} and predicts mean maps.
}
\details{
Function returns rasters of the mean predictions as well as the  covariate and field contributions
to the linear predictor.

To predict over a different spatial extent to that used in the model,
a SpatRaster covering the region to make predictions over is passed to the argument \emph{new_data}.
If this is not given predictions are made over the data used in the fit.

The \emph{predict_iid} logical flag should be set to TRUE if the results of the iid effect from the model are to be used in the prediction.
}
\examples{
\dontrun{
predict_model(result)
}

}
