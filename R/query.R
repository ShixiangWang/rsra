# query("SRR8657217")
query = function(id, location = c("NCBI", "AWS")) {
  location = match.arg(location)

  x = tryCatch(
    {
      rvest::read_html(glue::glue("https://trace.ncbi.nlm.nih.gov/Traces/sra/?run={id}")) %>%
        rvest::html_table()
    },
    error = function(e) {
      # warning here
      FALSE
    }
  )

  if (isFALSE(x)) {
    return(FALSE)
  }

  flag = sapply(x, function(x) {
    all(c("Size", "Location", "Name", "Free Egress", "Access Type") %in% colnames(x))
  })

  x = x[flag]
  if (sum(flag) > 0) {
    x = x[[1]]
  } else return(FALSE)

  link = x$Name[x$Location == location]

  if (length(link) != 1) return(FALSE)
  link
}

