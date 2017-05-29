## Motivation

Graphic packages like `lattice` and `ggplot2` work best when data are presented in **long format** as opposed to **wide format** into which data are typically imported and in which it is usually convenient to perform calculations.  For example `morley` is a data frame in long format, which allows functions like `lattice::xyplot` to receive simple formulas and yet produce a complex trellis display.


```r
library(lattice)
data(morley)
```


Take e.g. the formula `Speed ~ Run | Expt`, in which the speed of light measured by Michelson in 1879 plays the role of a response variable, the measurement run that of a predictor and the experimental replicate acts as a conditioning variable:

```r
morley$Expt <- as.factor(paste("Expt", morley$Expt)) # adjustment for xyplot
xyplot(Speed ~ Run | Expt, data = morley)
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png)

So, how is a given data set to be restructured between the wide and long format?  How do those structural properties reflect the underlying experimental design such as a longitudinal or a factorial one?  And how to use `stats::reshape`, R's principal restructuring tool with a given structure/design?
