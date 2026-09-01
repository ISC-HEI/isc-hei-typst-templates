// Decorative rules: the chapter-rule reading-position hairline and the encoded
// trit-rule shared by the bachelor-thesis cover and the poster separator.

#import "includes.typ" as inc

// Decorative "id rule": a brand-colored square at each end joined by a line
// whose circles encode the document's unique id (space = 0, hollow = 1, filled
// = 2). Each document therefore gets a stable, unique pattern. Shared by the
// bachelor-thesis cover and the poster title separator.
#let id-rule(
  square-size: 8pt,
  thickness: 2pt,
  circle-r: 2.5pt,
  length: 8cm,
  n-trits: 16,
  bits-length: auto,
  color: inc.hei-purple,
  trits
) = {
  let n-trits = trits.len()
  let bspan = if bits-length == auto { length } else { bits-length }
  box(width: length, height: square-size, {
    let mid = square-size / 2
    // Main line, vertically centered in the box.
    place(
      dy: mid,
      line(
        length: length,
        stroke: (thickness: thickness, paint: color)
      )
    )
    
    // End squares.
    let square = rect(
      width: square-size, height: square-size,
      fill: color, stroke: none
    )
    place(square)
    place(square, dx: length - square-size)

    // Trit circles, evenly spaced across the (possibly shorter) bits span,
    // with the whole cluster centered in `length` (leading + trailing line).
    let circle-w = 2 * circle-r + 0.5pt
    let usable = bspan - square-size
    let gap    = (usable - n-trits * circle-w) / (n-trits + 1)
    let stride = circle-w + gap
    let bits-offset = (length - bspan) / 2 + square-size / 2
    for (i, trit) in trits.enumerate() {
      if trit == 0 {
        continue
      }
      
      let dx-val = i * stride + bits-offset + gap
      place(
        dx: dx-val, dy: mid - circle-r,
        circle(
          radius: circle-r,
          fill: if trit == 1 { white } else { color },
          stroke: 0.5pt + color
        )
      )
    }
  })
}

// Draws the reading-position hairline below a numbered chapter heading: a faint
// full-width track with the leading `progress` fraction (0–1) in brand color and
// a dot at the head, indicating chapter n of the total. With `progress: none`
// nothing visible is drawn.
#let chapter-rule(progress: none) = {
  let color      = inc.hei-purple
  let track-w    = 1.0pt   // faint background track
  let fill-w     = 1.0pt   // filled (read-so-far) portion
  let dot-r      = 4.0pt   // head marker radius

  // Distance between heading text and line
  v(-0.2em)

  layout(size => {
    if progress != none {
      place(line(length: size.width, stroke: (paint: luma(60%), thickness: track-w)))
      place(line(length: progress * size.width, stroke: (paint: color, thickness: fill-w)))
      // Head marker at the current reading position.
      place(dx: progress * size.width, move(dx: -dot-r, dy: -dot-r,
        circle(radius: dot-r, fill: color, stroke: none)))
    }

    // Space below the line
    v(1em)
  })
}
