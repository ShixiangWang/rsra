#' Query and download SRA files from NCBI
#'
#' @param idList a list of cases to download.
#' @param outdir output directory, default is working directory.
#' @param progress if `TRUE`, show 'wget' download progress.
#' @param location one of "NCBI" or "AWS" for download server.
#'
#' @return Nothing
#' @export
#' @importFrom cli col_green col_blue
rsra <- function(idList, outdir = getwd(), progress = FALSE, location = c("NCBI", "AWS")) {
  stopifnot(length(idList) > 0)

  location <- match.arg(location)
  if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

  cli::cli_alert_info("Download server set to {location}")

  if (file.exists(idList[1])) {
    cli::cli_alert_info("Treat input {.file {idList}} as file(s)")
    if (length(idList) == 1) {
      idList <- data.table::fread(idList, header = FALSE)[[1]]
    } else {
      idList <- data.table::rbindlist(lapply(idList, function(x) {
        data.table::fread(idList, header = FALSE)
      }))[[1]]
    }
  }
  idList <- setdiff(idList, "")

  cli::cli_alert_success("{length(idList)} cases detected")

  success <- 0L
  for (i in idList) {
    cli::cli_alert("Querying information from NCBI for {.field {i}}")
    rv <- query(i, location)
    cli::cli_alert_success("Query done")
    if (!isFALSE(rv)) {
      cli::cli_alert("Checking output file name")
      fn <- file.path(outdir, paste0(sub("\\..*$", "", basename(rv)), ".sra"))
      cli::cli_alert("Downloading file {.file {fn}} from {.url {rv}}")

      args <- c("-c", rv, "-O", fn, "-q")
      if (progress) args <- c(args, "--show-progress")

      status <- system2("wget", args)
      if (status != 0) {
        cli::cli_alert_danger("Case {.field {i}} failed in download step")
      } else {
        success <- success + 1L
        cli::cli_alert_success("Success for {.field {i}}")
      }
    } else {
      cli::cli_alert_danger("Case {.field {i}} failed in query step")
    }
  }

  cli::cli_alert_info("Total input {col_blue(length(idList))} cases, {col_green(success))} downloaded successfully")
}
