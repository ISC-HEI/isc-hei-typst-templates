#let to-trits(n, n-trits: auto) = {
  let trits = ()
  while n != 0  {
    trits.push(calc.rem(n, 3))
    n = calc.quo(n, 3)
  }
  if n-trits != auto {
    trits = trits + (0,) * (n-trits - trits.len())
  }
  return trits
}

#let from-trits(trits) = {
  return trits.enumerate().map(((i, t)) => t * calc.pow(3, i)).sum(default: 0)
}

#let trit-length(n) = {
  return to-trits(n).len()
}

#let is-power-of-3(n) = {
  return to-trits(n).sum() == 1
}
