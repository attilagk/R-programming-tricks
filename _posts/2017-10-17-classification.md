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
library(rpart)
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

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/elevation-price-per-sqft-1.png" title="plot of chunk elevation-price-per-sqft" alt="plot of chunk elevation-price-per-sqft" width="700px" />

```r
xyplot(elevation ~ price_per_sqft, data = home, groups = city, col = my.col)
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/elevation-price-per-sqft-2.png" title="plot of chunk elevation-price-per-sqft" alt="plot of chunk elevation-price-per-sqft" width="700px" />


```r
splom(~ home[3:9], data = home, groups = city, auto.key = TRUE, pscales = 0)
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/splom-1.png" title="plot of chunk splom" alt="plot of chunk splom" width="700px" />

## CART: Classification And Regression Tree (Decision Tree)

Figure 9.2 from Hastie et al 2009 explaining partitions and CART.

![Fig]({{ site.baseurl }}/figures/elements-stats-learning-fig-9.2.jpg)


```r
M <- list()
M$tree <- rpart(city ~ beds + bath + price + year_built + sqft + price_per_sqft + elevation, data = home)
```


```r
plotcp(M$tree, upper = "splits")
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/complexity-1.png" title="plot of chunk complexity" alt="plot of chunk complexity" width="700px" />


```r
plot(M$tree, margin = 0.05)
text(M$tree, col = "brown", font = 2, use.n = TRUE, all = TRUE, cex = 0.9)
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/tree-1.png" title="plot of chunk tree" alt="plot of chunk tree" width="700px" />
<!-- MathJax scripts -->
<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
