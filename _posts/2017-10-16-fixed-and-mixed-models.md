---
layout: default
title: Fixed and Mixed Regression Models
tags: [ regression ]
Rdir: "/R/2017-10-16-fixed-and-mixed-models/"
featimg: "observed-only-1.png"
---

Fixed and mixed models are fitted to the sleepstudy dataset to investigate how human reaction slows down with sleep deprivation.

## Sleep study

A sleep study was carried out to investigate whether and how reaction time slows down with sleep deprivation.  The corresponding `sleepstudy` dataset is part of the `lme4` package; below is the description of `sleepstudy`:

>The average reaction time per day for subjects in a sleep deprivation study. On day 0 the subjects had their normal amount of sleep. Starting that night they were restricted to 3 hours of sleep per night. The observations represent the average reaction time on a series of tests given each day to each subject. 

This data set is ideal to compare fixed and mixed effects models.  The outline of this article is as follows:

1. inspect the data
1. mathematical description and fitting of models
   1. F1, a fixed effects model
   1. M1 and M2, two mixed models
1. fitting the models
1. statistical inference (using F1, M1, M2)

## Inspecting the data

First some prerequisites...


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
tp <- list(superpose.line = list(col = c("black", "gray40", "red", "gray40", "darkgreen", "blue", trellis.par.get("superpose.line")$col[-1:-5])))
tp$superpose.symbol <- tp$superpose.line
tp$plot.symbol <- tp$plot.symbol <- list(col = tp$superpose.line$col[1])
```

The human subjects of `sleepstudy` are numbered in a way that's a little inconvenient for our purposes, so let's simplify and renumber them from 1 to 18 and look at the first 3 and last 3 data points!


```r
sleepstudy <- sleepstudy
levels(sleepstudy$Subject) <- seq_along(levels(sleepstudy$Subject))
rbind(head(sleepstudy, 3), tail(sleepstudy, 3))
```

```
##     Reaction Days Subject
## 1   249.5600    0       1
## 2   258.7047    1       1
## 3   250.8006    2       1
## 178 343.2199    7      18
## 179 369.1417    8      18
## 180 364.1236    9      18
```

Now let's plot the average reaction time against the test day for each subject!


```r
xyplot(Reaction ~ Days | Subject, data = sleepstudy, layout = c(6, 3), par.settings = tp)
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/observed-only-1.png" title="plot of chunk observed-only" alt="plot of chunk observed-only" width="700px" />

The plot shows that subjects vary with respect to...

1. their initial reaction time (at day 0)
1. how their reaction time changes systematically with days
1. how scattered the data points are (noise, non-systematic variation)

But the plot also reveals common patterns shared by the subjects: for most of them the reaction time is initially $$\approx 250$$ milliseconds but this value tends to rise systematically with days suggesting that sleep deprivation slows down reaction.

We seek models that are able to capture as much of the varying and shared patterns noted above as possible.  We'll evaluate that ability in terms of how well each model fits the data.  Then we will use the models to test if the dependence of reaction time indeed varies across subjects and whether in a typical or average subject that dependence is indeed positive, as the scatter plot above suggests.

## Mathematical description of models

Before plunging into model descriptions it helps to make some considerations about notation.  We'll index the 18 subjects with $$g=1,...,G=18$$.  Observations are indexed with $$i$$.  Data points for the reaction time (the response variable) and days of sleep deprivation (the explanatory variable) are denoted as $$y_{gi}$$ and $$x_{gi}$$, respectively.  The noise is denoted as $$\varepsilon_{gi}$$.  Any other Greek letter ($$\beta, \gamma, \delta, \alpha$$) will denote regression coefficients.

### F1, a fixed effects model

This is the familiar normal linear model for each subject $$g$$.

$$
\begin{eqnarray*}
y_{gi} &=& \alpha_g + x_i \beta_g + \varepsilon_{gi} \\\\
\varepsilon_{gi} &\sim& \mathcal{N}(0, \sigma_g^2).
\end{eqnarray*}
$$

Thus $$F1$$ is a set of such models that are isolated from each other in the sense that they share no parameters or data.

In hypothesis testing we'll make use of a "null model" $$F0$$, which is a constrained version of $$F1$$ by asserting that

$$
\begin{equation}
F0: \; \beta_g = 0
\end{equation}
$$

Thus, $$F0$$ assumes independence between reaction time and days of sleep deprivation.

### M1 and M2, two mixed models

We consider two mixed models that allow dependence of reaction time on days of sleep deprivation, $$M1$$ and $$M2$$.  In addition, we'll make use of a third mixed model, a "null model" $$M0$$, in which reaction time is independent of days.  These are nested: $$M2 \supset M1 \supset M0$$, meaning that $$M1$$ and $$M0$$ can be derived from $$M2$$ by constraining certain parameters.  Although both $$M1$$ and $$M2$$ account for the increasing tendency of reaction time with days (while $$M0$$ does not), only $$M2$$ allows subjects to vary with respect to how reaction time depends on days.  All 3 models $$M0, M1, M2$$ allow the average reaction time to vary across subjects.

After the above qualitative description we specify the models qualitatively.  Both models share the following form and properties:

$$
\begin{eqnarray*}
y_{gi} &=& \alpha + a_g + x_i (\beta + b_g) + \varepsilon_{gi} \\\\
a \equiv (a_1, ..., a_G) &\sim& \mathcal{N}(0, \Omega_a) \\\\
\varepsilon_{gi} &\sim& \mathcal{N}(0, \sigma^2).
\end{eqnarray*}
$$

In addition, $$\beta$$ is an unknown fixed parameter both in $$M1$$ and $$M2$$.

The only difference between $$M1$$ and $$M2$$ is $$b \equiv (b_1, ..., b_G)$$; in $$M2$$ it is allowed to vary randomly while in $$M1$$ it is constrained to be 0.  $$M0$$ differs from $$M1$$ in that $$\beta$$ is constrained to zero.
$$
\begin{eqnarray*}
M2: \; b &\sim& \mathcal{N}(0, \Omega_b) \\\\
M1: \; b &=& 0 \\\\
M0: \; b &=& 0, \; \beta = 0
\end{eqnarray*}
$$

## Fitting the models

The `stats` package provides the `lm` function for fitting (normal, linear) fixed effects models.  Our fixed model F1 is the set of all such (sub)models, each fitted to a different subject.


```r
subjects <- levels(sleepstudy$Subject)
names(subjects) <- subjects
M <- list()
M$F0 <-
    lapply(subjects,
           function(s) {
               df <- subset(sleepstudy, Subject == s)
               lm(Reaction ~ 1, data = df)
           })
M$F1 <-
    lapply(subjects,
           function(s) {
               df <- subset(sleepstudy, Subject == s)
               lm(Reaction ~ Days, data = df)
           })
```


```r
M$M0 <- lmer(Reaction ~ (1 | Subject), sleepstudy)
M$M1 <- lmer(Reaction ~ Days + (1 | Subject), sleepstudy)
M$M2 <- lmer(Reaction ~ Days + (Days | Subject), sleepstudy)
```


```r
df <- cbind(sleepstudy,
            data.frame(yhat.F0 = unlist(lapply(M$F0, predict)),
                       yhat.F1 = unlist(lapply(M$F1, predict)),
                       yhat.M0 = predict(M$M0),
                       yhat.M1 = predict(M$M1),
                       yhat.M2 = predict(M$M2)))
names(df) <- sub("Days", "X", names(df))
df.long <- reshape(df, varying = varying <- c("Reaction", "yhat.F0", "yhat.F1", "yhat.M0", "yhat.M1", "yhat.M2"), v.names = "Y", timevar = "Type", direction = "long", times = varying)
df.long$Type <- factor(df.long$Type)
levels(df.long$Type) <- c("data", "F0", "F1", "M0", "M1", "M2")
```

The TODO lines represent the fitted line under `M2`, the TODO lines under `M1` (the observed data remain cyan).


```r
xyplot(Y ~ X | Subject, data = df.long, groups = Type, type = c("p", rep("l", 5)), subset = Type %in% c("data", "F0"), distribute.type = TRUE, par.settings = tp)
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/data-F0-1.png" title="plot of chunk data-F0" alt="plot of chunk data-F0" width="700px" />


```r
xyplot(Y ~ X | Subject, data = df.long, groups = Type, type = c("p", rep("l", 5)), subset = Type %in% c("data", "F1"), distribute.type = TRUE, par.settings = tp)
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/data-F1-1.png" title="plot of chunk data-F1" alt="plot of chunk data-F1" width="700px" />


```r
xyplot(Y ~ X | Subject, data = df.long, groups = Type, type = c("p", rep("l", 5)), subset = Type %in% c("data", "M0"), distribute.type = TRUE, par.settings = tp)
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/data-M0-1.png" title="plot of chunk data-M0" alt="plot of chunk data-M0" width="700px" />


```r
xyplot(Y ~ X | Subject, data = df.long, groups = Type, type = c("p", rep("l", 5)), subset = Type %in% c("data", "M1"), distribute.type = TRUE, par.settings = tp)
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/data-M1-1.png" title="plot of chunk data-M1" alt="plot of chunk data-M1" width="700px" />


```r
xyplot(Y ~ X | Subject, data = df.long, groups = Type, type = c("p", rep("l", 5)), subset = Type %in% c("data", "M2"), distribute.type = TRUE, par.settings = tp)
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/data-M2-1.png" title="plot of chunk data-M2" alt="plot of chunk data-M2" width="700px" />


```r
xyplot(Y ~ X | Subject, data = df.long, groups = Type, type = c("p", rep("l", 5)), subset = ! Type %in% c("F0", "M0"), distribute.type = TRUE, par.settings = tp)
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/data-F1-M1-M2-1.png" title="plot of chunk data-F1-M1-M2" alt="plot of chunk data-F1-M1-M2" width="700px" />

## Statistical inference (using F1, M1, M2)

### Hypothesis testing


```r
H <- list()
H$pval <- sapply(names(M$F1), function(x) anova(M$F0[[x]], M$F1[[x]])[2, "Pr(>F)"])
# alternative method, which gives same result
all.equal(H$pval,
          sapply(M$F1, function(m) summary(m)$coefficients["Days", "Pr(>|t|)"]))
```

```
## [1] TRUE
```

```r
H$col <- tp$superpose.line$col[3]
H$ANOVA <- "F0 vs F1"
H <- data.frame(H)
H$par <- paste0("beta_", seq_along(H$pval))
H$H0 <- paste0("beta_", seq_along(H$pval), " = 0")
```


```r
H <- rbind(H,
           data.frame(pval = anova(M$M0, M$M1)[2, "Pr(>Chisq)"],
                      col = tp$superpose.line$col[5],
                      ANOVA = "M0 vs M1",
                      par = "beta",
                      H0 = "beta = 0"),
           data.frame(pval = anova(M$M0, M$M2)[2, "Pr(>Chisq)"],
                      col = tp$superpose.line$col[6],
                      ANOVA = "M0 vs M2",
                      par = "beta, b",
                      H0 = "beta = 0, b = 0"),
           data.frame(pval = anova(M$M1, M$M2)[2, "Pr(>Chisq)"],
                      col = tp$superpose.line$col[6],
                      ANOVA = "M1 vs M2",
                      par = "b",
                      H0 = "b = 0")
           )
```

```
## refitting model(s) with ML (instead of REML)
## refitting model(s) with ML (instead of REML)
## refitting model(s) with ML (instead of REML)
```

```r
H$par <- factor(H$par, levels = rev(H$par), ordered = TRUE)
H$H0 <- factor(H$H0, levels = rev(H$H0), ordered = TRUE)
```


```r
dotplot(H0 ~ log10(pval), data = H, par.settings = list(dot.symbol = list(col = as.character(H$col))))
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/log-p-val-1.png" title="plot of chunk log-p-val" alt="plot of chunk log-p-val" width="700px" />

### Prediction



What would reaction time be for each person after 14 or 21 days of sleep deprivation?


```r
days <- c(14, 21)
names(days) <- paste0("day.", days)
pred <- list()
pred$F1 <- t(sapply(M$F1, predict, data.frame(Days = days)))
dotplot(pred$F1, auto.key = TRUE, xlab = "predicted reaction time", ylab = "subject")
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/lm-pred-1.png" title="plot of chunk lm-pred" alt="plot of chunk lm-pred" width="700px" />

## Mixed models

Fit models.

## Inference


```r
t(sapply(M$F1, function(m) summary(m)$coefficients[2, c(1, 4)]))
```

```
##     Estimate     Pr(>|t|)
## 1  21.764702 3.264657e-03
## 2   2.261785 4.931443e-02
## 3   6.114899 1.980757e-03
## 4   3.008073 2.552687e-01
## 5   5.266019 7.550229e-02
## 6   9.566768 1.914426e-01
## 7   9.142045 1.583426e-04
## 8  12.253141 6.352350e-04
## 9  -2.881034 5.064731e-02
## 10 19.025974 5.530467e-06
## 11 13.493933 2.285006e-05
## 12 19.504017 8.617903e-05
## 13  6.433498 3.324544e-02
## 14 13.566549 1.306668e-03
## 15 11.348109 1.860407e-04
## 16 18.056151 1.378251e-04
## 17  9.188445 1.040424e-02
## 18 11.298073 1.716323e-05
```

### Hypothesis testing

Does the dependence on days really vary across subjects or are subjects identical with respect to the dependence?  We take the latter possibility as the null hypothesis
$$
\begin{equation*}
H_0 : \; \gamma_1\neq...\neq\gamma_G.
\end{equation*}
$$

The most powerful test for $$H_0$$ is the likelihood ratio test comparing the `M2` model to its constrained version `M1`:


```r
anova(M2, M1)
```

```
## Error in anova(M2, M1): object 'M2' not found
```

Thus we may reject $$H_0$$ at significance level $$<10^{-9}$$ and conclude that the data supports overwhelmingly better the alternative hypothesis that the dependence of `Reaction` on `Days` varies across `Subject`s.

## Implications to our study

Mixed models would afford **joint modeling** of the data across all 30 genes in a way that the effect of each predictor (e.g. Age) could possibly be divided into a global component (a fixed effect shared by all genes) and a gene-specific component (a gene-specific random effect).  Compared to the previous strategy of separate gene-specific models the proposed joint modeling would extend the formally testable hypotheses to those that involve all genes jointly.  Thus the main advantages would be

1. **increased power** of currently unresolved hypotheses e.g. the overall effect of Age taking all genes into account
1. **more hypotheses** may be tested by separating gene-specific effects from effects shared by all genes


Note that the increased power follows from the fact that joint modeling allows borrowing of strength from data across all genes and that powerful likelihood ratio tests could be easily formulated by comparing nested models.   Additional benefits:

* better separation of technical and biological effects
    * for instance, we could model Institution-specific effect of RIN or RNA_batch and gene-specific effect of Age, Dx, or Ancestry.1
* shrinkage: for genes with many observations let the data "speak for themselves" but for data-poor genes shrink gene-specific parameters to a global average
* more straight-forward model comparison
    * various model families and data transformations
    * nested models (likelihood ratio tests)
<!-- MathJax scripts -->
<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
