


```r
param <- list(n = 100, m = 5)
```

## The student's Q--Q plotting function

The `plot.ls` function defined below uses `qqmath` of the lattice package to produce a trellis plot, where each panel is the normal Q--Q plot of one sample from the sequence of samples `s`.  Our `plot.ls` expects `s` to be implemented as an unnamed list of named lists.  Each named list has an element named `family` that specifies the family of the distribution, an element named `sample` that contains the sample points, and an element named `i` that specifies the index of the distribution in the sequence.

If `guess` argument is `FALSE`, then  `plot.ls` will display the name of the distribution family on the top of each panel.  Otherwise the student must guess the families.  In the latter case she/he can check the answers by printing the return value of `plot.ls`.  A few more details on `plot.ls` will be given later.


```r
plot.ls <- function(s, guess = FALSE, call2strip = FALSE, ...) {
    dt <- do.call(rbind, lapply(s, data.frame))
    d.names <- sapply(s, getElement, "family")
    tp <-
        qqmath(~ sample | i, data = dt,
               strip = strip.custom(factor.levels = d.names),
               strip.left =
                   if(call2strip)
                       strip.custom(factor.levels = sapply(s, getElement, "call"), par.strip.text = list(cex = 0.65))
                   else FALSE,
                   xlab = "normal quantiles", ylab = "sample quantiles", as.table = TRUE, between = list(x = 1, y = 1),
                   abline = c(0, 1), pch = "+",
                   ...)
    if(guess) tp <- update(tp, strip = strip.custom(factor.levels = as.character(seq_along(s))),
                           strip.left = FALSE, main = "Guessing distribution")
    print(tp)
    if(guess) d.names
}
```

## The teacher's sampling function using "switch"

`sample.d.switch` specifies four distributions.  Each distribution is represented as a named list with the `family`, `sample` and `i` components mentioned above.  The unnamed list of these named lists appears the (unnamed) list of "alternatives" passed `switch` in the body of `sample.d.switch`.  The arguments of `sample.d.switch` itself are `x` and `p`.  The `x` argument is a sequence of possibly repeated indices of arbitrary length; each index selects one of the four distributions specified within `switch` therefore must range between 1 and 4.  The `p` argument contains information on sample sizes and parameter values, and defaults to the `param` list defined above.


```r
sample.d.switch <- function(x = 1:4, p = param) {
    n <- p$n
    m <- p$m
    helper <- function(i) {
        switch(x[i],
               list(family = "normal", sample = rnorm(n), i = factor(i)),
               list(family = "t", sample = rt(n, df=m), i = factor(i)),
               list(family = "gamma", sample = rgamma(n, shape=m) / m, i = factor(i)),
               list(family = "rounded.normal", sample = round(m * rnorm(n)) / m, i = factor(i)))
    }
    lapply(seq_along(x), helper)
}
```

Let's see how the teacher generates a sequence `s` of samples using `sample.d.switch`!  She/he decides to pass the default `x = 1:4` argument, which results in the original sequence of four unique (not repeated) distributions.


```r
set.seed(1993) # the year R appeared
str(s <- sample.d.switch(x = 1:4))
```

```
## List of 4
##  $ :List of 3
##   ..$ family: chr "normal"
##   ..$ sample: num [1:100] -0.5005 -0.3772 0.0435 -0.6507 1.1533 ...
##   ..$ i     : Factor w/ 1 level "1": 1
##  $ :List of 3
##   ..$ family: chr "t"
##   ..$ sample: num [1:100] -1.074 1.623 -0.817 0.934 -0.133 ...
##   ..$ i     : Factor w/ 1 level "2": 1
##  $ :List of 3
##   ..$ family: chr "gamma"
##   ..$ sample: num [1:100] 0.47 0.819 0.98 0.566 1.206 ...
##   ..$ i     : Factor w/ 1 level "3": 1
##  $ :List of 3
##   ..$ family: chr "rounded.normal"
##   ..$ sample: num [1:100] 0.4 0.2 -0.8 0.6 1.8 0.6 0 -0.2 0 0.6 ...
##   ..$ i     : Factor w/ 1 level "4": 1
```

The teacher tells the student to first plot the sequence of samples with `plot.ls` and display the families as well so that the student can analyze their shapes before having to solve the "real" exercise: the reverse task, that is.


```r
library(lattice)
plot.ls(s = s, guess = FALSE, main = "Four distributions")
```

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png)

The student notes that, relative to the standard normal distribution, the t distribution has heavier tails, the gamma distribution is not supported on negative numbers, and that the effect of rounding is a step-like pattern in the Q--Q plot.

Now the teacher challenges the student with a sequence of six samples, three of which (#2, #3, #5) are from the t distribution, two (#4, #6) from the normal distribution and one (#1) from the gamma.


```r
s <- sample.d.switch(x = c(3, 2, 2, 1, 2, 1))
```

When the student plots these samples with `guess = TRUE`, this is what she/he sees:


```r
library(lattice)
ans <- plot.ls(s = s, guess = TRUE)
```

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8-1.png)

Once she/he guessed the distributions, the correct answers are printed.


```r
ans
```

```
## [1] "gamma"  "t"      "t"      "normal" "t"      "normal"
```

## The teacher's sampling function using "substitute"

The teacher is dissatisfied by two limitations of `sample.d.switch`.

Firstly, it would be important for the student to understand the role of parameters in the shape of various distributions, and also to get accustomed to the syntax of the R functions in the stats package.  In fact, the student wrote `plot.ls` with these considerations in mind when she/he included an argument named `call2strip`.  If `call2strip = TRUE`, then `plot.ls` displays on the right side of each panel the expression with which a function like `rgamma` was called in  `sample.d.switch`.  However, the return value of `sample.d.switch` contains no information on those function calls.

The second limitation is the lack of modularity that follows from the fact that the set of four distinct distributions are tied to the body of `sample.d.switch`.  How can more distinct distributions be added to the exercise without changing the body of the sampling function?

The second limitation might be overcome by somehow passing the list of "alternatives", say `ld`, to the main sampling function that would then call `switch` with `ld` as arguments.  But that strategy would have to be involve `do.call` as well as the prepending of `ld` with an index that selects a single element from it.  But the first limitation can be overcome in a straight-forward way only by using `substitute`.

So, the teacher implements `sample.d.substitute`.  The `x` and `p` arguments have the same semantics as in the case of `sample.d.switch`.   The new argument is `ld`, the unnamed list of named lists.  As the code shows, the `switch` in the body of the `helper` function was replaced by expressions that involve two calls to `substitute` within the same expression.  This mechanism allows sequential evaluation in two steps: at the first step a call object is obtained and assigned to `cl`, while at the second step `cl` itself is evaluated to produce the `sample`.


```r
sample.d.substitute <- function(x = 1:4, ld, p = param) {
    helper <- function(i) {
        le <- list(e = ld[[x[i]]])
        cl <- eval(substitute(substitute(e, p), le))
        list(family = names(ld[x[i]])[[1]],
             call = deparse(cl),
             sample = eval(cl),
             i = factor(i))
    }
    lapply(seq_along(x), helper)
}
```

Now the set of four distinct distributions can be stored in a `l.distr`, a list of lists, which exists separately from `sample.d.substitute`.


```r
l.distr <- list(normal = quote(rnorm(n = n)),
                t = quote(rt(n = n, df = m)),
                gamma = quote(rgamma(n = n, shape = m) / m),
                rounded.normal = quote(round(m * rnorm(n = n)) / m))
```

But before the teacher tests `sample.d.substitute` she/he decides to add two more distinct distributions to `l.distr`.


```r
# extend list of distributions
l.distr$beta <- quote((rbeta(n = n, shape1 = m, shape2 = m) - 0.5) * m)
l.distr$normal.cauchy.mix <- quote(c(rnorm(n = n - m), rcauchy(n = m)))
```

Now, the system is ready for the test.


```r
s <- sample.d.substitute(x = 1:6, ld = l.distr)
plot.ls(s = s, guess = FALSE, call2strip = TRUE, main = "Six distributions")
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13-1.png)

As can be seen, the new implementation removed the limitations, and thus `sample.d.substitute` is superior to `sample.d.switch`.
