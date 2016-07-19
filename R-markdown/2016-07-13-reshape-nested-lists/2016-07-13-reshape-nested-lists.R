library(lattice)
lattice.options(default.theme = standard.theme)

str(iris)
iris$Predictor <- iris$Petal.Length + rnorm(nrow(iris))


iris.l <-
   reshape(# second reshape
           reshape(iris, # first reshape
                   v.names = l.w <- c("Length", "Width"), varying = names(iris)[1:4],
                   timevar = "Flower.part", times = c("Petal", "Sepal"),
                   idvar = "id1", direction = "long"),
           v.names = "Response", varying = c("Length", "Width"),
           timevar = "Measure", times = c("Length", "Width"),
           direction = "long", drop = "id1")


iris.l2 <-
   reshape(# second reshape
           reshape(iris, # first reshape
                   v.names = l.w <- c("Petal", "Sepal"), varying = names(iris)[1:4],
                   timevar = "Measure", times = c("Length", "Width"),
                   idvar = "id1", direction = "long"),
           v.names = "Response", varying = c("Petal", "Sepal"),
           timevar = "Flower.part", times = c("Petal", "Sepal"),
           direction = "long", drop = "id1")

i.l1 <- reshape(# second reshape
           reshape(iris1, # first reshape
                   v.names = l.w <- c("Petal", "Sepal"), varying = names(iris)[1:4],
                   timevar = "Measure", times = c("Length", "Width"),
                   idvar = "id1", direction = "long"),
           v.names = "Response", varying = c("Petal", "Sepal"),
           timevar = "Flower.part", times = c("Petal", "Sepal"),
           direction = "long", drop = "id1")

i.l2 <- reshape(# second reshape
           reshape(iris1, # first reshape
                   v.names = l.w <- c("Sepal", "Petal"), varying = names(iris)[1:4],
                   timevar = "Measure", times = c("Length", "Width"),
                   idvar = "id1", direction = "long"),
           v.names = "Response", varying = c("Sepal", "Petal"),
           timevar = "Flower.part", times = c("Petal", "Sepal"),
           direction = "long", drop = "id1")

# works
i.Measure <-
    reshape(iris,
            v.names = c("Sepal", "Petal"), varying = list(c("Sepal.Length", "Sepal.Width"), c("Petal.Length", "Petal.Width")),
            timevar = "Measure", times = c("Length", "Width"),
            idvar = "id1", direction = "long")

# mixes things up
i.Measure.1 <-
    reshape(iris,
            v.names = c("Sepal", "Petal"), varying = list(c("Sepal.Length", "Petal.Length"), c("Sepal.Width", "Petal.Width")),
            timevar = "Measure", times = c("Length", "Width"),
            idvar = "id1", direction = "long")

iris.long <-
    reshape(i.Measure,
            v.names = "Response", varying = list(c("Sepal", "Petal")),
            timevar = "Flower.part", times = c("Sepal", "Petal"),
            direction = "long", drop = "id1")
