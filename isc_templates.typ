// Template for ISC bachelor degree programme at the School of engineering in Sion
// Since 2024, @pmudry with contributions from @LordBaryhobal, @MadeInShineA
// Bachelor thesis template first page inspired from Lasse Rosenow work on https://typst.app/universe/package/haw-hamburg-master-thesis

#import "lib/includes.typ" as inc
#import "@preview/gentle-clues:1.3.1": clue

// Global settings
#let space-after-heading = 0.8em
#let chapter-font-size = 1.5em
#let chapter-font-weight = 700

#let body-font-size = 11pt

#let global-keywords = inc.global-keywords
#let version = toml("typst.toml").package.version

// State for isc-poster's distribute-columns feature (read by isc-card)
#let _isc-poster-distribute = state("_isc-poster-distribute", false)
// Tracks whether the next isc-card is the first in its column (no leading spacer)
#let _isc-first-card = state("_isc-first-card", true)
// Vertical offset applied to the first card in every column (negative = pull up)
#let _isc-col-start-offset = state("_isc-col-start-offset", 0pt)

//////////////////////////
// User callable functions
// //////////////////////////
#let page-title(title, mult: 1.5, bottom: 2pt, top: 4em) = {
  set text(size: chapter-font-size * mult, weight: chapter-font-weight)
  block(fill: none, inset: (x: 0pt, bottom: bottom, top: top), below: space-after-heading * mult, {
    title
  })
}

// Draws a decorative horizontal rule below a chapter heading.
// Ornaments cycle automatically by chapter number.
//
// Each entry in `decorations` is an array of shape dicts with keys:
//   shape:  "square"|"circle"|"diamond"|"triangle-up"|"triangle-down"|"cross"|"pentagon"
//   filled: true → hei-purple fill / false → white fill, hei-purple border
//   scale:  (optional) size multiplier, e.g. 0.6 for a smaller ornament
//   angle:  (optional) clockwise rotation in degrees (useful for square, diamond, cross)
//
// Set `enabled: false` to draw only the plain line.
// Pass `chapter: counter(heading).get().first()` from the enclosing context — do not set manually.
//
// Example:
//   context chapter-rule(chapter: counter(heading).get().first())
//   context chapter-rule(chapter: counter(heading).get().first(), decorations: (
//     ((shape: "cross", filled: false, scale: 0.6, angle: 45), (shape: "square", filled: true)),
//   ))
#let chapter-rule(
  decorations: (
    // — single shapes —
    ((shape: "square",   filled: false, scale: 0.4, angle: 45),  (shape: "circle",      filled: true)),
    ((shape: "square",        filled: false),),
    ((shape: "pentagon",      filled: true),),
    ((shape: "cross",    filled: true,  scale: 0.6, angle: 0),  (shape: "square",      filled: false)),
    ((shape: "diamond",  filled: false, scale: 0.4, angle: 0),  (shape: "diamond",     filled: true)),
    ((shape: "circle",        filled: true),),
    ((shape: "square",   filled: true,  scale: 0.5, angle: 45),  (shape: "pentagon",    filled: false)),
    ((shape: "circle",        filled: false),),

    ((shape: "square",        filled: true),),
    ((shape: "diamond",  filled: false),),
    ((shape: "diamond",  filled: true,  scale: 0.6, angle: 12),  (shape: "circle",      filled: false)),
    ((shape: "pentagon",      filled: false), (shape: "square",  filled: true)),
    ((shape: "diamond", filled: false, scale: 0.55, angle: 15),
     (shape: "circle",  filled: true,  scale: 0.75),
     (shape: "square",  filled: false)),
    ((shape: "cross",   filled: false, scale: 0.55, angle: 45),
     (shape: "diamond", filled: true,  scale: 0.75),
     (shape: "circle",  filled: false)),
  ),
  enabled: true,
  chapter: 1,
) = {
  let color = inc.hei-purple
  let sz    = 10pt   // base slot size; shapes may be smaller via `scale`
  let gap   = 12pt    // gap between adjacent ornament slots
  let thick = 1pt

  // Build a single ornament of effective size `e` as renderable content.
  // Rotation (if any) is applied around the shape's centre before returning.
  let draw-ornament(spec, e) = {
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
      // Two overlapping bars inside a bounding box; rotating 45° gives an ×
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

    // Rotate around the ornament's centre (preserves bounding box for layout)
    if ang != 0 { rotate(ang * 1deg, origin: center + horizon, body) } else { body }
  }

  // Distance between heading text and line
  v(-0.2em)

  layout(size => {
    // Full-width horizontal rule
    place(line(length: size.width, stroke: (thickness: thick, paint: black)))

    if enabled and decorations.len() > 0 {
      // Pick the pattern for this chapter, cycling when chapter > len
      let pattern = decorations.at(calc.rem(chapter - 1, decorations.len()))
      let n = pattern.len()

      // Draw each ornament; array is left-to-right, last entry is rightmost
      for (i, spec) in pattern.enumerate() {
        let s      = if "scale" in spec { spec.scale } else { 1.0 }
        let e      = sz * s                           // effective size
        let slot-x = size.width - sz - (sz + gap) * (n - 1 - i)
        let x      = slot-x + (sz - e) / 2           // center in slot
        place(dx: x, dy: -e / 2, draw-ornament(spec, e))
      }
    }

    // Space below the line
    v(1em)
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

//
// Multiple languages support
// Thanks @LordBaryhobal for the original idea
//
#let langs = json("i18n.json")

#let i18n(lang, key, extra-i18n: none) = {
  let langs = langs
  if type(extra-i18n) == dictionary {
    for (lng, keys) in extra-i18n {
      if not lng in langs {
        langs.insert(lng, (:))
      }
      langs.at(lng) += keys
    }
  }

  let keys = langs.at(lang)

  assert(key in keys, message: "I18n key " + str(key) + " doesn't exist")
  return keys.at(key)
}

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
    bibliography("src/" + bib-file, full: full, style: style, title:none)
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

//////////////////////////
// TB assignment sheet
//////////////////////////
#import "lib/pages/cover_assignment.typ": tb-assignment-page, hes, industry, school, project-types, get-document-title

//////////////////////////
// Source code inclusion
//////////////////////////
#let _luma-background = luma(250)

// Replace the original function by ours
#let codelst-sourcecode = inc.sourcecode

#let code = codelst-sourcecode.with(
  frame: block.with(fill: _luma-background, stroke: 0.5pt + luma(80%), radius: 3pt, inset: (x: 6pt, y: 7pt)),
  numbering: "1",
  numbers-style: (lno) => text(luma(210), size: 7pt, lno),
  numbers-step: 1,
  numbers-width: -1em,
  gutter: 1.2em,
)

// Warning page rendered instead of the full document when ISC fonts are absent.
// Deliberately uses only Libertinus Serif (always bundled in Typst) so the page
// itself renders correctly even without the custom fonts.
#let _missing-fonts-page() = {
  set page(paper: "a4", margin: (x: 3cm, y: 3cm), header: none, footer: none, numbering: none)
  set text(font: ("Libertinus Serif",), size: 11pt, fill: black)

  let accent = rgb("#E20571")

  align(center + horizon,
    rect(
      width: 100%,
      stroke: (left: 5pt + accent, rest: 0.8pt + luma(200)),
      radius: 4pt,
      inset: (x: 2em, y: 1.8em),
      {
        align(center,
          text(size: 1.8em, weight: "bold", fill: accent)[⚠ ISC Template — Fonts Not Installed]
        )
        v(1em)
        line(length: 100%, stroke: 0.5pt + luma(220))
        v(1em)

        [The fonts required by this template are *not installed* on this system.
        This document cannot be rendered with the correct typography.]
        v(1.2em)

        [*Install the fonts by running this command once from the repository root:*]
        v(0.5em)
        block(width: 100%, fill: luma(245), inset: (x: 1em, y: 0.7em), radius: 3pt,
          align(left, raw(lang: "sh", "source src/fonts/install_fonts.sh"))
        )
        v(1.2em)

        [*Required fonts (all installed by the script above):*]
        v(0.3em)
        list(
          [*Source Sans Pro* / Source Sans 3 — body text],
          [*Fira Code* — source code listings],
          [*Inria Sans* — headings],
        )
        v(1.2em)

        text(style: "italic", size: 0.9em, fill: luma(100))[
          After installing the fonts, recompile the document.
          See #raw("README.md") or #raw("CLAUDE.md") for detailed instructions.
        ]
      }
    )
  )
}

/*********************************
 ** The template itself
 ********************************/
#let project(
  title: [Report title],
  subtitle: none,
  academic-year: [2026-2027],
  
  // Document type: "report", "thesis", "document", "exec-summary"
  doc-type: "report",  
  split-chapters: true,

  // Document specific
  show-cover: true,
  show-toc: 2, // false = no TOC, true = TOC with depth 2, integer = TOC with given depth
  fancy-line: false, // Use decorative line with squares (false = simple line)
  fancy-chapter-rule: false, // Use decorative ornaments on chapter rules (false = plain line)

  // Bachelor thesis specific
  thesis-supervisor: [Thesis supervisor],
  thesis-co-supervisor: none,
  thesis-expert: "[Thesis expert]",
  thesis-id: none,
  project-repos: none,
  keywords: (),
  major: (),
  school: [School name],
  programme: [Informatique et systèmes de communication],
  
  // Executive summary specific
  summary: none,
  content: none,
  student-picture: none,
  permanent-email: "stormy.peters@example.com",
  video-url: none,
  bind: none,
  footer: none,
  // Your picture and email will be used in the printed brochure.
  // By default they will also appear on the ISC web page. Set either
  // flag to true to opt out of web publication for that item.
  picture-web-opt-out: false,
  email-web-opt-out: false,
  
  // Course report specific
  course-name: none,
  course-supervisor: none,
  semester: none,
  cover-image: none,
  cover-image-height: 10cm,
  cover-image-caption: [KNN graph -- Inspired by _Marcus Volg_],
  cover-image-kind: auto,
  cover-image-supplement: auto,
  
  
  // A list of authors, separated by commas
  authors: (),
  date: none,
  logo: auto, // auto = default logo for document type, none = no logo
  equations: false,
  revision: none, // Like a version number
  language: "fr",
  extra-i18n: none,
  code-theme: "bluloco-light",
  // When true: suppresses all headers, footers, and the inline compact header
  no-decorations: false,
  body,
) = {
  
  // Validate doc-type
  let valid-doc-types = ("report", "thesis", "document", "exec-summary", "tb-assignment")
  assert(doc-type in valid-doc-types, message: "Invalid doc-type '" + doc-type + "'. Must be one of: " + valid-doc-types.join(", "))
  
  // Update state with the passed values so they are accessible globally
  inc.global-keywords.update(keywords)
  inc.global-language.update(language)

  // For tb-assignment: title is always i18n-derived, logo is always suppressed
  let title = if doc-type == "tb-assignment" { get-document-title(language) } else { title }
  let logo  = if doc-type == "tb-assignment" { none } else { logo }

  // Normalize show-toc: true -> 2, false -> 0, int -> int
  let toc-depth = if doc-type == "tb-assignment" or doc-type == "exec-summary" { 0 } else if show-toc == false { 0 } else if show-toc == true { 2 } else { int(show-toc) }
  inc.show-toc-enabled.update(toc-depth > 0)

  if(project-repos != none) {
    inc.global-project-repos.update(project-repos)
  }else{
    if(doc-type == "thesis") {panic("No project repository provided, you need to provide one!")}
  }

  let i18n = i18n.with(extra-i18n: extra-i18n, language)

  // Set the document's basic properties.
  set document(author: authors, title: title, date: date, keywords: keywords, description: "Using ISC template ver. " + version)

  set par(justify: true)

  // Detect whether the ISC fonts are available using glyph-metric comparison.
  // Source Sans Pro/3 (sans-serif) has markedly different capital widths from
  // Libertinus Serif (always bundled in Typst). Equal widths means both ISC font
  // names fell back to Libertinus Serif, i.e. the fonts are not installed.
  // Works identically on the Typst web editor (has Source Sans Pro built in) and
  // locally (has it after running install_fonts.sh).
  context {
  let _p   = "MMMMMMMMMM"
  let _isc = measure(text(font: ("Source Sans Pro", "Source Sans 3"), size: 12pt, _p)).width
  let _lib = measure(text(font: ("Libertinus Serif",),                size: 12pt, _p)).width
  if _isc == _lib { _missing-fonts-page() } else {

  //  Fonts
  let body-font = ("Source Sans Pro", "Source Sans 3", "Libertinus Serif")
  let sans-font = ("Source Sans Pro", "Source Sans 3", "Inria Sans")
  let raw-font = "Fira Code"
  let math-font = ("Asana Math", "Fira Math")

  // Default body font
  set text(font: body-font, lang: language, size: body-font-size)

  // Set other fonts
  // show math.equation: set text(font: math-font) // For math equations
  if doc-type != "tb-assignment" {
    let selected-theme = "src/themes/" + code-theme + ".tmTheme"
    set raw(theme: selected-theme)
  }
  show raw: set text(font: raw-font) // For code

  show heading: set text(font: sans-font) // For sections, sub-sections etc..
  show heading: set block(below: space-after-heading)

  /////////////////////////////////////////////////
  // Citation style
  /////////////////////////////////////////////////
  set cite(style: auto, form: "normal")

  /////////////////////////////////////////////////
  //  Basic pagination and typesetting
  /////////////////////////////////////////////////
  set rect(width: 100%, height: 100%, inset: 4pt)

  // Thesis specific settings
  set page(
    margin: (inside: 2.5cm, outside: 1.5cm, bottom: 2.1cm, top: 2cm), // Binding inside
    paper: "a4",
  ) if(doc-type == "thesis")  

  // Report specific settings
  set page(
    margin: (inside: 2.5cm, outside: 2cm, y: 2.1cm), // Binding inside
    paper: "a4",    
  ) if(doc-type == "report")

  // Document specific settings — symmetric margins
  set page(
    margin: (x: 2.0cm, y: 1.8cm),
    paper: "a4",    
  ) if(doc-type == "document")

  // TB assignment — same margins as document, no decorations
  set page(
    margin: (x: 2.0cm, y: 1.8cm),
    footer: none,
    header: none,
    paper: "a4",
  ) if(doc-type == "tb-assignment")

  if (doc-type != "thesis" and doc-type != "tb-assignment") {
    // For reports and documents, we want to put the header and footer on all pages
    set-header-footer(true)
  } else {
    // For theses, we want to put the header and footer only on the first page
    set-header-footer(false)
  }

  // Suppress all page decorations when requested (must come after other set page calls)
  if no-decorations {
    set-header-footer(false)
    set page(footer: none, header: none)
  }

  show heading: it => {
    // In a thesis, put chapters begin on odd pages
    // Add the header in a block to make space around it
    if it.level == 1 and doc-type == "thesis" and split-chapters {      
      pagebreak(weak: true)    
      inc.blank-page.update(true)
      pagebreak(to: "odd", weak: true)  
      inc.blank-page.update(false)
      
      block(fill: none, inset: (x: 0pt, bottom: space-after-heading, top: 6.5em), below: 0pt, {
        // If the heading has a numbering, display it
        if (it.numbering != none) {
          text(i18n("chapter-title") + " " + counter(heading).display() + " " + it.body, size: chapter-font-size, weight: chapter-font-weight)        
        } else {
          it
        }
        // Decorative rule — only for numbered (chapter) headings
        if it.numbering != none {
          context chapter-rule(chapter: counter(heading).get().first(), enabled: fancy-chapter-rule)
        }

      })
    } else {
      it
    }
  }

  // Manage authors single and plural
  let authors-list = if type(authors) == str { (authors,) } else { authors }
  let authors-str = if authors-list.len() > 1 {
    authors-list.join(", ")
  } else if authors-list.len() == 1 {
    authors-list.at(0)
  } else {
    panic("No authors provided for the report")
  }  

  let footer-title = if type(title) == str { title.replace("\n", " – ") } else { title }

  let footer-content = context text(0.75em)[
    #{
      emph(footer-title) 
      if revision != none {
          text(", rev " + revision, style: "italic")
      }

      h(1fr)
      counter(page).display("1/1", both: true)
    }
  ]

  set page(
    // For pages other than the first one
    header: context if counter(page).get().first() > 1 {
      if inc.header-footers-enabled.get() and not inc.blank-page.get() {
        let header-content = text(0.75em)[
          #emph(authors-str)            
        ]

        let page = counter(page).get().first()
        let content = if calc.odd(page) { align(right, header-content) } else { align(left, header-content)}
        content
      }
    },
    header-ascent: 40%,
    footer: context {
      if counter(page).get().first() == 1 and not show-cover and (doc-type == "report" or doc-type == "document") {
        // First page compact mode: show date and version
        text(0.75em, {
          if date != none {
            inc.custom-date-format(date, pattern: i18n("date-format"), lang: language)
          }
          if revision != none {
            if date != none {
              [ — v#revision]
            } else {
              [v#revision]
            }
          }
          h(1fr)
          counter(page).display("1/1", both: true)
        })
      } else if counter(page).get().first() > 1 {
        if inc.header-footers-enabled.get() and not inc.blank-page.get() {
          move(dy: 5pt, line(length: 100%, stroke: 0.5pt))
          footer-content
        } else {
          none
        }
      }
    },
  )

  // Links coloring
  show link: set text(ligatures: true, fill: blue)

  // Sections numbers
  set heading(numbering: "1.1.1 –")

  /////////////////////////////////////////////////
  // Handle specific captions styling
  /////////////////////////////////////////////////

  // Compute a supplement for captions as they are not to my liking
  let getSupplement(it) = {
    let f = it.func()
    if (f == image) {
      i18n("figure-name")
    } else if (f == table) {
      i18n("table-name")
    } else if (f == raw) {
      i18n("listing-name")
    } else {
      auto
    }
  }

  set figure(numbering: "1", supplement: getSupplement)

  // Make the caption like I like them
  show figure.caption: set text(9pt) // Smaller font size
  show figure.caption: emph // Use italics
  set figure.caption(separator: " - ") // With a nice separator

  show figure.caption: it => { it.counter.display() } // Used for debugging

  // Make the caption like I like them
  show figure.caption: it => context {
    if it.numbering == none {
      it.body
    } else {
      it.supplement + " " + it.counter.display() + it.separator + it.body
    }
  }

  /////////////////////////////////////////////////
  // Code related, only for inline as the
  // code block is handled by function at the top of the file
  /////////////////////////////////////////////////

  // Inline code display,
  // In a small box that retains the correct baseline.
  show raw.where(block: false): box.with(fill: _luma-background, inset: (x: 2pt, y: 0pt), outset: (y: 2pt), radius: 1pt)

  // Allow page breaks for raw figures
  show figure.where(kind: raw): set block(breakable: true)

  /////////////////////////////////////////////////
  // Cover pages
  /////////////////////////////////////////////////
  // Default logo for document type
  let logo = if logo == auto and (doc-type == "document" or doc-type == "report" or doc-type == "tb-assignment") {
    if show-cover{
      image("lib/assets/ISC Logo inline black v3.pdf")
    } else {
      image("lib/assets/ISC Logo inline black v3.pdf")
    }
  } else if logo == auto {
    none
  } else {
    logo
  }

  // TB assignment never has a cover page
  let show-cover = if doc-type == "tb-assignment" { false } else { show-cover }

  if not show-cover and not no-decorations and (doc-type == "report" or doc-type == "document" or doc-type == "tb-assignment") {
    // Compact inline header: logo right-aligned on its own row, then title + authors
    if logo != none {
      v(0.3em)
      align(right, box(height: 1.3cm, logo))
      v(1.5em)
    }
    text(font: sans-font, 1.8em, weight: 700, title)
    linebreak()
    v(-0.2em)
    text(1.1em, authors-list.join(", "))
    v(-0.1em)

    // A line to separate the header from the content
    if fancy-line {
      rect(width: 100%, height: 0.6pt, fill: gradient.linear((luma(20), 0%), (luma(20), 80%), (luma(20).transparentize(100%), 100%)), stroke: none)
    } else {
      line(length: 100%, stroke: (paint: luma(20), thickness: 0.6pt))
    }
    v(0.7em)
  } else if (doc-type == "report") {
    import "lib/pages/cover_report.typ": cover_page

    let report_cover = cover_page(
      course-supervisor: course-supervisor,
      course-name: course-name,
      font: sans-font,
      title: title,
      subtitle: subtitle,
      semester: semester,
      academic-year: academic-year,
      cover-image: cover-image,
      cover-image-height: cover-image-height,
      cover-image-caption: cover-image-caption,
      cover-image-kind: cover-image-kind,
      cover-image-supplement: cover-image-supplement,
      authors: authors,
      date: date,
      logo: logo,
      language: language,
    )

    report_cover
  } else if doc-type == "document" {
    import "lib/pages/cover_document.typ": cover_page

    let document_cover = cover_page(
      font: sans-font,
      title: title,
      subtitle: subtitle,
      authors: authors,
      date: date,
      revision: revision,
      logo: logo,
      language: language,
    )

    document_cover
  } else if doc-type == "thesis" {
    import "lib/pages/cover_bachelor.typ": cover_page

    let supervisors = ()

    if (thesis-co-supervisor == none) {
      supervisors = (thesis-supervisor,)
    } else {
      supervisors = (thesis-supervisor, thesis-co-supervisor)
    }

    let thesis_cover = cover_page(
      supervisors: supervisors,
      expert: thesis-expert,
      font: sans-font,
      title: title,
      subtitle: subtitle,
      semester: semester,
      academic-year: academic-year,
      school: school,
      programme: programme,
      major: major,      
      authors: authors-str,
      thesis-id: thesis-id,
      submission-date: date,
      revision: revision,
      logo: logo,
      language: language,
    )

    thesis_cover
  } else if doc-type == "exec-summary" {
    import "lib/pages/cover_exec_summary.typ": cover_page

    let supervisors = ()

    if (thesis-co-supervisor == none) {
      supervisors = (thesis-supervisor,)
    } else {
      supervisors = (thesis-supervisor, thesis-co-supervisor)
    }

    let exec_summary = cover_page(
      title: title,
      authors: authors-str,
      summary: summary,
      content: content,
      picture: student-picture,
      permanent-email: permanent-email,
      video-url: video-url,
      academic-year: academic-year,
      supervisors: supervisors,
      expert: thesis-expert,
      school: school,
      programme: programme,
      major: major,
      language: language,      
      bind: bind,
      footer: footer,
      font: sans-font,
    )

    exec_summary
  }

  // Add some top spacing on the first content page for report and document
  if show-cover and (doc-type == "report" or doc-type == "document") {
    v(2em)
  }

  // Auto-insert table of contents if enabled
  if toc-depth > 0 {
    table-of-contents(depth: toc-depth)
  }

  // Exec-summary is self-contained (single page); skip body to avoid a blank second page
  if doc-type != "exec-summary" {
    body
  }
  } // else (fonts available)
  } // context font check
}

// ─────────────────────────────────────────────────────────────────────────────
// Poster functions  (@preview/isc-hei-poster)
//
// Public API:
//   isc-poster()    — top-level show rule; sets up the A1 page, header, footer
//   isc-card()      — section content box; wraps placard's card() with ISC styling
//   isc-colbreak()  — column break that also resets the distribute-columns state
//
// Internals (not exported):
//   _isc-poster-distribute  — state: whether distribute-columns is active
//   _isc-first-card         — state: true at the start of each column (no leading spacer)
// ─────────────────────────────────────────────────────────────────────────────

// A1 poster layout powered by @preview/placard.
//
// Parameters:
//   title              — main poster title (content; multi-line is fine)
//   subtitle           — optional subtitle rendered below the title in lighter weight
//   student            — student full name
//   permanent-email    — student permanent e-mail shown below the name (optional)
//   supervisor         — supervising professor
//   co-supervisor      — optional second supervisor
//   expert             — optional thesis expert / jury member
//   thesis-id          — optional thesis ID shown in the footer left in monospace
//   academic-year      — optional academic year shown in the footer left, e.g. "2025-2026"
//   school             — institution name (shown in affiliation line)
//   programme          — degree programme (shown in affiliation line)
//   major              — optional specialization appended to the affiliation line
//   orientation        — "portrait" (default) or "landscape" for A1 paper
//   language           — "fr" | "en" | "de" — controls label strings
//   logo               — right-side logo: auto → ISC logo PDF; none → suppress; or custom content
//   logo-height        — height of the right logo when logo: auto (default: 2.5cm)
//   hei-logo           — left-side logo:  auto → HEI logo PDF; none → suppress; or custom content
//   hei-logo-height    — height of the left logo when hei-logo: auto (default: 3.6cm)
//   num-columns        — number of card columns (default: 2)
//   distribute-columns — true → vertically space cards so columns fill top-to-bottom
//   repo-url           — optional repo / GitHub URL; generates a QR code + pill in the footer
//
// Usage:  #show: isc-poster.with(title: ..., student: ..., supervisor: ..., ...)
//         Then place content with #isc-card(title: "...")[...] blocks.
#let isc-poster(
  title: [Poster Title],
  subtitle: none,
  student: [Prénom Nom],
  permanent-email: none,
  supervisor: [Prof. Prénom Nom],
  co-supervisor: none,
  expert: none,
  thesis-id: none,
  academic-year: none,
  school: "Haute École d'Ingénierie de Sion",
  programme: "Informatique et Systèmes de communication (ISC)",
  major: none,
  orientation: "portrait",
  language: "fr",
  logo: auto,             // right-side logo: auto = ISC logo, none = suppress, or custom content
  logo-height: 2.5cm,     // height applied when logo: auto; ignored for custom content
  hei-logo: auto,         // left-side logo:  auto = HEI logo, none = suppress, or custom content
  hei-logo-height: 3.6cm, // height applied when hei-logo: auto; ignored for custom content
  num-columns: 2,
  distribute-columns: true,
  repo-url: none,         // optional repo / GitHub URL → QR code + pill in footer
  body,
) = {
  import "@preview/placard:0.1.0": placard as _placard
  // Import at function scope so tiaoma is always available for QR generation
  // regardless of which if/else branch runs (Typst imports are block-scoped).
  import "@preview/tiaoma:0.3.0"

  // ISC TB aggregator — not user-facing; update here when the URL moves.
  // TODO: update when the ISC TB website moves to its permanent address
  let _isc-tbs-website = "https://isc-hei.github.io/isc-tbs/"

  // ── Logo resolution ───────────────────────────────────────────────────────
  // auto → default logo at the given height; none → suppress; custom → pass through as-is.
  let isc-logo = if logo == auto {
    image("lib/assets/ISC Logo inline black v3.pdf", height: logo-height)
  } else if logo == none { none } else { logo }

  let resolved-hei-logo = if hei-logo == auto {
    image("lib/assets/hei_logo.pdf", height: hei-logo-height)
  } else if hei-logo == none { none } else { hei-logo }

  // ── Localised label strings for the author block ──────────────────────────
  let lbl = if language == "de" {
    (student: [Student·in], supervisor: [Betreuer·in],
     co-supervisor: [Co-Betreuer·in], expert: [Expert·in])
  } else if language == "fr" {
    (student: [Étudiant·e], supervisor: [Superviseur·e],
     co-supervisor: [Co-superviseur·e], expert: [Expert·e])
  } else {
    (student: [Student], supervisor: [Supervisor],
     co-supervisor: [Co-supervisor], expert: [Expert])
  }

  // ── Author entries: muted role label above the name ───────────────────────
  // placard renders each author entry in bold by default; explicit text() calls
  // override that so only the name uses the bold weight placard would apply.
  // sub: optional second line below the name (used for permanent-email).
  let make-entry = (l, val, sub: none) => stack(
    dir: ttb,
    spacing: 12pt,
    text(size: 16pt, weight: "regular", fill: luma(120), l),
    if sub != none {
      stack(dir: ttb, spacing: 8pt,
        val,
        text(size: 15pt, weight: "regular", fill: luma(160), sub))
    } else { val },
  )

  let authors-list = (
    (make-entry(lbl.student, student, sub: permanent-email),
     make-entry(lbl.supervisor, supervisor))
    + (if co-supervisor != none { (make-entry(lbl.co-supervisor, co-supervisor),) } else { () })
    + (if expert != none { (make-entry(lbl.expert, expert),) } else { () })
  )

  // ── Title block: title → subtitle → affiliation → accent line (placard) ──
  // Affiliation (school · programme · major?) sits between the subtitle and
  // placard's accent rule so the institutional context is visible without
  // crowding the heading.
  // set par() scoped to tight-title only via code block; stack() uses absolute
  // pt spacers to avoid implicit paragraph spacing artefacts.
  let tight-title = { set par(leading: 0.5em); title }
  let _affil-parts = (school, programme) + (if major != none { (major,) } else { () })
  let affiliation  = text(size: 18pt, weight: "regular", fill: luma(140),
    _affil-parts.join([  ·  ]))

  // pad(bottom: …) reduces the natural gap placard inserts between the title
  // content and its accent rule — negative value pulls them closer together.
  let full-title = pad(bottom: -25pt,
    if subtitle != none {
      stack(dir: ttb,
        tight-title,
        1cm,
        text(size: 28pt, weight: "regular", subtitle),
        8mm,
        affiliation,
      )
    } else {
      stack(dir: ttb, tight-title, 16pt, affiliation)
    }
  )

  // ── Dot decoration: brand dots fading left → right, bottom-right corner ──
  // 20 columns × 3 rows of circles; opacity increases toward the right edge.
  // Placed in the page background so poster content and footer sit on top.
  let _dot-d    = 5pt
  let _dot-gap  = 4pt
  let _n-cols   = 20
  let _n-rows   = 3
  // Pre-computed transparency steps: index 0 = leftmost (nearly invisible),
  // index 19 = rightmost (fully opaque). Hard-coded to avoid float→ratio arithmetic.
  let _t-steps  = (95%, 90%, 85%, 80%, 75%, 70%, 65%, 60%, 55%, 50%,
                    45%, 40%, 35%, 30%, 25%, 20%, 15%, 10%,  5%,  0%)
  let _dot-grid = grid(
    columns: range(_n-cols).map(_ => _dot-d + _dot-gap),
    rows:    range(_n-rows).map(_ => _dot-d + _dot-gap),
    align:   center + horizon,
    ..range(_n-cols * _n-rows).map(idx => {
      let col = calc.rem(idx, _n-cols)
      circle(radius: _dot-d / 2,
             fill: inc.hei-purple.transparentize(_t-steps.at(col)),
             stroke: none)
    })
  )
  set page(background: place(bottom + right,
    pad(right: 2.5cm, bottom: 2.2cm, _dot-grid)
  ))

  // ── Page header: HEI logo left, ISC logo right ────────────────────────────
  // set page(header:) merges with the background set above and with placard's
  // set page(paper:, margin:, footer:) since neither touches the other's keys.
  // top padding: distance from paper edge to logo top.
  // bottom padding: breathing room between logo bottom and the title block.
  // The top margin passed to _placard (6cm) must clear logo height + padding.
  set page(header: pad(top: 2.5cm, bottom: 0.8cm,
    grid(
      columns: (auto, 1fr, auto),
      align: horizon,
      if resolved-hei-logo != none { resolved-hei-logo },
      [],
      if isc-logo != none { isc-logo },
    )
  ))

  // ── QR helper ─────────────────────────────────────────────────────────────
  let _make-qr(url) = box(fill: white, inset: 4pt, radius: 2pt,
    tiaoma.barcode(url, "QRCode", options: (
      scale: 1.6, fg-color: black, bg-color: white, dot-size: 1.0,
      output-options: (barcode-dotty-mode: false),
    ))
  )

  // ── Institutional info block — bottom-left foreground overlay ─────────────
  // Sits on top of the footer accent line (foreground layer).
  // Layout: ISC TB QR on the left, programme · major · academic-year stacked on the right.
  let _info-text-parts = (
    (programme,)
    + (if major         != none { (major,)         } else { () })
    + (if academic-year != none { (academic-year,) } else { () })
  )

  let _info-block = grid(
    columns: (auto, auto),
    column-gutter: 5mm,
    align: horizon,
    _make-qr(_isc-tbs-website),
    stack(dir: ttb, spacing: 8pt,
      ..(_info-text-parts.enumerate().map(((i, part)) =>
        text(
          font: "Source Sans Pro",
          size: if i == 0 { 18pt } else { 16pt },
          weight: if i == 0 { "semibold" } else { "regular" },
          fill: if i == 0 { luma(50) } else { luma(110) },
          part,
        )
      ))
    ),
  )

  // ── GitHub repo QR — bottom-right foreground overlay (optional) ───────────
  let _repo-block = if repo-url != none {
    stack(dir: ttb, spacing: 4pt,
      _make-qr(repo-url),
      align(center,
        box(
          fill: inc.hei-purple.lighten(85%),
          radius: 100pt,
          inset: (x: 10pt, y: 5pt),
          text(font: "Source Sans Pro", size: 14pt, weight: "semibold",
               fill: inc.hei-purple, "GitHub")
        )
      ),
    )
  }

  // Both overlays share one foreground so neither overrides the other.
  set page(foreground: {
    place(bottom + left,  pad(left:  2.5cm, bottom: 1.6cm, _info-block))
    if _repo-block != none {
      place(bottom + right, pad(right: 2cm, bottom: 1cm, _repo-block))
    }
  })

  // ── Initialise distribute-columns state before body renders ───────────────
  // State updates must appear before the content that reads them in document flow.
  _isc-poster-distribute.update(distribute-columns)
  _isc-first-card.update(true)
  // Pull every column's first card up by this amount to close the gap below the authors.
  _isc-col-start-offset.update(-0.6cm)

  // ── Hand off to placard ───────────────────────────────────────────────────
  // footer.content: thesis ID + academic year (simple text, left-aligned).
  // footer.logo: none — QR codes live in the page foreground above.
  _placard(
    title: full-title,
    authors: authors-list,
    paper: "a1",
    flipped: orientation == "landscape",
    num-columns: num-columns,
    // top margin = space reserved for the title block (title+subtitle+affiliation+authors).
    // Increase if the title block overflows into the cards; decrease to close the gap
    // between the authors row and the first card column.
    margin: (top: 6.3cm),
    colors: (
      accent:  inc.hei-purple,
      heading: inc.hei-purple,
    ),
    fonts: (
      title:    "Source Sans Pro",
      authors:  "Source Sans Pro",
      body:     "Source Sans Pro",
      headings: "Source Sans Pro",
      card:     "Source Sans Pro",
      footer:   "Source Sans Pro",
    ),
    sizes: (authors: 22pt),
    footer: (
      // Institutional block (left) and repo QR (right) live in the page foreground.
      content: [],
      logo: none,
      logo-placement: right,
      text-placement: left,
    ),
    body,
  )
}

// Section content box for use inside isc-poster().
//
// Wraps @preview/placard's card() with ISC colours and optional vertical
// distribution.  When distribute-columns is active (the default), a leading
// v(1fr) is injected before every card except the first in each column, giving
// space-between semantics: first card at the top, last card at the bottom,
// equal space distributed between them.
//
// gap: auto  → 0pt when distributing (no trailing gap after last card);
//              placard default otherwise.
//      length → explicit override, always applied.
#let isc-card(title: "", fill: none, gap: auto, body) = {
  import "@preview/placard:0.1.0": card as _card
  // First card in each column: apply the column-start offset (closes the gap below
  // the authors block for every column equally). Subsequent cards get v(1fr) for
  // space-between distribution.
  context {
    if _isc-poster-distribute.get() {
      if _isc-first-card.get() { v(_isc-col-start-offset.get()) }
      else { v(1fr) }
    }
  }
  _isc-first-card.update(false)
  // Resolve effective gap: suppress trailing space when distributing so the
  // last card sits flush with the column bottom.
  context {
    let effective-gap = if gap != auto { gap }
                        else if _isc-poster-distribute.get() { 0pt }
                        else { none }
    _card(title: title, fill: fill, gap: effective-gap, body)
  }
}

// Column break that resets the first-card flag for the new column.
// Always use #isc-colbreak() instead of #colbreak() when distribute-columns is
// active, otherwise the leading spacer logic mis-fires in the next column.
#let isc-colbreak() = {
  _isc-first-card.update(true)
  colbreak()
}
