## Bachelor thesis 
- add the déclaration sur l'honneur

## Poster

I need to verify that the poster template works correctly for various inputs. Generate all variations of the poster to test the layout, and check if the content fits well in all of them. In particular:
- control 2 and 3 columns as well
- long and short titles
- various contents (but always on the single poster page, no overflow)
- with and without subtitles
- with and without supervisor
- check landscape mode
- english, french and german variants

I might need to use a similar approach for the executive summary template as well, but let's start with the poster.

- print one to see how it looks like, and adjust the font size if needed

### Findings (verified via `just test-poster-variants`)
- ✅ **FIXED: `supervisor: none` left an orphaned label.** The supervisor entry was
  unconditionally added to `authors-list`; now guarded with `if supervisor != none`
  like `co-supervisor` and `expert`.
- ✅ **FIXED: published poster package was broken** — `just pack`/Universe releases
  shipped a poster that fails to compile:
    - `templates/poster/README.md` was missing (every other template has one, and
      `scripts/pack` copies it unconditionally) → created.
    - `lib/assets/hei_logo.pdf` was excluded by `.typstignore` (globs out `*.pdf`,
      only whitelisted the ISC logo). The poster is the only template using the HEI
      logo, so the packed package errored with "file not found" → added
      `!lib/assets/hei_logo.pdf`.
  **→ Needs a patch release to republish a working poster on Typst Universe.**
- ✅ **FIXED: long justified titles hyphenated mid-word** (FR "hospitalières" →
  "hospital-ières"). Title block now sets `text(hyphenate: false)`.
- **Content budget (one A1 page):** portrait holds 9+ cards comfortably; landscape
  is much tighter (~6 cards max — 7+ overflows) because the page is ~30% shorter.
- All languages (fr/en/de), 2/3 columns, both orientations, and short/long titles
  compile and render correctly; overflow is only ever a function of content volume.
- Regression check: `scripts/test-poster-variants.sh` (also part of `just test-all`).

## Global

- the isc_templates file is a mess -> separate it into multiple files, e.g. one for the poster, one for the thesis, etc.
- automate the submission process for deploying on the typst universe, with manual checking