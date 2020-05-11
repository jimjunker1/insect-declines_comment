# Install pacman if it isn't already installed
if ("pacman" %in% rownames(installed.packages()) == FALSE) install.packages("pacman")

# Install packages required for analysis
# Add any packages required for your data cleaning and manipulation to the
# `p_load` function call below
# Do not remove the packages already listed here
# they are important for running the livedat repository
# OG package list: pacman::p_load(git2r, httr, semver, testthat, yaml)

pacman::p_load(dplyr, ggplot2)
pacman::p_load_gh("jimjunker1/junkR")

#' This function calculates the trend and assigns the study to a category: "trend"
#' "trend" is a categorical variable with three levels: "positive", "negative", and "no change"
#' Trend is calculated based on OLS regression 
#' 
#' @param data: A data.frame or data.frame confomrable object to perform analysis. Must include 'Year' and 'Number' columns at minimum.
#' @param cols_keep: A string of the columns to keep in the analysis. This defaults to NULL, but will always include 'Year' and 'Number'
#' @param alpha: the significance cutoff to detect trends

trend_detect <- function(data, cols_keep = NULL, alpha = 0.05,...){
  if(!is.data.frame(data)){ data <- data.frame(data)}
  if(!is.numeric(alpha)){alpha <- as.numeric(alpha)}
  
  if(is.null(cols_keep)){data_mod = na.omit(data[c("Year","Number")])} else{data_mod = na.omit(data[c(cols_keep, "Year","Number")])}
  trend_summ <- summary(lm(log10(Number+1)~Year, data = data_mod))$coefficients
  df_add <- data.frame(trend = NA, coef = round(trend_summ['Year','Estimate'],2), coef_se = round(trend_summ['Year','Std. Error'],2), N = nobs(lm(Number~Year, data = data_mod)))
  
 if(is.na(trend_summ['Year','Pr(>|t|)'])){
   df_add[,'trend'] <- 'NA'
   } else if(trend_summ['Year','Pr(>|t|)'] >= alpha) {
    df_add[,'trend'] <- "no change"
  } else if(trend_summ['Year','Estimate'] > 0) {
    df_add[,'trend'] <- "positive"
  } else {df_add[,'trend'] <- "negative"}

    if(is.null(cols_keep)){
    return(df_add)
    } else{cbind(unique(data_mod[,names(data_mod) %in% cols_keep]), df_add)}
}
  