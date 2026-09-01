#import "consts.typ": thesis-id-regex, majors
#import "encoding.typ": to-trits
#import "shuffle.typ": shuffle
#import "hamming.typ"
#import "masks.typ"

#let build-code(thesis-id) = {
  assert(
    thesis-id.match(thesis-id-regex)!= none,
    message: "Invalid thesis id format '" + thesis-id +"'. Must be ISC-XX-dd-d"
  )
  let (isc, major, year, id) = thesis-id.split("-")
  assert(
    major in majors,
    message: "Invalid major '" + major + "'. Must be one of: " + majors. join(", ")
  )
  let major-id = majors.position(m => m == major)
  year = int(year)
  id = int(id)
  assert(
    0 <= year and year < 81,
    message: "Invalid year " + str(id) + ". Must be between 0 and 81"
  )
  assert(
    0 <= id and id < 81,
    message: "Invalid id " + str(id) + ". Must be between 0 and 81"
  )

  // major: 0-8 (2 trits)
  // year: 0-80 (4 trits)
  // id: 0-80 (4 trits)

  let trits = to-trits(major-id, n-trits: 2) + to-trits(year, n-trits: 4) + to-trits(id, n-trits: 4)
  trits = shuffle(trits)
  let encoded = hamming.encode(trits, block-size: 14)

  let mask-i = masks.choose(encoded)
  return masks.apply-and-insert-id(encoded, mask-i)
}
