context("Predict model")

test_that("Check predict_model function works as expected", {
  
  polygons <- list()
  for(i in 1:100) {
    row <- ceiling(i/10)
    col <- ifelse(i %% 10 != 0, i %% 10, 10)
    xmin = 2*(col - 1); xmax = 2*col; ymin = 2*(row - 1); ymax = 2*row
    polygons[[i]] <- rbind(c(xmin, ymax), c(xmax,ymax), c(xmax, ymin), c(xmin,ymin))
  }
  
  polys <- do.call(raster::spPolygons, polygons)
  response_df <- data.frame(area_id = 1:100, response = runif(100, min = 0, max = 10))
  spdf <- sp::SpatialPolygonsDataFrame(polys, response_df)
  
  # Create raster stack
  r <- raster::raster(ncol=20, nrow=20)
  r[] <- sapply(1:raster::ncell(r), function(x) rnorm(1, ifelse(x %% 20 != 0, x %% 20, 20), 3))
  r2 <- raster::raster(ncol=20, nrow=20)
  r2[] <- sapply(1:raster::ncell(r), function(x) rnorm(1, ceiling(x/10), 3))
  cov_stack <- raster::stack(r, r2)
  
  cl <- parallel::makeCluster(2)
  doParallel::registerDoParallel(cl)
  test_data <- prepare_data(polygon_shapefile = spdf, 
                            covariate_rasters = cov_stack)
  parallel::stopCluster(cl)
  foreach::registerDoSEQ()
  
  result <- fit_model(test_data, its = 2)
  
  preds <- predict_model(test_data, result)
  
  expect_is(preds, 'predictions')
  expect_equal(length(preds), 3)
  expect_equal(names(preds), c('prediction', 'field', 'covariates'))
  expect_is(preds$prediction, 'Raster')
  expect_is(preds$field, 'Raster')
  expect_is(preds$covariates, 'Raster')
  
})