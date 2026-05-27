// Déclaration sur l'honneur — Travail de Bachelor
// Filière Informatique et systèmes de communication (ISC)
// Haute École d'Ingénierie — HES-SO Valais-Wallis
//
#import "@preview/isc-hei-bthesis:0.7.9" : *

#page-title("Résumé")

#v(1fr)

//#set par(justify: true, leading: 0.65em)

// Champ à remplir : étiquette + ligne pointillée
#let champ(label) = [
  *#label* #h(0.6em) #box(width: 1fr)[#repeat[.]]
]

// En-tête
#align(center)[
  #text(size: 16pt, weight: "bold")[
    Déclaration sur l'honneur
  ]

  #v(0.4em)

  #text(size: 11pt)[
    Travail de Bachelor
  ]

  #v(0.2em)

  #text(size: 10pt, style: "italic")[
    Filière Informatique et systèmes de communication (ISC) \
    Haute École d'Ingénierie — HES-SO Valais-Wallis
  ]
]

#v(1.2em)
#line(length: 100%, stroke: 0.5pt)
#v(1.2em)

// Identification
#champ[Nom]

#v(0.4em)

#champ[Prénom]

#v(0.4em)

#champ[Titre du travail]

#v(0.4em)

#champ[Année académique]

#v(1.5em)

déclare sur l'honneur :

#v(0.6em)

#set enum(numbering: "1.", indent: 0pt, body-indent: 0.8em, spacing: 0.7em)

+ avoir pris connaissance des règles relatives à la prévention du plagiat dans le cadre du travail de Bachelor de la filière ISC, et m'engager à les respecter ;

+ que le travail soumis est le fruit de ma réflexion personnelle et qu'il a été réalisé de manière autonome ;

+ que toute formulation, idée, raisonnement, analyse, donnée, image, schéma ou fragment de code source empruntés à un tiers — y compris à un outil d'intelligence artificielle générative — sont clairement signalés comme tels et que leur source est précisément indiquée, conformément aux règles de citation en vigueur ;

+ avoir déclaré de manière transparente tout recours à un outil d'intelligence artificielle générative, en précisant l'outil utilisé, les finalités et les passages concernés ;

+ ne pas avoir eu recours au plagiat, à l'autoplagiat, au _ghostwriting_ ni à toute autre forme de fraude académique ;

+ avoir conscience que la transgression des règles ci-dessus peut entraîner des sanctions allant de la note de 1.0 à l'exclusion de la formation, voire au retrait du titre obtenu ;

+ accepter que mon travail puisse être analysé au moyen d'un logiciel de détection de similitudes (Compilatio) ou par tout autre moyen approprié.

#v(2em)

#champ[Lieu et date]

#v(1.2em)

#champ[Signature]

#v(1fr)

#line(length: 100%, stroke: 0.3pt)

#v(0.5em)

#text(size: 8pt, style: "italic")[
  Document inspiré de la Directive 0.3 de l'Université de Lausanne, de la Directive en matière de plagiat des étudiant·e·s de l'Université de Genève, et du formulaire de Déclaration sur l'honneur de l'Université de Neuchâtel.
]
