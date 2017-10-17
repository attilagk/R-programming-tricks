---
layout: default
title: Fixed and Mixed Regression Models
tags: [ regression ]
Rdir: "/R/2017-10-16-fixed-and-mixed-models/"
featimg: "observed-only-1.png"
---

Fixed and mixed models are fitted to the sleepstudy dataset to investigate how human reaction slows down with sleep deprivation.

## Data

The `sleepstudy` dataset from the `lme4` package is chosen for the demonstration.  Below is the description of `sleepstudy`

>The average reaction time per day for subjects in a sleep deprivation study. On day 0 the subjects had their normal amount of sleep. Starting that night they were restricted to 3 hours of sleep per night. The observations represent the average reaction time on a series of tests given each day to each subject. 


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

Plotting the average reaction time against the test day for each subject...


```r
xyplot(Reaction ~ Days | Subject, data = sleepstudy, layout = c(6, 3))
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/observed-only-1.png" title="plot of chunk observed-only" alt="plot of chunk observed-only" width="700px" />

## Fixed models


```r
xyplot(Reaction ~ Days | Subject, data = sleepstudy, layout = c(6, 3),
       panel = function(x, y) {
           panel.xyplot(x, y)
           panel.lmline(x, y)
       })
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/observed-lm-1.png" title="plot of chunk observed-lm" alt="plot of chunk observed-lm" width="700px" />


```r
subjects <- levels(sleepstudy$Subject)
names(subjects) <- subjects
M <- list()
M$fixed <-
    lapply(subjects,
           function(s) {
               df <- subset(sleepstudy, Subject == s)
               lm(Reaction ~ Days, data = df)
           })
```

### Prediction


```r
dotplot(as.matrix(data.frame(observed = subset(sleepstudy, Days == 0, "Reaction", drop = TRUE),
                             predicted = sapply(M$fixed, function(m) summary(m)$coefficients[1, "Estimate", drop = FALSE]))),
        auto.key = TRUE, xlab = "reaction time at day 0", ylab = "subject")
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/lm-obs-pred-1.png" title="plot of chunk lm-obs-pred" alt="plot of chunk lm-obs-pred" width="700px" />


```r
days <- c(14, 21)
names(days) <- paste0("day.", days)
pred <- list()
pred$fixed <- t(sapply(M$fixed, predict, data.frame(Days = days)))
dotplot(pred$fixed, auto.key = TRUE, xlab = "predicted reaction time", ylab = "subject")
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/lm-pred-1.png" title="plot of chunk lm-pred" alt="plot of chunk lm-pred" width="700px" />

## Mixed models


```r
M1 <- lmer(Reaction ~ Days + (Days | Subject), sleepstudy)
M2 <- lmer(Reaction ~ Days + (1 | Subject), sleepstudy)
df <- cbind(sleepstudy, data.frame(yhat.M1 = predict(M1), yhat.M2 = predict(M2)))
```

The magenta lines represent the fitted line under `M1`, the green lines under `M2` (the observed data remain cyan).


```r
xyplot(Reaction + yhat.M1 ~ Days | Subject, data = df, type = "l", ylab = "Reaction", layout = c(6, 3),
       auto.key = list(text = c("observed", "predicted by M1"), points = FALSE, lines = TRUE))
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/observed-predicted-M1-1.png" title="plot of chunk observed-predicted-M1" alt="plot of chunk observed-predicted-M1" width="700px" />


```r
xyplot(Reaction + yhat.M2 ~ Days | Subject, data = df, type = "l", ylab = "Reaction", layout = c(6, 3),
       auto.key = list(text = c("observed", "predicted by M2"), points = FALSE, lines = TRUE))
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/observed-predicted-M2-1.png" title="plot of chunk observed-predicted-M2" alt="plot of chunk observed-predicted-M2" width="700px" />


```r
df <- cbind(sleepstudy, data.frame(yhat.M1 = predict(M1), yhat.M2 = predict(M2)))
xyplot(Reaction + yhat.M1 + yhat.M2 ~ Days | Subject, data = df, type = "l", ylab = "Reaction", layout = c(6, 3),
       auto.key = list(text = c("observed", "predicted by M1", "predicted by M2"), points = FALSE, lines = TRUE))
```

<img src="{{ site.baseurl }}/R/2017-10-16-fixed-and-mixed-models/figure/observed-predicted-1.png" title="plot of chunk observed-predicted" alt="plot of chunk observed-predicted" width="700px" />

## Inference


```r
t(sapply(M$fixed, function(m) summary(m)$coefficients[2, c(1, 4)]))
```

```
##      Estimate     Pr(>|t|)
## 308 21.764702 3.264657e-03
## 309  2.261785 4.931443e-02
## 310  6.114899 1.980757e-03
## 330  3.008073 2.552687e-01
## 331  5.266019 7.550229e-02
## 332  9.566768 1.914426e-01
## 333  9.142045 1.583426e-04
## 334 12.253141 6.352350e-04
## 335 -2.881034 5.064731e-02
## 337 19.025974 5.530467e-06
## 349 13.493933 2.285006e-05
## 350 19.504017 8.617903e-05
## 351  6.433498 3.324544e-02
## 352 13.566549 1.306668e-03
## 369 11.348109 1.860407e-04
## 370 18.056151 1.378251e-04
## 371  9.188445 1.040424e-02
## 372 11.298073 1.716323e-05
```

### Models

We consider two models, $$M1$$ and $$M2$$.  These are nested: $$M1 \supset M2$$, meaning that $$M1$$ is more general while $$M2$$ is a constrained version of $$M1$$.  Both models account for two shared characteristics among subjects: the increasing tendency of reaction time with days, captured by parameter $$\beta$$, as well as the roughly $$300ms$$ day- and subject-averaged reaction time, $$\mu$$.  Moreover, both models also account for the subject-specific variation about $$\mu$$ by including a separate day-averaged reaction time parameter $$\delta_g$$ for each subject $$g = 1,...,G$$.  However, only $$M1$$ allows for subject-specific dependence of reaction time on days, which is expressed by parameters $$\gamma_1\neq...\neq\gamma_G$$.  In contrast, $$M2$$ assumes that subjects are identical in that respect so $$\gamma_1=...=\gamma_G$$.

After the above qualitative description we specify the models qualitatively.  Both models share the following form and properties:
$$
\begin{eqnarray*}
y_{gi} &=& \mu + x_i (\beta + \gamma_g) + \delta_g + \varepsilon_{gi} \\\\
\delta \equiv (\delta_1, ..., \delta_G) &\sim& \mathcal{N}(0, \Omega_\delta) \\\\
\varepsilon_{gi} &\sim& \mathcal{N}(0, \sigma^2).
\end{eqnarray*}
$$
In addition, $$\beta$$ is an unknown fixed parameter both in $$M1$$ and $$M2$$.

The only difference between $$M1$$ and $$M2$$ is $$\gamma \equiv (\gamma_1, ..., \gamma_G)$$; in $$M1$$ it is allowed to vary randomly while in $$M2$$ it is constrained to be 0:
$$
\begin{eqnarray*}
M1: \; \gamma &\sim& \mathcal{N}(0, \Omega_\gamma) \\\\
M2: \; \gamma &=& 0
\end{eqnarray*}
$$

### Hypothesis testing

Does the dependence on days really vary across subjects or are subjects identical with respect to the dependence?  We take the latter possibility as the null hypothesis
$$
\begin{equation*}
H_0 : \; \gamma_1\neq...\neq\gamma_G.
\end{equation*}
$$

The most powerful test for $$H_0$$ is the likelihood ratio test comparing the `M1` model to its constrained version `M2`:


```r
anova(M1, M2)
```

```
## refitting model(s) with ML (instead of REML)
```

```
## Data: sleepstudy
## Models:
## M2: Reaction ~ Days + (1 | Subject)
## M1: Reaction ~ Days + (Days | Subject)
##    Df    AIC    BIC  logLik deviance  Chisq Chi Df Pr(>Chisq)    
## M2  4 1802.1 1814.8 -897.04   1794.1                             
## M1  6 1763.9 1783.1 -875.97   1751.9 42.139      2  7.072e-10 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
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
