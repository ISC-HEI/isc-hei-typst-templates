// User-callable content helpers: titles, table of contents / figures,
// bibliography, appendix pages, the abstract footer and small utilities.

#import "includes.typ" as inc
#import "settings.typ": space-after-heading, chapter-font-size, chapter-font-weight
#import "i18n.typ": i18n
#import "@preview/gentle-clues:1.3.1": clue
#import "@preview/tiaoma:0.3.0"

#let page-title(title, mult: 1.5, bottom: 2pt, top: 4em) = {
  set text(size: chapter-font-size * mult, weight: chapter-font-weight)
  block(fill: none, inset: (x: 0pt, bottom: bottom, top: top), below: space-after-heading * mult, {
    title
  })
}

// Enable the display of headers and footers
#let set-header-footer(enabled) = {
  context inc.header-footers-enabled.update(enabled)
}

// Make a page break so that the next page starts on an odd page
#let cleardoublepage() = {
  pagebreak(weak: true)
  inc.blank-page.update(true)
  pagebreak(to: "odd", weak: true)
  inc.blank-page.update(false)
}

// Indicate that something still needs to be done
#let todo(body, fill-color: yellow.lighten(50%)) = {
  set text(black)
  box(baseline: 25%, fill: fill-color, inset: 4pt, [*TODO* #body])
}

// Generate a lorem ipsum with paragraphs
#let lorem-pars(n-words, each: 5) = {
  let n = int(n-words / (each * 30))
  let sentences = lorem(n * (each * 30)).split(". ")

  range(n)
    .map(i => sentences.slice(i * each, count: each).join(". ") + [.])
    .join(parbreak())
}

// Cetz
#let scale-to-width(width, body) = layout(page-size => {
  let size = measure(body, ..page-size)
  let target-width = if type(width) == ratio {
    page-size.width * width
  } else if type(width) == relative {
    page-size.width * width.ratio + width.length
  } else {
    width
  }
  let multiplier = target-width.to-absolute() / size.width
  scale(reflow: true, multiplier * 100%, body)
})

#let _make-outline(font: auto, title, ..args) = {
  {
    show heading:none
    heading(bookmarked: true, numbering: none, outlined: false)[Table of contents]
  }

  let title = if font == auto { title } else {
    text(font: font, title)
  }

  outline(title: {
    v(2em)
    text(size: chapter-font-size, weight: chapter-font-weight, title)
    v(3em)
  }, indent: 2em, ..args)
  pagebreak(weak: true)
}

// Generates the special appendix page
#let appendix-page() = {
  context{
    {
      show heading: none
      heading(numbering:none)[#i18n(inc.global-language.get(), "appendix-title")]
    }

    // The appendix page
    place(center + horizon, [
      #{
        set text(size: chapter-font-size * 2, weight: chapter-font-weight)
        i18n(inc.global-language.get(), "appendix-title")
      }
    ])
  }
}

// Generate the table of contents with a given depth
#let table-of-contents(depth: 2) = {
  context {
    if inc.show-toc-enabled.get() {
      let f = inc.global-language.get()
      _make-outline(i18n(f, "toc-title"), depth: depth)
    }
  }
}

// Generate the table of figures
#let table-of-figures(depth: 1) = {
  context {
    let f = inc.global-language.get()
    outline(
      title: page-title(i18n(f, "figure-table-title"), mult: 1, top: 1em, bottom: 1em),
      depth: 1,
      indent: auto,
      target: figure.where(kind: image),
    )
  }
}

// Generate the proper header for the code samples appendix
#let code-samples() = {
  context{
    heading(
      numbering: none,
      depth: 2,
      outlined: false,
      bookmarked: false,
      text(
        page-title(i18n(inc.global-language.get(), "appendix-code-name"), mult: 1, top: 1em, bottom: 1em)),
    )
  }
}

#let the-bibliography(
  bib-file: none,
  full: false,
  style: "ieee"
) = {
  context {
    let title = i18n(inc.global-language.get(), "bibliography-title")
    show heading: none
    heading(bookmarked: true, numbering: none, outlined: true)[#title]
    page-title(title, mult: 1, top: 0.5em, bottom: 0.3em)
    bibliography("../src/" + bib-file, full: full, style: style, title:none)
  }
}


// Pull a friendly "brand" out of a URL host: the first hostname component
// after stripping protocol and an optional www. (e.g. github.com → github,
// gitlab.hevs.ch → gitlab, isc.hevs.ch → isc).
#let _repo-host-brand(repo) = {
  let s = repo
  if s.starts-with("https://") { s = s.slice(8) }
  else if s.starts-with("http://") { s = s.slice(7) }
  let slash = s.position("/")
  let host = if slash == none { s } else { s.slice(0, slash) }
  if host.starts-with("www.") { host = host.slice(4) }
  let parts = host.split(".")
  if parts.len() > 0 { parts.first() } else { host }
}

// Repository "card": magenta accent bar + title + brand affordance + scaled QR.
// Reads the repo URL from global-project-repos. Sizes are em-relative so the
// card scales with the surrounding text size. Returns content (not placed).
// The entire text pane is wrapped in link(repo, …) so click-readers can hit it
// anywhere; print readers use the QR.
#let repo-block(lang, accent: inc.hei-purple) = context {
  let repo       = str(inc.global-project-repos.get())
  let repo-title = i18n(lang, "repository")
  let brand      = _repo-host-brand(repo)
  let on-prep    = i18n(lang, "repo-on")

  let text-pane = block(
    stroke: (left: 3.5pt + accent),
    inset: (left: 0.8em, right: 0.9em, top: 0.45em, bottom: 0.45em),
    link(repo, stack(spacing: 0.55em,
      text(0.9em, fill: black, weight: "bold", tracking: 0.06em, upper(repo-title)),
      text(0.82em, fill: black, [❯ #on-prep #text(fill: accent, weight: "bold", brand)]),
    )),
  )
  let pane-h = measure(text-pane).height

  // Scale the QR uniformly so its height matches the text pane.
  let qr-raw = tiaoma.barcode(repo, "QRCode", options: (
    scale: 1.0, fg-color: black, bg-color: white,
  ))
  let qr-scaled = scale(
    (pane-h / measure(qr-raw).height) * 100%,
    origin: top + left, reflow: true, qr-raw,
  )

  let qr-pane = block(
    stroke: (left: 0.6pt + luma(70%)),
    inset: (left: 7pt, right: 0pt, y: 0pt),
    link(repo, qr-scaled),
  )

  stack(dir: ltr, spacing: 0pt, text-pane, qr-pane)
}

#let abstract-footer(lang) = {
  context {
    let kw-list  = inc.global-keywords.get().join(", ")
    let kw-title = i18n(lang, "keywords")

    place(top + right, repo-block(lang))

    v(1fr)

    // Plain keywords block (no box, no icon)
    align(left, {
      text(1em, weight: "bold", kw-title)
      linebreak()
      text(0.9em, kw-list)
    })
  }
}
