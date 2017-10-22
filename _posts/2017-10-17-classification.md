---
layout: default
title: Classification
tags: [ classification ]
Rdir: "/R/2017-10-17-classification/"
---

First paragraph.

Download presentation [here]({{ site.baseurl }}/assets/machine-learning-attilagk.pdf)

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
M$complex.tree <- rpart(city ~ beds + bath + price + year_built + sqft + price_per_sqft + elevation, data = home, control = rpart.control(cp = -1))
plot(M$complex.tree, margin = 0.01)
text(M$complex.tree, col = "brown", font = 2, use.n = FALSE, all = FALSE, cex = 0.8)
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/complex-tree-1.png" title="plot of chunk complex-tree" alt="plot of chunk complex-tree" width="700px" />


```r
plotcp(M$complex.tree, upper = "splits")
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/complexity-1.png" title="plot of chunk complexity" alt="plot of chunk complexity" width="700px" />


```r
M$tree <- rpart(city ~ beds + bath + price + year_built + sqft + price_per_sqft + elevation, data = home)
plot(M$tree, margin = 0.01)
text(M$tree, col = "brown", font = 2, use.n = TRUE, all = TRUE, cex = 0.9)
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/tree-1.png" title="plot of chunk tree" alt="plot of chunk tree" width="700px" />

## Prediction

Let's predict the city at the average of each input variable taking the following values:


```r
(newhome <- data.frame(lapply(home[c(-1, -2)], function(h) round(mean(h)))))
```

```
##   beds bath   price year_built sqft price_per_sqft elevation
## 1    2    2 2020696       1959 1523           1196        40
```

Now the prediction.  Actually, it's more than mere prediction of the output classes (NY and SF) because their probability is estimated.  Note that the first splitting rule of the tree already classifies the new data point as SF because $$\mathrm{elevation} = 40 \ge 30.5$$.  Therefore the model based probability estimates are compared to the fraction of those NY and SF homes in the training data whose $$\mathrm{elevation} \ge 30.5$$, which is $$9 / 183$$.  The two kinds of probability estimate are only slightly different: they agree that $$\mathrm{Pr}(\mathrm{city} = \mathrm{SF} \mid \mathrm{elevation} \ge 30.5) \gg \mathrm{Pr}(\mathrm{city} = \mathrm{NY} \mid \mathrm{elevation} \ge 30.5)$$:


```r
nh.prob <- predict(M$tree, newhome, type = "prob")
nh.prob <- rbind(nh.prob, data.frame(NY = 9 / 183, SF = (183 - 9) / 183))
nh.prob$prob.estimate <- c("prediction", "training data, elevation >= 30.5")
nh.prob
```

```
##            NY        SF                    prob.estimate
## 1  0.04687500 0.9531250                       prediction
## 11 0.04918033 0.9508197 training data, elevation >= 30.5
```

```r
nh.prob <- reshape(nh.prob, varying = c("NY", "SF"), v.names = "probability", times = c("NY", "SF"), timevar = "city", direction = "long")
barchart(probability ~ prob.estimate, data = nh.prob, groups = city, stack = TRUE, auto.key = TRUE, scales = list(x = list(cex = 1)))
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/barchart-prob-1.png" title="plot of chunk barchart-prob" alt="plot of chunk barchart-prob" width="700px" />

The next prediction is at a sequence of increasing $$\mathrm{price\_per\_sqft}$$ in the range of the training data, while holding all other input variables at their average.


```r
nh <- cbind(newhome[-6], data.frame(price_per_sqft = seq(from = min(home$price_per_sqft), to = max(home$price_per_sqft), length.out = 50)))
nh.prob <- predict(M$tree, nh, type = "prob")
```


```r
my.xyplot <- function(fm = formula(NY ~ price_per_sqft), newdata = nh, mod = M)
    xyplot(fm, data = cbind(newdata, predict(mod$tree, newdata, type = "prob")),
           ylim = c(-0.05, 1.05), ylab = "Pr(city = NY)",
           panel = function(...) { panel.grid(h = -1, v = -1); panel.xyplot(...) })
my.xyplot()
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/effect-price-per-sqft-1.png" title="plot of chunk effect-price-per-sqft" alt="plot of chunk effect-price-per-sqft" width="700px" />

Clearly, the model based probability estimates show no dependence on $$\mathrm{price\_per\_sqft}$$, because the tree ends in a leaf if $$\mathrm{elevation} \ge 30.5$$ (the right branch of the first split).  So let's set $$\mathrm{elevation} = 30.0$$ and repeat the prediction.  This time there is a clear dependence on $$\mathrm{price\_per\_sqft}$$.  It is a striking limitation of the decision tree model that the dependence is step-like.  Note that the step is located at $$\mathrm{price\_per\_sqft} = 741.5$$, which corresponds to the second of the two splits based on $$\mathrm{price\_per\_sqft}$$.  There is a tiny step at $$1072$$ corresponding to the first of the splits based on $$\mathrm{price\_per\_sqft}$$.  This tiny step goes counter-intuitively *downward* exposing another weakness of decision trees.


```r
nh$elevation <- 30
my.xyplot()
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/effect-price-per-sqft-elevation-30-1.png" title="plot of chunk effect-price-per-sqft-elevation-30" alt="plot of chunk effect-price-per-sqft-elevation-30" width="700px" />

Finally, let's do the same type of experiment when $$\mathrm{elevation}$$ grows incrementally.  Similarly to the previous case, there is a sudden jump around a splitting threshold, which is in this case $$\mathrm{elevation} = 30.5$$, corresponding to the first (topmost) split in the tree.


```r
nh <- cbind(newhome[-7], data.frame(elevation = seq(from = min(home$elevation), to = max(home$elevation), length.out = 50)))
my.xyplot(fm = formula(NY ~ elevation))
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/effect-elevation-1.png" title="plot of chunk effect-elevation" alt="plot of chunk effect-elevation" width="700px" />

<!-- MathJax scripts -->
<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>