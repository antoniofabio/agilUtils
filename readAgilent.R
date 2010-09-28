#!/usr/bin/env Rscript
if(!suppressPackageStartupMessages(require("optparse", quietly=TRUE))) {
  stop("the 'optparse' package is needed in order to run this script")
}

option_list <-
  list(
       make_option(c("-v", "--variables"), default="LogRatio,PValueLogRatio,gProcessedSignal,rProcessedSignal",
                   help="comma-separated list of variables to be extracted [default: LogRatio,PValueLogRatio,gProcessedSignal,rProcessedSignal]"),
       make_option(c("-l", "--list-variables"), action="store_true", default=FALSE, help="list available variables"),
       make_option(c("-o", "--output-file"), default="X.RData", help="output RData file name [default: X.RData]")
       )

parser <- OptionParser(usage="%prog [options] data-files", option_list=option_list)
arguments <- parse_args(parser, positional_arguments = TRUE)
opt <- arguments$options
vList <- strsplit(opt$variables, ",")[[1]]

files <- arguments$args
f1 <- files[1]
h <- strsplit(readLines(f1, 1), "\t")[[1]]
h1 <- make.names(gsub("Software Unknown:(.*)$", "\\1", h), unique=TRUE)
if(opt$`list-variables`) {
  writeLines(h1)
  quit("no")
}

featureNames <- read.delim(f1, colClasses=ifelse(h1 == "Reporter.identifier", "character", "NULL"))[[1]]
featureNames <- gsub("www.chem.agilent.com:R:(.*)", "\\1", featureNames)
colClasses <- ifelse(h1 %in% vList, "numeric", "NULL")
R <- lapply(files, read.delim, colClasses=colClasses)
Rv <- as.vector(unlist(sapply(R, unlist)))
X <- aperm(array(Rv,
                 dim=c(length(featureNames), length(vList), length(files)),
                 dimnames=list(feature=featureNames,
                   variable=vList,
                   sample=files)),
           3:1)

save(X, file=opt$`output-file`)
