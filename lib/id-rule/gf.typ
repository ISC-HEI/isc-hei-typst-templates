#let make-gf(base) = {
  let cls = (
    base: base,
    add: (a, b) => calc.rem(a + b, base),
    neg: n => calc.rem(base - calc.rem(n, base), base)
  )

  cls += (
    mult: (a, b) => {
      let mn = calc.min(a, b)
      let mx = calc.max(a, b)
      range(mn).fold(0, (acc, _) => (cls.add)(acc, mx))
    },
  )
  return cls
}

#let GF3 = make-gf(3)