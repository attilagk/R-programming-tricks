---
layout: post
title: Reshaping Data from Longitudinal and Factorial Experiments
tags: [ reshape, Iris, lattice, experimental-design, factor ]
---

## Motivation

Graphic packages like `lattice` and `ggplot2` work best when data are presented in **long format** as opposed to **wide format** into which data are typically imported and in which it is usually convenient to perform calculations.  For example `datasets::morley` is a data frame in long format, which allows the simple expression `lattice::xyplot(Speed ~ Run | Expt, data = morley)` to produce a complex trellis display, in which the speed of light measured by Michelson in 1879 plays the role of a response variable, the measurement run that of a predictor and the experimental replicate acts as a conditioning variable.

To grasp the difference between the long and wide format, consider $$$$m$$$$ experimental units (a.k.a. records, observations, ...) on which $$$$n$$$$ variables have been observed.  We will specify the $$n$$ units with **ids** $$u_1,...,u_i,...,u_m$$, and among variables with a set $$\mathcal{V}$$ of labels/classes where $$\mathcal{V} = \{v_1,...,v_j,...,v_n\}$$.  It is helpful to regard such labels as generalized indices and any set like $$\mathcal{V}$$ a **index set** for variables (and not for units).  In the `morley` data set ids are run numbers so that $$u_1 = 1,..., u_m = m$$, whereas variable indices $$v_i$$ are experiment numbers but for many real-world data sets neither type of indices are integers (e.g. patient id).

The data set may be written as the statistical table

$$\begin{matrix}
\text{id} & \text{var } v_{1} & \cdots & \text{var } v_{n} \\
1 & Y_{1v_1} & \cdots & Y_{1v_n} \\
\vdots & \vdots & \ddots & \vdots \\
m & Y_{mv_1} & \cdots & Y_{mv_n} \\
\end{matrix}$$

It is this table that is modeled in R as a data frame in wide format.  The long format, in the other hand, corresponds to the following table:

$$\begin{matrix}
\text{id} & \text{var} & \text{index set } \mathcal{V} \\
1 & Y_{1v_1} & v_1 \\
\vdots & \vdots & \vdots \\
m & Y_{mv_1} & v_1 \\
\vdots & \vdots & \vdots \\
1 & Y_{1v_n} & v_n \\
\vdots & \vdots & \vdots \\
m & Y_{mv_n} & v_n \\
\end{matrix}$$

Thus, the set of $$n$$ variables (in $$n$$ columns) have been concatenated into a single variable in a single column named $$\text{var}$$ and a new column was introduced to label each datum with the appropriate generalized index.

From a purely syntactic viewpoint any data set in wide format may be converted into long format and vice versa.  The R functions `utils::stack` and `stats::reshape` do exactly that so they are invaluable time savers when preparing data for `lattice` for example.  But semantically it is only sensible to convert wide format into the long one shown above when the index set $$\mathcal{V}$$ models some meaningful relation among all variables to each other.  For instance, $$\mathcal{V}$$ may be a set of genes $$\{\mathrm{gene}_1,...,\mathrm{gene}_n\}$$ in a genomic experiment indexing a measure of gene expression.  Other examples for index set $$\mathcal{V}$$ include the set of *floral parts* such as $$\{\mathrm{sepal},\mathrm{petal}\}$$, a set of *directions* $$\{\mathrm{length},\mathrm{width}\}$$ along which *floral parts* have been measured, or a set of *Iris* species such as $$\{\mathrm{setosa},\mathrm{versicolor},\mathrm{virginica}\}$$.  Those familiar with R's `datasets` package may have instantly identified the latter example as the classic Fisher--Anderson data set residing in `datasets::iris`.

## Longitudinal experiments and generalization of time

In general not all $$n$$ variables are necessarily related to each other in a way that justifies indexing them with a single index set.  Take longitudinal studies as an example.  In such experiments there are say $$p < n$$ time points $$\{v_1\le,...,\le v_p\}$$ at which a variable $$Y$$ is measured (on each of the $$m$$ units) so that the sequence of variables $$\{Y_{v_1},...,Y_{v_p}\}$$ yields a time series.  Those variables are called **time-varying** in the help documentation of `reshape` and their relation is time.  The remaining $$q\equiv n - p$$ variables are called time-constant in `reshape`'s help but instead I will use here the term **time-invariant**.  Time-invariant variables are race and gender of study subjects, etc.

More generally, the index set $$\mathcal{V}=\{v_1,...,v_p\}$$ need not have a temporal interpretation and need not even form an ordered set as we saw in the case of a genomic experiment in which $$\mathcal{V}$$ is a set of $$p$$ genes and gene expression might be called "gene-varying".  If $$p < n$$ then the remaining $$q$$ variables $$\{v_{p+1},...,v_n\}$$ are "gene-invariant".  For instance these may represent metabolic---and hence non-genetic---properties.  These $$q$$ variables may even be related to each other in a systematic way that justifies indexing them from a single index set $$\mathcal{V}'$$ that is distinct from $$\mathcal{V}$$.  E.g. besides genome-wide gene expression the concentration of the same metabolite may be measured in different organs so that $$\mathcal{V}'=\{\text{blood},\text{liver},...\}$$.

So given a $$p$$-sized index set $$\mathcal{V}$$ it might be appropriate to call the first $$p$$ variables "$$\mathcal{V}$$-varying" and the remaining $$q$$ variables "$$\mathcal{V}$$-invariant".  These are illustrated by the second and third column, respectively, of the table below.

|  index set        | $$\mathcal{V}=\{v_1,...,v_p\}\;$$ | $$\mathcal{V'}=\{v_{p+1},...,v_n\}$$ |
|:-----------------:|:-------------------------------:|:------------------------------------:|
| property of variable | $$\mathcal{V}$$-varying      |   $$\mathcal{V}$$-invariant          |
|:-----------------:|:-------------------------------:|:------------------------------------:|
|  example I        |           time                  |               gender                 |
|  example II       |        gene identity            |               organ                  |

The important points to realize about the data sets of our current focus:

1. we have multiple index sets $$\mathcal{V},\;\mathcal{V}'$$ (and possibly more) indexing a total of $$n$$ variables
1. for each variable $$Y_{\cdot v_j}$$ the index $$v_j$$ belongs to one and only one index set
1. among all index sets only $$\mathcal{V}$$ provides a rule to reshape the data from wide to long format (see below).

In the wide format we have

$$\begin{matrix}
\text{id} & \text{var } v_{1} & \cdots & \text{var } v_{p} & \text{var } v_{p+1} & \cdots & \text{var } v_{n} \\
1 & Y_{1v_1} & \cdots & Y_{1v_p} & Y_{1v_{p+1}} & \cdots & Y_{1v_n} \\
\vdots & \vdots & \ddots & \vdots & \vdots & & \vdots \\
m & Y_{mv_1} & \cdots & Y_{mv_p} & Y_{mv_{p+1}} & \cdots & Y_{mv_n} \\
\end{matrix}$$

To arrive at a long format the `reshape` function lets index set $$\mathcal{V}$$ guide the concatenation of the first $$p$$ variables $$\{Y_{\cdot v_1},...,Y_{\cdot v_p}\}$$ as before.  But now `reshape` also must take care of the remaining $$q$$ variables indexed by $$\mathcal{V}'$$ rather than $$\mathcal{V}$$.  It does so by replicating those and storing them in the $$p+1,...n$$ columns, so the long format looks like

$$\begin{matrix}
\text{id} & \mathcal{V}\text{-varying var} & \text{index set } \mathcal{V} & \text{var } p+1 & \cdots & \text{var } n \\
1 & Y_{1v_1} & v_1 & Y_{1v_{p+1}} & \cdots & Y_{1v_{n}} \\
\vdots & \vdots & \vdots & \vdots & & \vdots \\
m & Y_{mv_1} & v_1 & Y_{mv_{p+1}} & \cdots & Y_{mv_{n}}  \\
\vdots & \vdots & \vdots & \vdots & & \vdots \\
1 & Y_{1v_p} & v_p & Y_{1v_{p+1}} & \cdots & Y_{1v_{n}} \\
\vdots & \vdots & \vdots & \vdots & & \vdots \\
m & Y_{mv_p} & v_p & Y_{mv_{p+1}} & \cdots & Y_{mv_{n}} \\
\end{matrix}$$

Note that the simple-to-use `stack` is of little help in this case so that only `reshape` can be used.  Also note that `idvar` corresponds to $$\text{id}$$ in the long format and `timevar` to the index set $$\mathcal{V}$$.

## Factorial experiments and sequential reshape

There is at least another major advantage of `reshape` over `stack` but this feature is rather vaguely documented so I attempt to elucidate both its usefulness and the way it may have been meant to be used in R.

The *Iris* data set, despite its miniscule size in today's standards, illustrates a particularly important structure of data that is the result of factorial (crossed) experimental design.  Here we have multiple index sets say $$\mathcal{V}_\mathrm{sp}$$, $$\mathcal{V}_\mathrm{fp}$$ and $$\mathcal{V}_\mathrm{dir}$$ for the factors *species* ($$\mathrm{sp}$$), *floral part* ($$\mathrm{fp}$$), and measurement *direction* ($$\mathrm{dir}$$), respectively.  These are fully **crossed factors** that collectively specify a set of variables reporting on the *size* of floral parts.  To set a practical goal we will sequentially reshape `iris` into a form which will allow us to write `xyplot(Size ~ X | Direction * Floral.Part, data = iris.long.format, groups = Species)` to produce a nested trellis display (i.e. one with multiple conditioning variables).  Note that we will augment the original `iris` data with a variable $$X$$, which we will consider as covariate (i.e. continuous predictor) of size---more about it soon.

In the preceding section we also dealt with variables indexed by multiple sets but the kind of data sets `iris` exemplifies is different:

1. we *still* have multiple index sets $$\mathcal{V}_a,\;\mathcal{V}_b,...$$ indexing a total of $$n$$ variables
1. however, for each variable $$Y_{\cdot w_j}$$ the index $$w_j = (v_{aj_a},v_{bj_b},...)$$ is a combination of all types of indices $$v_{xj_x}\in\mathcal{V}_x\;(x=a,b,...)$$, which correspond to all levels crossed factors
1. data may be sensibly reshaped according to any of the index sets $$\mathcal{V}_{x_1}$$ (i.e. any of the factors)
1. moreover, a **sequence of reshapes** may be performed if an initial reshape according to $$\mathcal{V}_{x_1}$$ is followed by one according to another index set $$\mathcal{V}_{x_2}$$

Let's see the special meaning of these points in case of the *Iris* data while we work our way towards the desired plot!

First we generate a covariate $$X$$ based on sepal length with `set.seed(13); iris$X <- iris$Sepal.Length + rnorm(nrow(iris))`.  With `head(iris)` or `str(iris)` we see that the present format of our data is

$$\begin{matrix}
\text{id} & \text{Sepal.Length} & \text{Sepal.Width} & \text{Petal.Length} & \text{Petal.Width} & \text{Species} & \text{var } X \\
1 & Y_{1(\text{set, sep, len})} & Y_{1(\text{set, sep, wid})} &  Y_{1(\text{set, pet, len})} &  Y_{1(\text{set, pet, wid})} & \text{setosa} & X_1 \\
\vdots & \vdots & \vdots & \vdots & \vdots & \vdots & \vdots \\
m & Y_{m(\text{set, sep, len})} & Y_{m(\text{set, sep, wid})} &  Y_{m(\text{set, pet, len})} &  Y_{m(\text{set, pet, wid})} & \text{setosa} & X_m \\
\vdots & \vdots & \vdots & \vdots & \vdots & \vdots & \vdots \\
1 & Y_{1(\text{vir, sep, len})} & Y_{1(\text{vir, sep, wid})} &  Y_{1(\text{vir, pet, len})} &  Y_{1(\text{vir, pet, wid})} & \text{virginica} & X_1 \\
\vdots & \vdots & \vdots & \vdots & \vdots & \vdots & \vdots \\
m & Y_{m(\text{vir, sep, len})} & Y_{m(\text{vir, sep, wid})} &  Y_{m(\text{vir, pet, len})} &  Y_{m(\text{vir, pet, wid})} & \text{virginica} & X_m \\
\end{matrix}$$

To connect this specific notation to the general one introduced above note that a size variable like $$Y_{\cdot(\text{set, pet, len})}$$ conforms to the general form $$Y_{\cdot (v_{aj_a},v_{bj_b},...)}$$.  The present shape of the data may be called wide and our goal motivates us to reshape it to long format.  Realize the following points

* from the present form is in fact intermediate because we can reshape the data in both towards a "completely" long or wide format
* a single reshape is sufficient to reach that wide format
* a sequence of two reshapes are needed for the long format
* two such sequences exist:
    1. sequence *F.D*: reshape first according to *floral part* and then according to *direction*
    1. sequence *D.F*: the *F.D* in reverse order
* the long formats that result from *F.D* and *D.F* should not differ in any meaningful way

"Meaningful way" means that although the two long format data frames may differ in e.g. the order of their components/columns, such differences must not have any impact on the way functions like `xyplot` extract information from them.
This requirement is safely fulfilled as long as data frame components are extracted by names rather than integer or boolean indices---as `xyplot` does it---or if precautions are taken in integer and boolean indexing.

So, we are to generate the following long format (up to any "meaningless" differences):

$$\begin{matrix}
\text{id} & \text{Size} & \text{Species} & \text{Floral.Part} & \text{Direction} & \text{var } X \\
1 & Y_{1(\text{set, sep, len})} & \text{setosa} &  \text{sepal} &  \text{length} & X_1 \\
\vdots & \vdots & \vdots & \vdots & \vdots & \vdots & \\
m & Y_{m(\text{set, sep, len})} & \text{setosa} &  \text{sepal} &  \text{length} & X_m \\
\vdots & \vdots & \vdots & \vdots & \vdots & \vdots & \\
\vdots & \vdots & \vdots & \vdots & \vdots & \vdots & \\
\vdots & \vdots & \vdots & \vdots & \vdots & \vdots & \\
1 & Y_{1(\text{vir, pet, wid})} & \text{virginica} &  \text{petal} &  \text{width} & X_1 \\
\vdots & \vdots & \vdots & \vdots & \vdots & \vdots & \\
m & Y_{m(\text{vir, pet, wid})} & \text{virginica} &  \text{petal} &  \text{width} & X_m, \\
\end{matrix}$$

where the large gap in the middle represents all possible combinations of *species*, *floral part* and *direction* beyond the ones shown.  The specific permutation (order) of these combinations depends on whether we take the *F.D* or the *D.F* sequence but that difference carries no information for `xyplot` similarly to the order of components in the data frame.  (What does matter, though, is the order of levels of components `Species`, `Floral.Part` and `Direction` when those are represented by ordered factors.)

{% include R-markdown2html/2016-07-14-sequential-reshapes.html %}
