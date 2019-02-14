# RPG-Dice

Perl library and script that can perform compound dice roll expressions.

It can do arithmetic such as `2d6 + 5` or `1d8 + (2d6 * 1d20)`. For example, if 
you use `bin/dice`:

```
dice expression [random_seed]
```

## Why?

It seemed like both an interesting enough problem to be fun to solve, but also 
an easy enough one that it would make it a good candidate for learning how to 
make a standard Perl package.