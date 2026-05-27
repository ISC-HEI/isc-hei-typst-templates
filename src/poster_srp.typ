#import "@preview/isc-hei-poster:0.7.2": isc-poster-srp, isc-section
#import "@preview/cetz:0.4.0": canvas, draw

// ─── Dodecahedron figure (reused from exec-summary) ──────────────────────────
#let ex_fig = canvas(length: 2cm, {
  import draw: *
  let phi = (1 + calc.sqrt(5)) / 2
  ortho({
    hide({
      line((-phi, -1, 0), (-phi, 1, 0), (phi, 1, 0), (phi, -1, 0), close: true, name: "xy")
      line((-1, 0, -phi), (1, 0, -phi), (1, 0, phi), (-1, 0, phi), close: true, name: "xz")
      line((0, -phi, -1), (0, -phi, 1), (0, phi, 1), (0, phi, -1), close: true, name: "yz")
    })
    intersections("a", "yz", "xy")
    intersections("b", "xz", "yz")
    intersections("c", "xy", "xz")
    set-style(stroke: (thickness: 0.5pt, cap: "round", join: "round"))
    line((0, 0, 0), "c.1", (phi, 1, 0), (phi, -1, 0), "c.3")
    line("c.0", (-phi, 1, 0), "a.2")
    line((0, 0, 0), "b.1", (1, 0, phi), (-1, 0, phi), "b.3")
    line("b.0", (1, 0, -phi), "c.2")
    line((0, 0, 0), "a.1", (0, phi, 1), (0, phi, -1), "a.3")
    line("a.0", (0, -phi, 1), "b.2")
    anchor("A", (0, phi, 1))
    content("A", [$A$], anchor: "north", padding: .1)
    anchor("B", (-1, 0, phi))
    content("B", [$B$], anchor: "south", padding: .1)
    anchor("C", (1, 0, phi))
    content("C", [$C$], anchor: "south", padding: .1)
    line("A", "B", stroke: (dash: "dashed"))
    line("A", "C", stroke: (dash: "dashed"))
  })
})

// ─── Choose orientation: "portrait" or "landscape" ──────────────────────────
#let poster-orientation = "portrait"

#show: isc-poster-srp.with(
  title: [Titre du poster de recherche],
  subtitle: [Sous-titre du poster],
  student: "Barbara Liskov",
  supervisor: "Prof. Dr John von Neumann",
  // co-supervisor: "Lady Ada Lovelace",  // optional
  thesis-id: "ISC-ID-26-1",
  orientation: poster-orientation,
  language: "fr",
)

#let num-cols = if poster-orientation == "portrait" { 2 } else { 3 }

#let col1 = [
  #isc-section[Résumé][
    #lorem(60)
  ]

  #isc-section(fill: true)[Introduction][
    #lorem(50)

    #figure(
      grid(
        columns: (1fr, 1fr),
        gutter: 8pt,
        align(center + horizon, ex_fig),
        image("figs/made.svg", height: 10cm, fit: "contain"),
      ),
      caption: [Structure de graphe du réseau de capteurs (gauche) et pipeline de traitement (droite)],
    )
  ]

  #isc-section[Méthode][
    #lorem(60)
  ]
]

#let col2 = [
  #isc-section(fill: true)[Résultats][
    #lorem(70)

    #figure(
      rect(width: 100%, height: 11cm, fill: luma(240), stroke: none,
        align(center + horizon)[_Graphique des résultats_]),
      caption: [Performance des algorithmes],
    )
  ]

  #isc-section[Discussion][
    #lorem(60)

    #table(
      columns: (auto, 1fr, 1fr),
      inset: 8pt,
      align: center,
      table.header([*Paramètre*], [*Valeur A*], [*Valeur B*]),
      [Alpha], [0.92], [0.88],
      [Beta],  [1.14], [1.07],
      [Gamma], [0.75], [0.81],
    )

    #figure(
```python
def hybrid_score(x, alpha=0.6):
    if_score  = iso_forest.score_samples([x])[0]
    rnn_score = lstm_model.predict(x[None, :, :])
    return alpha * (-if_score) + (1 - alpha) * rnn_score
```,
      caption: [Score hybride — α appris par validation croisée.],
    )
  ]

  // In portrait mode this column also holds conclusion / references
  #if num-cols == 2 [
    #isc-section[Conclusion][
      #lorem(50)
    ]

    #isc-section(fill: true)[Remerciements][
      Les auteurs remercient #lorem(20)
    ]

    #isc-section[Références][
      + A. Auteur, _Titre de l'article_, Journal XYZ, vol. 1, pp. 1–10, 2024.
      + B. Auteur, _Another Reference_, Conference ABC, 2025.
      + C. Auteur et al., _Yet Another Work_, arXiv:2501.00001, 2025.
    ]
  ]
]

#let col3 = [
  #isc-section[Conclusion][
    #lorem(50)
  ]

  #isc-section(fill: true)[Remerciements][
    Les auteurs remercient #lorem(20)
  ]

  #isc-section[Références][
    + A. Auteur, _Titre de l'article_, Journal XYZ, vol. 1, pp. 1–10, 2024.
    + B. Auteur, _Another Reference_, Conference ABC, 2025.
    + C. Auteur et al., _Yet Another Work_, arXiv:2501.00001, 2025.
  ]
]

#pad(
  grid(
    columns: num-cols,
    inset: 25pt,
    gutter: 10pt,
    col1,
    col2,
    ..if num-cols == 3 { (col3,) } else { () },
  ),
  top: 20pt,
  x: 20pt,
)
