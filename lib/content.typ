// User-callable content helpers: titles, table of contents / figures,
// bibliography, appendix pages, the abstract footer and small utilities.

#import "includes.typ" as inc
#import "settings.typ": space-after-heading, chapter-font-size, chapter-font-weight
#import "i18n.typ": i18n
#import "@preview/gentle-clues:1.3.1": clue

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


#let abstract-footer(lang) = {
  // Suppress the inline-code background box so URLs render as plain monospace
  show raw.where(block: false): it => it

  context {
    let repo       = str(inc.global-project-repos.get())
    let kw-list    = inc.global-keywords.get().join(", ")
    let repo-title = i18n(lang, "repository")
    let kw-title   = i18n(lang, "keywords")
    let accent-repo = rgb(30, 102, 245)   // blue
    let accent-kw   = rgb(23, 146, 153)   // teal

    // Repo box: floated to the top-right, compact insets, normal text size
    // Measure header and body to size the box snugly around its content
    let repo-header-w = measure(box(inset: (x: 0.3em),
      grid(columns: (auto, auto), gutter: 1em,
        align: (horizon, left + horizon),
        box(height: 0.8em)[#text(0.8em)[🔗]], text(0.8em, repo-title))
    )).width
    let repo-body-w = measure(box(inset: (x: 0.4em), raw(repo))).width
    let repo-box-w  = calc.max(repo-header-w, repo-body-w) + 2pt  // 2pt for left stroke

    place(top + right,
      clue(
        align(right, link(repo)[#raw(repo)]),
        title: text(0.8em, repo-title), icon: text(0.8em)[🔗],
        accent-color: accent-repo, body-color: accent-repo.lighten(95%),
        radius: 0pt, stroke-width: 2pt,
        header-inset: 0.3em, content-inset: 0.4em,
        width: repo-box-w,
      )
    )

    // Push keywords to the bottom of the page
    v(1fr)

    // Full-width keywords clue
    clue(
      align(center, text(0.9em,kw-list)),
      title: text(0.9em,kw-title), icon: text(0.9em)[🏷],
      accent-color: accent-kw, body-color: accent-kw.lighten(95%),
      header-inset: 0.3em, content-inset: 0.7em,
      radius: 0pt, stroke-width: 3pt,
    )
  }
}
