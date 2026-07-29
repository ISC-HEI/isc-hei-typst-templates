#import "consts.typ": permutations
#import "encoding.typ": from-trits, to-trits

#let permute(data, id) = {
  let perm = permutations.at(id)
  return perm.map(i => data.at(i))
}

#let make-groups(data, group-sizes) = {
  let groups = ()
  for size in group-sizes {
    groups.push(data.slice(0, size))
    data = data.slice(size)
  }
  return groups
}

#let split-in-groups(data, n-groups: 4, permutation: none) = {
  let base-size = int(calc.round(data.len() / n-groups))
  let last-size = data.len() - (n-groups - 1) * base-size
  let sizes = (base-size,) * (n-groups - 1) + (last-size,)
  if permutation != none {
    sizes = permute(sizes, permutation)
  }
  let groups = make-groups(
    data,
    sizes
  )
  return groups
}

#let substitute(trits) = {
  let val = from-trits(trits)
  return to-trits(
    calc.rem(
      17461 * val + 28411,
      calc.pow(3, trits.len())
    ),
    n-trits: trits.len()
  )
}

#let shuffle(data) = {
  for i in range(data.len() - 1) {
    let value = data.at(i) + data.at(i + 1) * 3
    let rest = data.slice(0, i) + data.slice(i + 2)
    rest = substitute(rest)
    let groups = split-in-groups(rest)
    groups = permute(groups, value)
    rest = groups.flatten()
    data = rest.slice(0, i) + data.slice(i, i + 2) + rest.slice(i)
  }
  return data
}
