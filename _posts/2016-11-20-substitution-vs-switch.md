---
layout: post
title: "Substitution vs Switch"
---

## Summary

1. general task: evaluate arbitrary elements of a sequence of expressions
1. specific task: produce normal Q--Q plots for a sequence of distributions
1. two implementation strategies are discussed: one based on `switch` and another on `substitute`
1. using `substitute` demands more abstract programming but affords more flexibility

## A toy problem: recognizing distributions

This exercise appeared in the practicals for chapter 2 of A.C. Davison's Statistical Models (Cambridge University Press, 2003).

Suppose we want to compare a sequence of distributions to the standard normal distribution.  We base the comparison on random samples from the distributions, which we visualize with normal quantile-quantile (Q--Q) plots.  For instance, consider the Q--Q plots in the figure titled "Four distributions" below.

To put a twist on this toy problem the sequence $$x$$ of distributions may contain repeated elements, such as $$x = \{\mathrm{gamma}(p), \mathrm{normal}(\mu = 0, \sigma^2 = 1), \mathrm{gamma}(p), \mathrm{gamma}(p)\}$$, where $$p$$ is a vector of parameters for the gamma distribution family.  This might be useful if we want to create the following quiz:

1. *teacher*: generates a sample from each distribution in the sequence $$x$$ with possibly repeated distributions
    * she/he will sample using either the `sample.d.switch` or the `sample.d.substitute` implementation
1. *student*: creates Q--Q plots from the sequence of samples and guesses $$x$$, the sequence of distributions
    * she/he will plot the samples using `plot.ls`

To keep things simple, we will sample the same number of points $$n$$ from each distribution and for the parameters of all distributions will be based on a single number $$m$$ with the constraint that all distributions should be on comparable scale so that the principal difference is in the shape of the distributions.  We store $$n$$ and $$m$$ in the list `param`.

{% include R-markdown2html/2016-11-20-substitution-vs-switch.html %}
