#' Query and download SRA files from NCBI
#'
#' @param idList a list of cases to download.
#' @param prefetch if not `NULL`, should be the path to the prefetch program.
#' @param outdir output directory, default is working directory.
#' @param progress if `TRUE`, show 'wget' download progress.
#' @param location one of "AWS" or "NCBI" for download server.
#' "GCAP" is not available due to its limit.
#' @param opts options work with `prefetch` (expects `-p`) when `prefetch` is not `NULL`.
#'
#' @return Nothing
#' @export
#' @importFrom cli col_green col_blue
rsra <- function(idList, prefetch = NULL, outdir = getwd(),
                 progress = TRUE, location = c("AWS", "NCBI"),
                 opts = "-r yes -C yes") {
  stopifnot(length(idList) > 0)

  location <- location[1]
  if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)

  if (is.null(prefetch)) cli::cli_alert_info("Download server set to {location}")

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

  if (!is.null(prefetch)) {
    cli::cli_alert_info("prefetch is set to {prefetch}, use CLI to download")
    # if (!file.exists(prefetch)) {
    #   cli::cli_alert_danger("the program not found")
    #   return(NULL)
    # }
    if (progress) opts <- paste0(opts, " ", "-p")
    cli <- sprintf("%s %s -O %s %s", prefetch, opts, outdir, paste(idList, collapse = " "))
    cli::cli_alert_info("download data files with command `{cli}`")
    system(cli)
    return(NULL)
  }

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
      if (progress) args <- args[-5]

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

  cli::cli_alert_info("Total input {col_blue(length(idList))} cases, {col_green(success)} downloaded successfully")
}