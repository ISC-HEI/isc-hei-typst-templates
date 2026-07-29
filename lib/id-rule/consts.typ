#let permutations = (
  (0, 3, 1, 2),
  (2, 3, 0, 1),
  (1, 3, 2, 0),
  (2, 1, 0, 3),
  (3, 2, 0, 1),
  (2, 1, 3, 0),
  (3, 2, 1, 0),
  (1, 0, 2, 3),
  (3, 1, 2, 0),
)

#let majors = (
  "IL", // Informatique logicielle
  "SE", // Systèmes informatiques embarqués
  "RS", // Réseaux et systèmes
  "SI", // Sécurité informatique
  "ID"  // Ingénierie des données
)

#let thesis-id-regex = regex(`ISC-[A-Z]{2}-\d+-\d+`.text)