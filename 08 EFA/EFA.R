# https://easystats.github.io/parameters/articles/efa_cfa.html


# 24 psychological tests given to 145 seventh and eight-grade children
Harman74 <- read.csv("Harman74.csv")
head(Harman74)

library(psych)
library(parameters)


# How many factors to retain in Factor Analysis (FA)? ---------------------

## Is the data suitable for FA? --------
round(cor(Harman74), 2) # hard to visually "see" structure in the data...

check_factorstructure(Harman74)




## Scree plot --------
screeplot(
  prcomp(Harman74, scale. = TRUE),
  npcs = 10, type = "lines"
)
abline(h = 1) # use only when scale. = TRUE
# where is the elbow?



## Other methods --------
ns <- n_factors(
  Harman74,
  type = "FA",
  algorithm = "pa", rotation = "oblimin"
)
# This function calls many methods, e.g., nFactors::nScree... Read the doc!

as.data.frame(ns) # look for Kaiser criterion of Scree







# Run Factor Analysis (FA) ------------------------------------------------







## Run FA
efa <- fa(Harman74, nfactors = 5, 
          fm = "pa", # (principal factor solution), or use gm = "minres" (minimum residual method)
          rotate = "oblimin") # or rotate = "varimax"
# You can see a full list of rotation types here:
?GPArotation::rotations



efa # Read about the outputs here: https://m-clark.github.io/posts/2020-04-10-psych-explained/
model_parameters(efa, sort = TRUE, threshold = 0.45)
# These give the pattern matrix




# fa.diagram(efa, cut = 0.45)
# biplot(efa, choose = c(1,2,5), pch = ".", cuts = 0.45)  # choose = NULL to look at all of them







# We can now use the factor scores just as we would any variable:
data_scores <- efa$scores
colnames(data_scores) <- c("Verbal","Numeral","Visual","Math","Je Ne Sais Quoi") # name the factors
head(data_scores)








# Reliability -------------------------------------------------------------

# We need a little function here...
efa_reliability <- function(x, keys = NULL, threshold = 0, labels = NULL) {
  #'         x - the result from psych::fa()
  #'      keys - optional, see ?psych::make.keys
  #' threshold - which values from the loadings should be used
  #'    labels - factor labels
  
  L <- unclass(x$loadings)
  r <- x$r  
  
  if (is.null(keys)) keys <- sign(L) * (abs(L) > threshold) 
  
  out <- data.frame(
    Factor = colnames(L),
    Omega = colSums(keys * L)^2 / diag(t(keys) %*% r %*% keys)
  )
  
  if (!is.null(labels))
    out$Factor <- labels
  else
    rownames(out) <- NULL
  
  out
}

efa_reliability(efa, threshold = 0.45, 
                labels = c("Verbal","Numeral","Visual","Math","Je Ne Sais Quoi"))
# These are interpretable similarly to Cronbach's alpha






# Exercise ----------------------------------------------------------------

# Select only the 25 first columns corresponding to the items
bfi <- subset(psychTools::bfi, select = 1:25)
bfi <- na.omit(bfi) # Note, there are ways to do EFA with missing data...
head(bfi)

# 1. Validate the big-5: look at a scree-plot to see if the data suggests 5
#   factors or more or less.
# 2. Conduct an EFA.
# 3. Look at the loadings - do they make sense?
# 4. Fit a second EFA with one more / less factor. Compare it to the previous
#   EFA; You can use `anova()` (`d.chiSq` is the test statistic with `d.df`
#   degrees of freedom. `PR` is the p-value.)
#   Note: Chi-squared corresponds to the variance unaccounted for in the
#   selected factors. And the difference (`d.chiSq`) is the *additional*
#   accounted variance by the EFA with more factors. If the results is
#   significant, this means that the model with more factors significantly
#   accounted for more variance!

