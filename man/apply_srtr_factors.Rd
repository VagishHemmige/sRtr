% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/apply_srtr_factors.R
\name{apply_srtr_factors}
\alias{apply_srtr_factors}
\title{Apply SRTR factor labels to a data frame}
\usage{
apply_srtr_factors(df, file_key = NULL, verbose = FALSE)
}
\arguments{
\item{df}{A data frame loaded from an SRTR SAF file.}

\item{file_key}{Optional. The dataset name (e.g., "CAND_KIPA", "TX_KI").
If not provided, will be inferred from the object name of \code{df}.}

\item{verbose}{Logical. If TRUE, print each variable being labeled.}
}
\value{
A data frame with factor levels applied to coded variables.
}
\description{
Converts coded variables in an SRTR dataset into human-readable factors
using the SRTR data dictionary and associated format tables.
}
\examples{
\dontrun{
# Explicit file_key
df <- read_sas("TX_KI.sas7bdat")
df <- apply_srtr_factors(df, file_key = "TX_KI", verbose = TRUE)

# Implicit file_key inferred from object name
TX_KI <- read_sas("TX_KI.sas7bdat")
TX_KI <- apply_srtr_factors(TX_KI, verbose = TRUE)
}
}
