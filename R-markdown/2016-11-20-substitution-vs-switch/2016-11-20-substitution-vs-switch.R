param <- list(n = 100, m = 5)

sample.ld.switch <- function(x = 1:4, p = param) {
    n <- p$n
    m <- p$m
    helper <- function(i) {
        switch(x[i],
               list(name = "normal", sample = rnorm(n), i = factor(i)),
               list(name = "t", sample = rt(n, df=m), i = factor(i)),
               list(name = "gamma", sample = rgamma(n, shape=m) / m, i = factor(i)),
               list(name = "rounded.normal", sample = round(m * rnorm(n)) / m, i = factor(i)))
    }
    lapply(seq_along(x), helper)
}

plot.ls <- function(s = sample.ld.switch(), guess = FALSE, call2strip = FALSE, ...) {
    dt <- do.call(rbind, lapply(s, data.frame))
    d.names <- sapply(s, getElement, "name")
    tp <-
        qqmath(~ sample | i, data = dt,
               strip = strip.custom(factor.levels = d.names),
               strip.left =
                   if(call2strip)
                       strip.custom(factor.levels = sapply(s, getElement, "call"), par.strip.text = list(cex = 0.7))
                   else FALSE,
                   xlab = "normal quantiles", ylab = "sample quantiles", as.table = TRUE, between = list(x = 1, y = 1),
                   abline = c(0, 1), pch = "+",
                   ...)
    if(guess) tp <- update(tp, strip = strip.custom(factor.levels = as.character(seq_along(s))),
                           strip.left = FALSE, main = "Guess distributions!")
    print(tp)
    if(guess) d.names
}

l.distr <- list(normal = quote(rnorm(n = n)),
                t = quote(rt(n = n, df = m)),
                gamma = quote(rgamma(n = n, shape = m) / m),
                rounded.normal = quote(round(m * rnorm(n = n)) / m))

sample.ld.subs <- function(x = 1:4, ld = l.distr, p = param) {
    helper <- function(i) {
        le <- list(e = ld[[x[i]]])
        cl <- eval(substitute(substitute(e, p), le))
        list(name = names(ld[x[i]])[[1]],
             call = deparse(cl),
             sample = eval(cl),
             i = factor(i))
    }
    lapply(seq_along(x), helper)
}

# extend list of distributions
l.distr$beta <- quote((rbeta(n = n, shape1 = m, shape2 = m) - 0.5) * m)
l.distr$normal.cauchy.mix <- quote(c(rnorm(n = n - m), rcauchy(n = m)))
