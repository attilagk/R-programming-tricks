







## Performing sequential reshapes

The prerequisite of our goal (the trellis plot of our extended version of *Iris* data) is to reshape the data into the completely long format either taking the *F.D* or the *D.F* sequence of two reshapes. The next two code blocks represent the *F.D* sequence.  The first reshape is according to *floral part* and the result is assigned to `iris.F`.


```r
iris.F <-
    reshape(iris, direction = "long",
            varying = list(c("Sepal.Length", "Petal.Length"), c("Sepal.Width", "Petal.Width")),
            v.names = c("Length", "Width"),
            timevar = "Floral.Part", times = c("Sepal", "Petal"),
            idvar = "id1")
```

Note how the `varying` argument is a list of equal-length vectors whose length is the number of levels (in this case two) of the factor (*floral part*) according to which we perform the reshape.  That the length of the list is also two is merely a coincidence.  In general the list may be both shorter or longer than each of its own vector components.  The concluding section will discuss how that is related to the crossed factors of the experiments.

The second reshape in the *F.D* sequence is according to *direction* yielding data frame assigned to the name `iris.F.D`.


```r
iris.F.D <-
    reshape(iris.F, direction = "long",
            varying = c("Length", "Width"), v.names = "Size",
            timevar = "Direction", times = c("Length", "Width"),
            drop = "id1")
```

As we see, `iris.F.D` structures data in the desired long-format (compare with the most recent table):

```r
head(iris.F.D, n = 2)
```

```
##          Species        X Floral.Part Direction Size id
## 1.Length  setosa 5.654327       Sepal    Length  5.1  1
## 2.Length  setosa 4.619728       Sepal    Length  4.9  2
```

```r
tail(iris.F.D, n = 2)
```

```
##             Species        X Floral.Part Direction Size  id
## 299.Width virginica 5.577147       Petal     Width  2.3 299
## 300.Width virginica 6.408354       Petal     Width  1.8 300
```

The next code block performs the reverse sequential reshape *D.F* i.e. first according to *direction* and then according to *floral part*.


```r
iris.D <-
    reshape(iris, direction = "long",
            varying = list(c("Sepal.Length", "Sepal.Width"), c("Petal.Length", "Petal.Width")),
            v.names = c("Sepal", "Petal"),
            timevar = "Direction", times = c("Length", "Width"),
            idvar = "id1")
iris.D.F <-
    reshape(iris.D, direction = "long",
            varying = c("Sepal", "Petal"), v.names = "Size",
            timevar = "Floral.Part", times = c("Sepal", "Petal"),
            drop = "id1")
```

The "head" and "tail" of the new data frame `iris.D.F` are the same as those of `iris.D.F` (up to the order of the `Floral.Part` and `Direction` components).


```r
head(iris.D.F, n = 2)
```

```
##         Species        X Direction Floral.Part Size id
## 1.Sepal  setosa 5.654327    Length       Sepal  5.1  1
## 2.Sepal  setosa 4.619728    Length       Sepal  4.9  2
```

```r
iris.D.F[201, ]
```

```
##              Species        X Direction Floral.Part Size  id
## 201.Sepal versicolor 5.654327     Width       Sepal  3.2 201
```

```r
tail(iris.D.F, n = 2)
```

```
##             Species        X Direction Floral.Part Size  id
## 299.Petal virginica 5.577147     Width       Petal  2.3 299
## 300.Petal virginica 6.408354     Width       Petal  1.8 300
```

But the middle portion of the two data frames differ due to the different permutation of crossed factors.  That difference, however, has no statistical meaning similarly to the order of columns.  Both types of difference are implementation details that well designed software tools should be able to ignore.

```r
iris.F.D[201, ]
```

```
##               Species        X Floral.Part Direction Size  id
## 201.Length versicolor 5.654327       Petal    Length  4.7 201
```

```r
iris.D.F[201, ]
```

```
##              Species        X Direction Floral.Part Size  id
## 201.Sepal versicolor 5.654327     Width       Sepal  3.2 201
```

## The goal attained

Having sequentially shaped the *Iris* data---supplemented with our covariate $X$---into two long-format data frames, we are ready to produce the trellis display.  Starting with `iris.F.D` (resulting from the "forward" sequence)

```r
xyplot(Size ~ X | Direction * Floral.Part, data = iris.F.D, groups = Species, auto.key = list(columns = 3))
```

![plot of chunk correct.F](figure/correct.F-1.png)

Using `iris.D.F` ("reverse" sequence) yields

```r
xyplot(Size ~ X | Direction * Floral.Part, data = iris.D.F, groups = Species, auto.key = list(columns = 3))
```

![plot of chunk correct.D](figure/correct.D-1.png)

The two plots are identical since the differences between `iris.F.D` and `iris.D.F`---or equivalently between the corresponding sequences of reshapes---are immaterial from the viewpoint of `xyplot`, as discussed earlier.

## How to call `reshape` and why so?

The crucial but poorly documented feature of `reshape` is how "time"-varying variables must be specified for the `varying` argument in factorial experiments like the *Iris* study.  Suppose there are $k$ factors  $a_1,...,a_k$, whose levels count $p_{a_1},...,p_{a_k}$ (as we saw these factors are equivalent to index sets $\mathcal{V}_{a_1},...,\mathcal{V}_{a_k}$).  With the notation we introduced for longitudinal setups $\prod_{i=1}^k p_{a_1} = p\le n$ because these $k$ factors are fully crossed.  The remaining $q\equiv n - p$ variables, if any, are not crossed with the previous $k$ factors and consequently play a passive role in any of the reshapes.  In our extended *Iris* example $p_\mathrm{sp} = 3, \; p_\mathrm{fp} = 2, \; p_\mathrm{dir} = 2$ and $q=1$ because there is a single uncrossed variable: covariate $X$.

To illustrate the sequential use of `reshape` we will

1. reshape our extended `iris` into a completely wide format `iris.wide`
1. then we will reshape `iris.wide` according to *species* to obtain `iris.2`
1. we will check if `iris.2` is any different from `iris` (it should not be apart from implementation details)
1. discuss the semantics behind the syntax of calling `reshape`

### Reshape `iris` to a completely wide format

It will be convenient to assign the value of the `varying` argument to reshape to a name, say `varying.v`.

```r
(varying.v <-
    lapply(c(paste0(".Sepal", c(".Length", ".Width")),
             paste0(".Petal", c(".Length", ".Width"))),
           function(x) paste0(c("Setosa", "Versicolor", "Virginica"), x)))
```

```
## [[1]]
## [1] "Setosa.Sepal.Length"     "Versicolor.Sepal.Length"
## [3] "Virginica.Sepal.Length" 
## 
## [[2]]
## [1] "Setosa.Sepal.Width"     "Versicolor.Sepal.Width"
## [3] "Virginica.Sepal.Width" 
## 
## [[3]]
## [1] "Setosa.Petal.Length"     "Versicolor.Petal.Length"
## [3] "Virginica.Petal.Length" 
## 
## [[4]]
## [1] "Setosa.Petal.Width"     "Versicolor.Petal.Width"
## [3] "Virginica.Petal.Width"
```
That `varying.v` is indeed the correct argument will be shown and discussed shortly.

Additionally, we create an `id` variable, whose role is to identify all $m$ observations in the sequence $1,...,m$ repeated for all $3$ levels of *species*.

```r
iris$id <- rep(seq_len(nrow(iris) / 3), 3)
```

Now, the syntax of the desired reshape is this:

```r
iris.wide <-
    reshape(iris, direction = "wide",
            varying = varying.v,
            v.names = c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"),
            timevar = "Species", times = c("setosa", "versicolor", "virginica"),
            idvar = "id")
str(iris.wide)
```

```
## 'data.frame':	50 obs. of  14 variables:
##  $ X                      : num  5.65 4.62 6.48 4.79 6.14 ...
##  $ id                     : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ Setosa.Sepal.Length    : num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
##  $ Setosa.Sepal.Width     : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
##  $ Setosa.Petal.Length    : num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
##  $ Setosa.Petal.Width     : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
##  $ Versicolor.Sepal.Length: num  7 6.4 6.9 5.5 6.5 5.7 6.3 4.9 6.6 5.2 ...
##  $ Versicolor.Sepal.Width : num  3.2 3.2 3.1 2.3 2.8 2.8 3.3 2.4 2.9 2.7 ...
##  $ Versicolor.Petal.Length: num  4.7 4.5 4.9 4 4.6 4.5 4.7 3.3 4.6 3.9 ...
##  $ Versicolor.Petal.Width : num  1.4 1.5 1.5 1.3 1.5 1.3 1.6 1 1.3 1.4 ...
##  $ Virginica.Sepal.Length : num  6.3 5.8 7.1 6.3 6.5 7.6 4.9 7.3 6.7 7.2 ...
##  $ Virginica.Sepal.Width  : num  3.3 2.7 3 2.9 3 3 2.5 2.9 2.5 3.6 ...
##  $ Virginica.Petal.Length : num  6 5.1 5.9 5.6 5.8 6.6 4.5 6.3 5.8 6.1 ...
##  $ Virginica.Petal.Width  : num  2.5 1.9 2.1 1.8 2.2 2.1 1.7 1.8 1.8 2.5 ...
##  - attr(*, "reshapeWide")=List of 5
##   ..$ v.names: chr  "Sepal.Length" "Sepal.Width" "Petal.Length" "Petal.Width"
##   ..$ timevar: chr "Species"
##   ..$ idvar  : chr "id"
##   ..$ times  : Factor w/ 3 levels "setosa","versicolor",..: 1 2 3
##   ..$ varying: chr [1:4, 1:3] "Setosa.Sepal.Length" "Setosa.Sepal.Width" "Setosa.Petal.Length" "Setosa.Petal.Width" ...
```

The structure of the new data format looks as expected

```r
str(iris.wide)
```

```
## 'data.frame':	50 obs. of  14 variables:
##  $ X                      : num  5.65 4.62 6.48 4.79 6.14 ...
##  $ id                     : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ Setosa.Sepal.Length    : num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
##  $ Setosa.Sepal.Width     : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
##  $ Setosa.Petal.Length    : num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
##  $ Setosa.Petal.Width     : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
##  $ Versicolor.Sepal.Length: num  7 6.4 6.9 5.5 6.5 5.7 6.3 4.9 6.6 5.2 ...
##  $ Versicolor.Sepal.Width : num  3.2 3.2 3.1 2.3 2.8 2.8 3.3 2.4 2.9 2.7 ...
##  $ Versicolor.Petal.Length: num  4.7 4.5 4.9 4 4.6 4.5 4.7 3.3 4.6 3.9 ...
##  $ Versicolor.Petal.Width : num  1.4 1.5 1.5 1.3 1.5 1.3 1.6 1 1.3 1.4 ...
##  $ Virginica.Sepal.Length : num  6.3 5.8 7.1 6.3 6.5 7.6 4.9 7.3 6.7 7.2 ...
##  $ Virginica.Sepal.Width  : num  3.3 2.7 3 2.9 3 3 2.5 2.9 2.5 3.6 ...
##  $ Virginica.Petal.Length : num  6 5.1 5.9 5.6 5.8 6.6 4.5 6.3 5.8 6.1 ...
##  $ Virginica.Petal.Width  : num  2.5 1.9 2.1 1.8 2.2 2.1 1.7 1.8 1.8 2.5 ...
##  - attr(*, "reshapeWide")=List of 5
##   ..$ v.names: chr  "Sepal.Length" "Sepal.Width" "Petal.Length" "Petal.Width"
##   ..$ timevar: chr "Species"
##   ..$ idvar  : chr "id"
##   ..$ times  : Factor w/ 3 levels "setosa","versicolor",..: 1 2 3
##   ..$ varying: chr [1:4, 1:3] "Setosa.Sepal.Length" "Setosa.Sepal.Width" "Setosa.Petal.Length" "Setosa.Petal.Width" ...
```

### Reverse: from `iris.wide` to `iris.2`

Next, the reverse reshape operation is carried out.  The syntax is conveniently the same as the forward equivalent except for the `direction` argument, which has now the value `"long"`.

```r
iris.2 <-
    reshape(iris.wide, direction = "long",
            varying = varying.v,
            v.names = c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"),
            timevar = "Species", times = c("setosa", "versicolor", "virginica"),
            idvar = "id")
```

### Checking consistency between `iris` and `iris.2`

`iris` and `iris.2` do differ in their attributes, the order of their components, and in the fact that `Species` is a factor in `iris` but a character vector in `iris.2`:

```r
str(iris)
```

```
## 'data.frame':	150 obs. of  7 variables:
##  $ Sepal.Length: num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
##  $ Sepal.Width : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
##  $ Petal.Length: num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
##  $ Petal.Width : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
##  $ Species     : Factor w/ 3 levels "setosa","versicolor",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ X           : num  5.65 4.62 6.48 4.79 6.14 ...
##  $ id          : int  1 2 3 4 5 6 7 8 9 10 ...
```

```r
str(iris.2)
```

```
## 'data.frame':	150 obs. of  7 variables:
##  $ X           : num  5.65 4.62 6.48 4.79 6.14 ...
##  $ id          : int  1 2 3 4 5 6 7 8 9 10 ...
##  $ Species     : chr  "setosa" "setosa" "setosa" "setosa" ...
##  $ Sepal.Length: num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
##  $ Sepal.Width : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
##  $ Petal.Length: num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
##  $ Petal.Width : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
##  - attr(*, "reshapeLong")=List of 4
##   ..$ varying:List of 4
##   .. ..$ : chr  "Setosa.Sepal.Length" "Versicolor.Sepal.Length" "Virginica.Sepal.Length"
##   .. ..$ : chr  "Setosa.Sepal.Width" "Versicolor.Sepal.Width" "Virginica.Sepal.Width"
##   .. ..$ : chr  "Setosa.Petal.Length" "Versicolor.Petal.Length" "Virginica.Petal.Length"
##   .. ..$ : chr  "Setosa.Petal.Width" "Versicolor.Petal.Width" "Virginica.Petal.Width"
##   ..$ v.names: chr  "Sepal.Length" "Sepal.Width" "Petal.Length" "Petal.Width"
##   ..$ idvar  : chr "id"
##   ..$ timevar: chr "Species"
```

But do they differ in a "meaningful" way?  Reordering `iris.2` and converting its `Species` component into factor shows

```r
iris.2$Species <- as.factor(iris.2$Species)
all.equal(iris, iris.2[names(iris)])
```

```
## [1] "Attributes: < Component \"row.names\": Modes: numeric, character >"              
## [2] "Attributes: < Component \"row.names\": target is numeric, current is character >"
```
Thus, the answer is: `iris.2` does not have any meaningful differences from `iris`, demonstrating the reversibility of reshape operations with the `reshape` function.

### The semantics and syntax of `reshape` and its `varying` argument

Now that our data are in a completely wide format, a sequence of $k$ reshapes must be used to reach the (completely) long format.  Clearly, the sequence of reshapes follows a chosen sequence of factors $a_1,...,a_k$.

First we want to reshape according to factor $a_1$ (equivalently index set $\mathcal{V}_{a_1}$.  With what arguments should we call `reshape`?  In particular what should be the value of the `varying` argument?  Some experimentation shows that `varying` must be a list of character vectors each of length $p_{a_1}$


This is because all $p_{a_1}$ levels of factor $a_1$ must appear in each vector.  The number of such vectors---the length of the list itself---is $p / p_{a_1} = \prod_{i=2}^k p_{a_i}$ because we need to consider all combinations of the *remaining* $k-1$ factors.  In the second reshape $a_1$ plays no more role so it is omitted from `varying`.  Now the list has $p / (p_{a_1} p_{a_2}) = \prod_{i=3}^k p_{a_i}$ vector components and each vector is $p_{a_2}$ long.  The sequence continues with $i=3,...,k$.

If we follow this rule then the last, $k$-th, reshape is special in the sense that `varying` is a list with a single component, a $p_{a_k}$-length vector since there are no more factors to combine.  Therefore this trivial list may be `unlist`ed: replaced by its only component (the $p_{a_k}$-length vector) without any loss of information.  In fact, this is probably by far the most frequent way in which `reshape` is called since it was designed for longitudinal experiments where with only $k=1$ "factor" present: time.

## The lessons learned

The multiplicity of data representations is not only computationally convenient but also facilitates the clarification and expression of certain semantic relationships between variables.  Unlike `stack` the `reshape` function allows representation of various experimental setups by partitioning variables into related sets and indexing those separately.  We only briefly mentioned how longitudinal setups can be modeled with `reshape` and how this can be generalized to cases where instead of time points genes or other objects serve as indices to a set of related variables. `reshape`'s documentation provides details and examples on---possibly generalized---longitudinal applications.

In contrast, we examined more deeply how `reshape` is also capable of dealing with the equally important but more complex case of factorial experiments, where $k$ number of combined index sets correspond to $k$ crossed factors.  In the *Iris* data set the factors are *species*, *floral part*, and measurement *direction* so $k=3$.  Moreover, we supplemented `iris` with a covariate $X$ with the intention of $X$ having a relation to the original variables akin to time-invariant variables relate time-varying ones in longitudinal studies in a sense that data reshaping is only governed by the latter.  This demonstrated how flexibly `reshape` can be adapted to various setups.

We also saw that as many reshapes can be performed as many factors are present.  Therefore various *sequences* of reshapes may transform a completely wide-format data frame to a completely long-format one.  Thus, intermediate formats exist whenever we have $k>2$ factors.  Which sequence of reshapes we chose is immaterial, or at least should be, from the viewpoint of well-designed software such as the trellis display plotting `xyplot`.
