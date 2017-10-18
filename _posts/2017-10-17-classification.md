---
layout: default
title: Classification
tags: [ classification ]
Rdir: "/R/2017-10-17-classification/"
---

Hello, World!

## Data

We are going to use the home data from [A visual introduction to machine learning](http://www.r2d3.us/visual-intro-to-machine-learning-part-1/)


```r
library(lattice)
lattice.options(default.args = list(as.table = TRUE))
lattice.options(default.theme = "standard.theme")
opts_chunk$set(dpi = 144)
opts_chunk$set(out.width = "700px")
opts_chunk$set(dev = c("png", "pdf"))
```


```r
home <- read.csv("ny-sf-home-data.csv")
home <- cbind(data.frame(city = factor(home$in_sf)), home)
levels(home$city) <- c("NY", "SF")
head(home)
```

```
##   city in_sf beds bath   price year_built sqft price_per_sqft elevation
## 1   NY     0    2    1  999000       1960 1000            999        10
## 2   NY     0    2    2 2750000       2006 1418           1939         0
## 3   NY     0    2    2 1350000       1900 2150            628         9
## 4   NY     0    1    1  629000       1903  500           1258         9
## 5   NY     0    0    1  439000       1930  500            878        10
## 6   NY     0    0    1  439000       1930  500            878        10
```


```r
trellis.par.set(superpose.symbol = list(pch = 20, alpha = 0.2, col = c(my.col <- c("blue", "green3"), trellis.par.get("superpose.symbol")$col[3:7])))
```


```r
densityplot(~ elevation | city, data = home, groups = city, plot.points = "rug", layout = c(1, 2), xlim = c(0, 250), col = my.col)
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/unnamed-chunk-4-1.png" title="plot of chunk unnamed-chunk-4" alt="plot of chunk unnamed-chunk-4" width="700px" />

```r
xyplot(elevation ~ price_per_sqft, data = home, groups = city, col = my.col)
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/unnamed-chunk-4-2.png" title="plot of chunk unnamed-chunk-4" alt="plot of chunk unnamed-chunk-4" width="700px" />


```r
splom(~ home[3:9], data = home, groups = city, auto.key = TRUE, pscales = 0)
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/unnamed-chunk-5-1.png" title="plot of chunk unnamed-chunk-5" alt="plot of chunk unnamed-chunk-5" width="700px" />

## CART: Classification And Regression Tree (Decision Tree)

![Fig]({{ site.baseurl }}/figures/elements-stats-learning-fig-9.2.jpg)
<!-- MathJax scripts -->
<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
