#import "encoding.typ": trit-length, is-power-of-3
#import "gf.typ": make-gf, GF3

#let encode(data, block-size: 14) = {
  let n-ec-trits = trit-length(block-size - 1)
  let data-size = block-size - n-ec-trits
  let data = data + (0,) * (make-gf(data-size).neg)(data.len())
  let n-blocks = calc.ceil(data.len() / data-size)

  let blocks = ()

  for b in range(n-blocks) {
    let block = ()
    // Layout data trits
    for i in range(block-size) {
      if i == 0 or is-power-of-3(i) {
        block.push(0)
      } else {
        block.push(data.first())
        data = data.slice(1)
      }
    }

    // Compute ternity trits (base-3 parity bits)
    for i in range(n-ec-trits).rev() {
      let pow = calc.pow(3, i)
      let ternity = range(block-size)
        .map(j => {
          let digit = calc.rem(calc.quo(j, pow), 3)
          return digit * block.at(j)
        })
        .sum()
      block.at(pow) = (GF3.neg)(ternity)
    }
    block.at(0) = (GF3.neg)(block.sum())

    blocks.push(block)
  }
  return blocks.flatten()
}