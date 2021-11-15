
# rsra

<!-- badges: start -->
<!-- badges: end -->

The goal of `{rsra}` is to query download information for SRA accession list and
download them with `wget`.

## Installation

`wget` is required in your system.

You can install this package with:

``` r
remotes::install_github("ShixiangWang/rsra")
```

## Example

Function signature:

```r
> args(rsra)
function (idList, outdir = getwd(), progress = FALSE, location = c("NCBI", 
    "AWS"))
```

The first argument can be file(s) storing accession list in each line.

### In R console

```r
library(rsra)
rsra("SRR8615934")
```

### In terminal

```sh
Rscript -e 'rsra::rsra("SRR8615934")'
```

## Similar projects

- [get-ena-seq](https://github.com/wangshun1121/get-ena-seq)

## LICENSE

GPL-3

