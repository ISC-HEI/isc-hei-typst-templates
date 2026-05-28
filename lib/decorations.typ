// Decorative ornaments and rules: the chapter-rule ornament system and the
// hashed bit-rule shared by the bachelor-thesis cover and the poster separator.

#import "includes.typ" as inc

// Shared ornament renderer — used by chapter-rule and the poster separator.
// color is passed explicitly so the caller can use any brand color.
#let _draw-ornament(spec, e, color) = {
  let fc  = if spec.filled { color } else { white }
  let ang = if "angle" in spec { spec.angle } else { 0 }
  let body = if spec.shape == "square" {
    rect(width: e, height: e, fill: fc, stroke: color)
  } else if spec.shape == "circle" {
    ellipse(width: e, height: e, fill: fc, stroke: color)
  } else if spec.shape == "diamond" {
    polygon(fill: fc, stroke: color,
      (e / 2, 0pt), (e, e / 2), (e / 2, e), (0pt, e / 2))
  } else if spec.shape == "cross" {
    let bar = e / 3
    box(width: e, height: e, {
      place(dy: (e - bar) / 2, rect(width: e,   height: bar, fill: fc, stroke: color))
      place(dx: (e - bar) / 2, rect(width: bar, height: e,   fill: fc, stroke: color))
    })
  } else if spec.shape == "pentagon" {
    let r   = e / 2
    let pts = range(5).map(k => {
      let a = (270 + 72 * k) * calc.pi / 180
      (r + r * calc.cos(a), r + r * calc.sin(a))
    })
    polygon(fill: fc, stroke: color, ..pts)
  }
  if ang != 0 { rotate(ang * 1deg, origin: center + horizon, body) } else { body }
}

// Decorative "hash rule": a brand-colored square at each end joined by a line
// whose circles encode a deterministic hash of `seed` (hollow = 1 bit, filled
// = 0 bit). Each document therefore gets a stable, unique pattern. Shared by
// the bachelor-thesis cover and the poster title separator.
#let hash-rule(
  seed,
  length: 8cm,
  thickness: 2pt,
  square-size: 8pt,
  circle-r: 2.5pt,
  n-bits: 16,
  bits-length: auto,
  color: inc.hei-purple,
) = {
  // bits-length: span the circle bits are packed into (left-aligned). When
  // auto it equals `length` (bits fill the whole rule); set it shorter to
  // cluster the bits on the left and let the line run on to the right square.
  let bspan = if bits-length == auto { length } else { bits-length }
  let bit-set(n, i) = calc.rem(int(n / calc.pow(2, i)), 2) == 1

  // Polynomial rolling hash (base 31) over the seed string.
  let hash = seed.clusters().fold(0, (acc, ch) =>
    calc.rem(acc * 31 + str.to-unicode(ch), 2147483647))

  let pattern = calc.rem(hash, calc.pow(2, n-bits))

  // Guarantee at least n-bits/4 set bits so the pattern never looks empty.
  let min-ones = calc.quo(n-bits, 4)
  let ones = range(n-bits).filter(i => bit-set(pattern, i)).len()
  if ones < min-ones {
    let s = calc.quo(hash, calc.pow(2, n-bits))
    let i = 0
    while ones < min-ones {
      let pos = calc.rem(s + i * 7, n-bits)
      if not bit-set(pattern, pos) {
        pattern = pattern + calc.pow(2, pos)
        ones = ones + 1
      }
      i = i + 1
    }
  }

  box(width: length, height: square-size, {
    let mid = square-size / 2
    // Main line, vertically centered in the box.
    place(dy: mid, line(length: length, stroke: (thickness: thickness, paint: color)))
    // End squares.
    place(rect(width: square-size, height: square-size, fill: color, stroke: none))
    place(dx: length - square-size, rect(width: square-size, height: square-size, fill: color, stroke: color))
    // Bit circles, evenly spaced across the (possibly shorter) bits span,
    // with the whole cluster centered in `length` (leading + trailing line).
    let usable = bspan - 2 * square-size
    let gap    = (usable - n-bits * 2 * circle-r) / (n-bits + 1)
    let stride = 2 * circle-r + gap
    let bits-offset = (length - bspan) / 2
    for i in range(n-bits) {
      let dx-val = bits-offset + square-size + gap + circle-r + i * stride
      place(dx: dx-val, dy: mid - circle-r,
        circle(radius: circle-r,
               fill: if bit-set(pattern, i) { white } else { color },
               stroke: 0.5pt + color))
    }
  })
}

// Draws a decorative horizontal rule below a chapter heading with a single
// ornament anchored at the right end. The same ornament is used for every
// chapter (no per-chapter cycling) — the student picks once via project()'s
// `chapter-ornament:` parameter.
//
// `ornament` is a dict with keys:
//   shape:  "square"|"circle"|"diamond"|"cross"|"pentagon"
//   filled: true → hei-purple fill / false → white fill, hei-purple border
//   scale:  (optional) size multiplier, e.g. 0.5 for a smaller ornament
//   angle:  (optional) clockwise rotation in degrees
//
// Pass `ornament: none` to draw only the plain line.
#let chapter-rule(
  ornament: (shape: "circle", filled: true, scale: 0.5),
) = {
  let color = inc.hei-purple
  let sz    = 10pt
  let thick = 1pt

  // Distance between heading text and line
  v(-0.2em)

  layout(size => {
    // Full-width horizontal rule
    place(line(length: size.width, stroke: (thickness: thick, paint: black)))

    if ornament != none {
      let s = if "scale" in ornament { ornament.scale } else { 1.0 }
      let e = sz * s
      // Right edge of the ornament flush with the right end of the rule.
      place(dx: size.width - e, dy: -e / 2, _draw-ornament(ornament, e, color))
    }

    // Space below the line
    v(1em)
  })
}
