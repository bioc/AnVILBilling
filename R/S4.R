setOldClass("tbl_df")

#' accessor for reckoning element
#' @param x an instance of avReckoning
#' @return a tibble with one row for each expense type by time slice
#' @examples
#' dim(ab_reckoning(demo_rec))
#' @export
ab_reckoning = function(x) x@reckoning

# internal accessors
#' @keywords internal
ab_keys = function(x) x@keys
#' @keywords internal
ab_start = function(x) x@start
#' @keywords internal
ab_end = function(x) x@end
#' @keywords internal
ab_project = function(x) x@project
#' @keywords internal
ab_dataset = function(x) x@dataset
#' @keywords internal
ab_table = function(x)  x@table 
#' @keywords internal
ab_billing_code = function(x) x@billing_code

setClass("avReckoningRequest", representation(start="ANY", # FIXME -- use POSIXct
  end="ANY", project="character", dataset="character", table="character",
   billing_code="character"))

setClass("avReckoning", contains="avReckoningRequest", 
  representation(reckoning="tbl_df", keys="character"))

setMethod("show", "avReckoningRequest", function(object) {
cat("AnVIL reckoning info for project ", object@project, "\n")
cat(sprintf("  starting %s, ending %s.\n", ab_start(object), 
    ab_end(object)))
})

setMethod("show", "avReckoning", function(object) {
 callNextMethod()
 cat("There are ", nrow(ab_reckoning(object)), " records.\n")
 cat("Available keys:\n")
 print(ab_keys(object))
 cat("---","\n")
 cat("Use ab_reckoning() for full table\n")
})

#' set up request object
#' @param start character(1) date of start of reckoning
#' @param end character(1) date of end of reckoning
#' @param project character(1) GCP project id
#' @param dataset character(1) GCP dataset id for billing data in BQ
#' @param table character(1) GCP table for billing data in BQ
#' @param billing_code character(1) GCP billing code
#' @return instance of avReckoningRequest
#' @examples
#' lk1 = setup_billing_request("2020-08-01", "2020-08-15",
#'    "bq_scoped_project", "bq_dataset", "bq_table", "billcode")
#' lk1
#' @export
setup_billing_request = function(
 start, end, project, dataset, table, billing_code ) {
  new("avReckoningRequest", 
      start=start,
      end=end,
      project=project,
      dataset=dataset,
      table=table,
      billing_code=billing_code)
}

#' perform reckoning
#' @param obj instance of avReckoningRequest
#' @return instance of avReckoning
#' @examples
#' data(demo_rec)
#' if (interactive()) reckon(demo_rec)
#' @export
reckon = function(obj) {
  dat = getBilling(ab_start(obj), ab_end(obj),
     ab_dataset(obj), ab_table(obj), ab_billing_code(obj))
  keys = getKeys(dat)
  new("avReckoning", obj, reckoning = dat, keys=keys)
}

#' generic for accessor for reckoning component
#' @param x object inheriting from avReckoning
#' @return tbl_df
#' @examples
#' if (interactive()) reckoning(reckon(demo_rec))
#' @export
setGeneric("reckoning", function(x) standardGeneric("reckoning"))

#' accessor for reckoning component
#' @param x instance of avReckoning
#' @return tbl_df
#' @examples
#' if (interactive()) reckoning(reckon(demo_rec))
#' @export
setMethod("reckoning", "avReckoning", function(x) ab_reckoning(x))
