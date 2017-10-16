---
layout: default
title: Fixed and Mixed Regression Models
tags: [ regression ]
Rdir: "/R/2017-10-16-fixed-and-mixed-models/"
---


```r
library(lme4)
```

```
## Loading required package: Matrix
```

```
## Loading required package: methods
```

```r
library(lattice)
lattice.options(default.args = list(as.table = TRUE))
lattice.options(default.theme = "standard.theme")
opts_chunk$set(dpi = 144)
opts_chunk$set(out.width = "700px")
opts_chunk$set(dev = c("png", "pdf"))
```

## Demo

### Data

The `sleepstudy` dataset from the `lme4` package is chosen for the demonstration.  Below is the description of `sleepstudy`

>The average reaction time per day for subjects in a sleep deprivation study. On day 0 the subjects had their normal amount of sleep. Starting that night they were restricted to 3 hours of sleep per night. The observations represent the average reaction time on a series of tests given each day to each subject. 

Plotting the average reaction time against the test day for each subject...


```r
xyplot(Reaction ~ Days | Subject, data = sleepstudy, layout = c(6, 3))
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/observed-only-1.png" title="plot of chunk observed-only" alt="plot of chunk observed-only" width="700px" />

<!-- MathJax scripts -->
<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
