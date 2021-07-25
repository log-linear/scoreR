#!/usr/bin/env -S Rscript --no-save --no-restore --no-site-file

#===============================================================================
# Usage: score.R n1 n2 [n3] ... [conf]
#
# Calculate a Bayesian Approximation of an ordinal score.R. All n[x]
# values must be integers, corresponding to the number of ratings of [x]
# value. Can optionally provide [conf] to calculate confidence interval
# for a specific level. Default confidence interval is .95.
#===============================================================================

#===============================================================================
# Scoring functions
#===============================================================================

# Valid scoring functions
scorers <- c(
  "wilson",
  "ordinal"
)

#' Calculate lower bound binomial confidence interval
#'
#' @param pos integer-valued scalar count of successes
#' @param n integer-valued scalar count of trials
#' @param conf decimal-valued scalar of desired confidence level
#' @return scalar, calculated Wilson score.R
#' @examples

#' wilson_score(5, 6, .95)
wilson_score <- function(pos, n, conf = .95) {
  if (n < pos) {
    return(cat("'n' must be equal to or less than pos"))
  }

  z <- qnorm(1 - (1 - conf) / 2)
  phat <- 1.0 * pos / n

  score <- (
    (phat
     + (z^2 / (2 * n))
     - (z * sqrt((phat * (1-phat) + z^2 / (4 * n)) / n)))
    /
    (1 + (z^2 / n))
  )

  return(score)
}

#' Calculate lower bound Bayesian confidence interval
#'
#' @param scores numeric vector of integer values, corresponding to the number
#'   of ratings per rating level (e.g. 5 one-star, 4 two-star, 1 three-star)
#' @param conf decimal-valued scalar of desired confidence level
#' @return scalar, calculated lower bound Bayesian confidence interval
#' @examples
#' ordinal_score(c(0, 4, 8, 2, 0), .95)
ordinal_score <- function(scores, conf = .95) {
  K <- length(scores)
  N <- sum(scores)
  z <- qnorm(1 - (1 - conf) / 2)

  sum1 <- sum(sapply(seq(scores), function(k) (k * (scores[k] + 1) / (N + K))))
  sum2 <- sum(sapply(seq(scores), function(k) (k^2 * (scores[k] + 1) / (N + K))))

  score <- sum1 - z * sqrt((sum2 - sum1^2) / (N + K + 1))

  return(score)
}

#===============================================================================
# Main script
#===============================================================================
main <- function() {

  # Get args
  args <- commandArgs(trailingOnly = T)

  # No arguments passed
  if(length(args) < 1) {
    args <- "--help"
  }

  # Define --help option
  if(!is.na(match("--help", args))) {
    return(
      cat(
        "Usage: score (wilson | ordinal) n1 n2 [n3] ... [--conf]",
        "\n",
        "Calculate Wilson scores for binomial count data (e.g. porportion of ",
        "'upvotes' to 'downvotes'), or Bayesian Approximation scores for ",
        "ordinal equivalents (e.g. 'true' average ratings for products rated ",
        "on a 5-point scale).",
        "\n",
        "For Wilson scores, only two arguments required: number of postive ",
        "cases (e.g. total upvotes) and number of total cases (e.g. total ",
        "upvotes + total downvotes)",
        "\n",
        "For Ordinal scores, any number of arguments may be supplied. Each ",
        "argument will be interpreted as the number of ratings for a given ",
        "score value in ascending order. For example: \n\nordinal 4 5 6 \n ",
        "would be interpreted as '4 one-star ratings, 5 two-star ratings, and ",
        "6 three-star ratings'",
        "\n\n",
        "--conf             Confidence interval for scoring. Must be",
        "                   decimal-valued. Defaults to .95",
        "\n\n",
        "Examples:",
        "\n",
        "score wilson 314 341\n",
        "score ordinal 4 6 35 45 25\n",
        "score wilson 314 341 --conf=.99",
        "score ordinal 4 6 35 45 25 --conf=.99",

        fill = 80
      )
    )
  }

  # Ensure valid first argument
  err1 <- expression(
    cat(
      "First argument must be one of ",
      "",
      scorers,
      "",
      sep = "\n",
      fill = 80
    )
  )

  scorer <- args[1]
  if (scorer != "wilson" & scorer != "ordinal") stop(eval(err1))

  # Parse confidence level option, if provided
  conf_index <- grep("--conf=.+", args)
  if (length(conf_index) != 0) {
    conf <- as.numeric(
      grep("[[:digit:]]+",
           gsub("--conf=", args[conf_index], replacement = ""),
           value = T)
    )
    if (length(conf) == 0 | conf >= 1) {
      stop("Argument for option --conf must be numeric, decimal valued")
    }
    args <- args[-conf_index]
  } else {
    conf <- .95
  }

  # Catch non-numeric arguments
  args <- as.numeric(args[-1])
  if (any(is.na(args))) stop("All arguments must be numeric.")
  n_args <- length(args)

  # Catch < 2 arguments
  if (n_args < 2) stop("Must provide at least two numeric arguments.")

  # Calculate Wilson score
  if (scorer == "wilson") {

    # Catch > 3 arguments
    if (n_args > 3) stop("Maximum of 3 arguments accepted for Wilson scoring")

    # Final parameters
    pos <- ifelse(
      args[1] %% 1 != 0,
      round(args[1] * args[2]),  # If proportion, convert to integer count
      args[1]
    )
    n <- args[2]

    # Calculate score
    result <- wilson_score(pos, n, conf)

  }
  else if (scorer == "ordinal") {

    # Catch non-integer arguments for n arguments < 3
    ints <- sapply(args, function(x) x %% 1 == 0)
    if (!any(ints))  stop("All arguments must be integers.")
    scores <- args

    # Calculate score.R
    result <- ordinal_score(scores, conf)
  }

  cat(result, fill = 80)
}

main()
