# scoreR

A command line utility for calculating the "true" scores for things using 
___S T A T I S T I C S___.

To give a concrete example, say you're trying to decide between two movies, 
one where 800 out of 1000 critics gave a positive review and another where 8 out 
of 10 were positive. The proportions of positive scores are exactly the same, 
but intuitively, you probably have more confidence that the first movie is 
"truly" an 80% compared to the second, simply due to the shear number of reviews 
available. This tool "re-averages" such scores using a metric called the
[Wilson Score](https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval),
which takes into account not just the raw proportions of scores, but the actual
numbers of scores available. 

Similarly, the tool can also provide ratings for common ordinal scoring systems,
such as Amazon's 5-star reviews, accounting for both the proportions and raw
numbers of 1, 2, 3, 4, or 5-star reviews available.

## Installation

1. Ensure you have an installation of R on your UNIX-like system. Not sure if 
this will work on a Windows machine.
2. Run the `install.sh` script

## Usage 

Here, we evaluate a product with 314 positive scores (or upvotes, or likes, 
etc.) out of 341 total scores.

```shell
[user@hostname ~] score wilson 314 341
0.8872512
```

Similarly, we can evaluate ordinal ratings. Here we evaluate a product with
4 one-star reviews, 6 two-star reviews, 35 three-star reviews, 45 four-star 
reviews, and 25 five-star reviews

```shell
[user@hostname ~] score ordinal 4 6 35 45 25
3.495104
```

We can also adjust the [confidence interval](https://en.wikipedia.org/wiki/Confidence_interval)
for a more or less "accurate" score.

```shell
[user@hostname ~] score wilson 314 341 --conf=.99
0.8746312
[user@hostname ~] score ordinal 4 6 35 45 25 --conf=.99
3.438576
```
