---
layout: default
title: Classification
tags: [ classification ]
Rdir: "/R/2017-10-17-classification/"
featimg: "tree-1.png"
---

Decision tree model is fitted to toy data on homes in New York and San Francisco (NY, SF).  Along the way overfitting is illustrated.  The optimally fitted tree is used to classify some test data as either NY or SF.

Download the related presentation [here]({{ site.baseurl }}/assets/machine-learning-attilagk.pdf)

## Data and analytical tools

We are going to use the home data and the machine learning approach called decision tree or CART (Classification And Regression Tree) from [A visual introduction to machine learning](http://www.r2d3.us/visual-intro-to-machine-learning-part-1/), referred to here as *visual intro*.  As CART implementation we are going to take advantage of the `rpart` package.  As usual in this blog, we opt for `lattice` graphics.


```r
library(lattice)
library(rpart)
lattice.options(default.args = list(as.table = TRUE))
lattice.options(default.theme = "standard.theme")
opts_chunk$set(dpi = 144)
opts_chunk$set(out.width = "700px")
opts_chunk$set(dev = c("png", "pdf"))
```

Now read the data...


```r
home <- read.csv("ny-sf-home-data.csv")
home <- cbind(data.frame(city = factor(home$in_sf)), home)
levels(home$city) <- c("NY", "SF")
head(home, n = 2)
```

```
##   city in_sf beds bath   price year_built sqft price_per_sqft elevation
## 1   NY     0    2    1  999000       1960 1000            999        10
## 2   NY     0    2    2 2750000       2006 1418           1939         0
```

```r
tail(home, n = 2)
```

```
##     city in_sf beds bath  price year_built sqft price_per_sqft elevation
## 491   SF     1    1    1 649000       1983  850            764       163
## 492   SF     1    3    2 995000       1956 1305            762       216
```

So our data are 492 observations on homes in two cities: New York and San Francisco ($$\mathrm{NY},\mathrm{SF}$$).  We'll treat $$\mathrm{city}$$ (equivalent to the $$\mathrm{in\_sf}$$ variable) as a categorical output with classes $$\mathrm{NY},\mathrm{SF}$$.  The rest of variables (except for $$\mathrm{in\_sf}$$) will be treated as input.

Here we reproduce the scatter plot matrix from *visual intro*.


```r
trellis.par.set(superpose.symbol = list(pch = 20, alpha = 0.2, col = c(my.col <- c("blue", "green3"), trellis.par.get("superpose.symbol")$col[3:7])))
splom(~ home[3:9], data = home, groups = city, auto.key = TRUE, pscales = 0)
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/splom-1.png" title="plot of chunk splom" alt="plot of chunk splom" width="700px" />

Elevation seems like an input variable that is informative for distinguishing NY from SF.  But the empirical distribution of elevation for NY overlaps considerably with SF at lower elevations.  Therefore additional variables like $$\mathrm{price\_per\_sqft}$$ would be useful for training a good classifier.


```r
densityplot(~ elevation | city, data = home, groups = city, plot.points = "rug", layout = c(1, 2), xlim = c(0, 250), col = my.col)
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/elevation-price-per-sqft-1.png" title="plot of chunk elevation-price-per-sqft" alt="plot of chunk elevation-price-per-sqft" width="700px" />

```r
xyplot(elevation ~ price_per_sqft, data = home, groups = city, col = my.col, auto.key = TRUE)
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/elevation-price-per-sqft-2.png" title="plot of chunk elevation-price-per-sqft" alt="plot of chunk elevation-price-per-sqft" width="700px" />

## CART / decision tree

This figure 9.2 from Hastie et al 2009 explains the recursive partitioning of CART.  *Visual intro* provides elegant dynamic visualization of the fitting process.

![Fig]({{ site.baseurl }}/figures/elements-stats-learning-fig-9.2.jpg)

We first fit the decision tree with `control = rpart.control(cp = -1)`, which allows the tree to grow beyond optimal size and thus overfit the data.


```r
M <- list()
M$complex.tree <- rpart(city ~ beds + bath + price + year_built + sqft + price_per_sqft + elevation, data = home, control = rpart.control(cp = -1))
plot(M$complex.tree, margin = 0.01)
text(M$complex.tree, col = "brown", font = 2, use.n = FALSE, all = FALSE, cex = 0.8)
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/complex-tree-1.png" title="plot of chunk complex-tree" alt="plot of chunk complex-tree" width="700px" />

The table and plot show the complexity parameter table at 7 different "prunings" sequentially nested in the overfitted tree above.  8 splits correspond to the optimal pruning.


```r
printcp(M$complex.tree)
```

```
## 
## Classification tree:
## rpart(formula = city ~ beds + bath + price + year_built + sqft + 
##     price_per_sqft + elevation, data = home, control = rpart.control(cp = -1))
## 
## Variables actually used in tree construction:
## [1] bath           elevation      price          price_per_sqft
## [5] sqft           year_built    
## 
## Root node error: 224/492 = 0.45528
## 
## n= 492 
## 
##           CP nsplit rel error  xerror     xstd
## 1  0.5803571      0   1.00000 1.00000 0.049313
## 2  0.0892857      1   0.41964 0.43750 0.039549
## 3  0.0267857      3   0.24107 0.26339 0.032169
## 4  0.0089286      5   0.18750 0.24107 0.030953
## 5  0.0066964      6   0.17857 0.24107 0.030953
## 6  0.0000000      8   0.16518 0.23214 0.030444
## 7 -1.0000000     17   0.16518 0.23214 0.030444
```

```r
plotcp(M$complex.tree, upper = "splits")
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/complexity-1.png" title="plot of chunk complexity" alt="plot of chunk complexity" width="700px" />

Thus the optimal tree is the one below and this model will be used for the classification tasks in the next section.  Notice how only a subset of input variables appear on the tree so that the rest are deemed uninformative.  Moreover, $$\mathrm{elevation}$$ and $$\mathrm{price\_per\_sqft}$$ each appear at two splits, which underscores their importance.


```r
M$tree <- rpart(city ~ beds + bath + price + year_built + sqft + price_per_sqft + elevation, data = home)
plot(M$tree, margin = 0.01)
text(M$tree, col = "brown", font = 2, use.n = TRUE, all = TRUE, cex = 0.9)
```

<img src="{{ site.baseurl }}/R/2017-10-17-classification/figure/tree-1.png" title="plot of chunk tree" alt="plot of chunk tree" width="700px" />

## Classification

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
