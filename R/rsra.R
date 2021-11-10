rsra = function(idList, outdir = getwd(), location = c("NCBI", "AWS")) {
  location = match.arg(location)

  success = 0
  for (i in idList) {
    rv = query(i, location)
    if (!isFALSE(rv)) {

    }
  }
}
