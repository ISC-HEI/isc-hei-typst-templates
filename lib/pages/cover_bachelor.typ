#import "../includes.typ" as inc
#import "/isc_templates.typ" as isc

// Adapted from https://github.com/LasseRosenow/HAW-Hamburg-Typst-Template/tree/main

#let cover_page(
  supervisors: none,
  expert: none,
  font: "",
  title: "",
  subtitle: none,
  semester: "",
  academic-year: "",
  school: "",
  programme: "",
  major: "",
  authors: "",
  thesis-id: none,
  submission-date: "",
  revision: none,
  logo: none,
  language: "",
) = {
  // A missing thesis ID is no longer fatal: it is surfaced by the completeness
  // warning block below instead of aborting the compile.
  let thesis-id = if thesis-id == none { "" } else { thesis-id }

  let i18n = isc.i18n.with(extra-i18n: none, language)

  let hei-purple = inc.hei-purple
  let right-margin = 12mm
  let left-margin = 35mm

  // Set the document's basic properties.
  set page(margin: (left: 0mm, right: right-margin, top: 0mm, bottom: 0mm), numbering: none, number-align: center)

  // ── Completeness check (drafting aid) ───────────────────────────────────────
  // The sentinels mirror the placeholder values shipped in src/bachelor_thesis.typ.
  // While the document still carries the template's sample author we assume the
  // student hasn't started and stay silent; once they set their own name we flag
  // every required field still left empty or at its shipped placeholder value.
  let sample-author    = "James Gosling"
  let sample-thesis-id = "ISC-ID-26-1"
  let sample-repo      = "https://isc.hevs.ch"
  let sample-keywords  = ("engineering", "data", "machine learning", "meteorology")
  // Expected reference format: ISC-XX-YY-N (XX = two letters, YY = two-digit
  // year, N = one or more digits), e.g. ISC-SE-26-3.
  let id-pattern       = regex("^ISC-[A-Za-z]{2}-[0-9]{2}-[0-9]+$")
  let fr = language == "fr"

  context {
    let repo      = inc.global-project-repos.get()
    let keywords  = inc.global-keywords.get()
    let signature = inc.global-thesis-meta.get().at("signature", default: none)
    // An image element exposes its path via `.source`; we use it to tell whether
    // the student is still pointing at the shipped placeholder signature file.
    let sig-src   = if signature != none and "source" in signature.fields() { signature.fields().at("source") } else { none }

    let issues = ()
    if str(authors) != sample-author {
      if thesis-id in (none, "", sample-thesis-id) {
        issues.push(if fr [La référence du travail (`thesis-id`) n'a pas été mise à jour.] else [The thesis reference (`thesis-id`) has not been updated.])
      } else if str(thesis-id).match(id-pattern) == none {
        issues.push(if fr [Le format de la référence (`thesis-id`) est invalide — attendu p. ex. `ISC-SE-26-3`.] else [The thesis reference (`thesis-id`) format is invalid — expected e.g. `ISC-SE-26-3`.])
      }
      if signature == none {
        issues.push(if fr [L'image de la signature (`signature`) est manquante.] else [The signature image (`signature`) is missing.])
      } else if type(sig-src) == str and sig-src.contains("signature_placeholder") {
        issues.push(if fr [L'image de la signature (`signature`) doit être remplacée par la vôtre.] else [The signature image (`signature`) must be replaced with your own.])
      }
      if repo in (none, "", sample-repo) {
        issues.push(if fr [Le lien du dépôt Git (`project-repos`) n'a pas été mis à jour.] else [The Git repository link (project-repos) has not been updated.])
      }
      if keywords == () or keywords == sample-keywords {
        issues.push(if fr [Les mots-clés (keywords) n'ont pas été modifiés.] else [The keywords (keywords) have not been changed.])
      }
    }

    if issues.len() > 0 {
      place(top + left, dx: left-margin, dy: 14mm, box(
        width: 210mm - left-margin - right-margin,
        fill: rgb("#ffe3e3"),
        stroke: 2.5pt + rgb("#c1121f"),
        radius: 4pt,
        inset: 10pt,
        {
          set text(font: font, fill: rgb("#9d0208"))
          text(weight: 900, size: 13pt, if fr [⚠ DOCUMENT INCOMPLET — à compléter avant le rendu] else [⚠ INCOMPLETE DOCUMENT — complete before submission])
          v(4pt)
          set text(size: 10pt, weight: 500)
          for it in issues {
            block(below: 5pt, [— #it])
          }
        },
      ))
    }
  }

  let title_block = if subtitle == none {
    stack(par(leading: 11pt, text(title, size: 24pt, weight: 660)), v(5mm))
  } else {
    stack(
      par(leading: 11pt, text(title, size: 24pt, weight: 660)),
      v(7mm),
      par(leading: 11pt, text(subtitle, size: 12pt)),
      v(12mm),
    )
  }

  // Title etc.
  pad(
    left: left-margin,
    top: 60mm,
    right: right-margin,
    stack(
      // Type
      let thesis-title = i18n("bachelor-thesis-title"),
      upper(text(thesis-title, size: 15pt, weight: "black")),
      v(4mm),
      // Author
      text(authors, size: 18pt),
      v(50mm),
      // Title
      title_block,
      
      v(35mm),
      
      // Decorative line: hash-encoded bit pattern (square ends + circle bits).
      // dy pulls the box up by half its height so the rule sits on the baseline,
      // matching the original zero-height placement.
      place(dy: -4pt, isc.hash-rule(thesis-id + authors)),
      v(5mm),
      text(programme, size: 14pt, weight: 650),
      v(3mm),
      text(i18n("thesis-id-title") + " " + thesis-id, size: 9pt),
    ),
  )

  // University identity block
  place(
    right + bottom,
    dx: -right-margin,
    dy: -20mm,
    box(
      align(
        right,
        stack(
          move(dy: -0mm, image("../assets/HES-SO_logo_CMJN.svg", width: 3.5cm)),
          // Decorative line: hei-hei-purple square on the left, line with hei-purple circles
          {
            let line-length = 3.5cm // 3.5cm + 2cm extra on left
            let line-thickness = 1.0pt
            let square-size = 5pt
            let circle-r = 2.2pt

            // The main line
            // line(start: (0pt, 0pt), length: line-length, stroke: (thickness: line-thickness, dash: "solid", paint: black))

            // hei-purple square at the far left
            //place(dx: 4.1cm, dy: -square-size / 2, rect(width: square-size, height: square-size, fill: hei-purple, stroke: none))
            // hei-purple circles at fixed positions along the line
            // for dx-val in (0.8cm, 1.6cm, 2.3cm, 3.1cm) {
            //   place(dx: dx-val, dy: -circle-r, circle(radius: circle-r, fill: hei-purple, stroke: none))
            // }
          },
          v(3mm),
          text(i18n("hes-so"), size: 9pt, weight: "bold"),
          v(2mm),
          text(i18n("faculty"), size: 9pt),
          v(2mm),
          text(school, size: 9pt),
        ),
      ),
    ),
  )

  //
  // Second cover page
  //
  isc.cleardoublepage()

  set page(margin: (left: 31.5mm, right: 32mm, top: 75mm, bottom: 25mm), numbering: none, number-align: center)

  // School logo
  place(top + center, dx: 0mm, dy: -55mm, image("../assets/isc_logo.svg", height: 1.4cm))


  stack(
    // Author
    align(center, text(authors, size: 18pt)),
    v(23mm),
  )

  align(center, par(leading: 13pt, text(title, size: 22pt, weight: 620)))
  v(8mm)

  if (subtitle != none) {
    align(center, par(leading: 13pt, text(subtitle, size: 12pt)))
  }

  v(18mm)
  context{    
    let repo = str(inc.global-project-repos.get())
    stack(
      align(center, text(i18n("repository"))),
      v(3mm),
      align(center, link(repo, text(size: 10pt, font: "Fira Code", repo)))    
    )
  }
  
  v(1fr)

  stack(
    stack(
      spacing: 3mm,
      text(i18n("thesis-submitted")),
      text(programme + " – " + major + " major", style: "italic"),
      text(school),
    ),
    v(6mm),
    line(start: (0pt, 0pt), length: 25pt, stroke: 1mm),
    v(6mm),
    let colon = if language == "fr" { " : " } else { ": " },
    if supervisors.len() > 0 {
      if type(supervisors) != array {
        text(i18n("supervising-examiner") + colon + text(upper(supervisors), weight: "bold"), size: 10pt)
      } else {
        text(i18n("supervising-examiner") + colon + text(upper(supervisors.first()), weight: "bold"), size: 10pt)

        if supervisors.len() > 1 {
          linebreak()
          text(i18n("supervising-second-examiner") + colon + text(upper(supervisors.at(1)), weight: "bold"), size: 10pt)
        }
      }
    },
    if expert != none {
      linebreak()
      text(i18n("supervising-expert") + colon + text(upper(expert), weight: "bold"), size: 10pt)
    },
    if submission-date != none {
      stack(v(6mm), line(start: (0pt, 0pt), length: 25pt, stroke: 1mm), v(6mm), text(
        i18n("submitted-on") + " " + inc.custom-date-format(submission-date, pattern: i18n("date-format") + " - " + i18n("revision") + " - " + revision, lang: language),
        size: 10pt,
      ))
    }
  )
}