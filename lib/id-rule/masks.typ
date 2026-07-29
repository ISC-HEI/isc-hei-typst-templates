#import "gf.typ": GF3

#let masks = (
  i => i,
  i => calc.rem(
    calc.quo(i, 2) + calc.rem(i * 29 + 9, 23),
    7
  ),
  i => (GF3.neg)(calc.quo(i, 2)) + 2,
)

#let apply(data, mask-i) = {
  let mask = masks.at(mask-i)
  return data.enumerate().map(((i, trit)) => (GF3.add)(trit, mask(i)))
}

#let apply-and-insert-id(data, mask-i) = {
  let masked = apply(data, mask-i)
  return (mask-i,) + masked + (2 - mask-i,)
}

#let grade(data, mask-i) = {
  let masked = apply-and-insert-id(data, mask-i)
  let consecutive = 0

  let last-trit = masked.first()
  let count = 1
  for trit in masked.slice(1) {
    if trit != last-trit {
      count = 1
      last-trit = trit
    } else {
      count += 1
      if count == 3 {
        consecutive += 5
      } else if count > 3 {
        consecutive += 1
      }
    }
  }

  let balance = 0
  let window-size = 7
  for i in range(masked.len() - window-size) {
    let window = masked.slice(i, i + window-size)
    let by-trit = (0, 0, 0)
    for trit in window {
      by-trit.at(trit) += 1
    }
    balance += calc.abs(by-trit.at(0) - 1)
    balance += calc.abs(by-trit.at(1) - 3)
    balance += calc.abs(by-trit.at(2) - 3)
  }

  return consecutive + balance
}

#let choose(data) = {
  let best = none
  for i in range(masks.len()) {
    let grade = grade(data, i)
    if best == none or grade < best.first() {
      best = (grade, i)
    }
  }
  return if best != none {best.last()} else {0}
}
