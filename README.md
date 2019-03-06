# R you experienced?

## What is this?

* articles on theoretical programming concepts turned into R code
* source of a static website containing those articles: [https://attilagk.github.io/R-you-experienced/](https://attilagk.github.io/R-you-experienced/)

## Introduction

The idea of this little collection of articles came about when I studied language-independent programming concepts.  As I was working my way through the classic textbook [Structure and Interpretation of Computer Programs](https://mitpress.mit.edu/sites/default/files/sicp/index.html) I was taken by the austere beauty of its theoretical subject itself.  At the same time I wondered how I could lift those general programming concepts into my everyday R programming practice in computational and statistical genomics.  I knew that once I managed to implement some general concept in R---and so learn a new R idiom---in the context of a specific problem from then on that R idiom would serve me well in other contexts.

I began to search for the problem with the blueprint of a solution in my hand.  Where in my everyday work could I apply, say, a recursive procedure?  What facilities does the R language offer to implement it and what the pros and cons of alternative implementations?  And what are the pros and cons of iteration relative to recursion?  Whenever I found a pretext for applying a general technique (like recursive procedures) in my everyday work I swung into action (spending probably time and effort than my boss would have preferred) and finally achieved the lofty goal of connecting theory to practice.

But introducing a new concept into work on real world problems turned out too much of a compromise because real world problems are messy, complicated and already loaded with their own practical significance.  Besides, I wanted share my experience with others.  That called for putting real problems aside and working in the cute realm of toy problems.  Only that allowed proper discussion of and comparison between general and R language specific programming concepts.

This principle lead directly to the present project (or blog, if you will).  After the first few programming minded articles I expanded the scope to statistical modeling; a rather accidental decision but not arbitrary because the statistics oriented articles, too, balance between theory and practice.

## About the repository

The repository contains the source of a website to be built by [Jekyll](https://jekyllrb.com/).  This means that GitHub automatically builds it into a static website; see [https://attilagk.github.io/R-you-experienced/](https://attilagk.github.io/R-you-experienced/).

If you would like to build and serve it locally then fork the repo and run Jekyll as follows.

```
git clone https://github.com/attilagk/R-you-experienced && cd R-you-experienced
bundle exec jekyll serve --config _config.local.yml
```

The HTML style may not work in this case, but that's OK because running the site locally is only meant for rapid development and testing.

Most files and directories are standard for Jekyll (see [this page](https://jekyllrb.com/docs/structure/) in Jekyll's docs).  There are two directories that contain the real content, though.

```
R-markdown/   # R markdown files (the articles) and associated R scripts
R/            # images produced by "knitting" the R markdown files
```
