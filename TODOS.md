For version 0.8.1

## Bachelor thesis
  - German translation of the template
  - Unknown font family: source sans 3 (warning) in web editor. We should leave it like this for now.
  - Move declaration of honour to the template, not user-facing file, and only ask for the signature image in the user-facing file.
  - Remove `doc-type: "thesis"` and `split-chapters: true` from the example. Should not be user-facing.
  - This is ugly as well for the end-user : 
    ```
    //////////////
    // Appendices
    ////////////// 
    #cleardoublepage()
    #appendix-page()
    #pagebreak()

    // Table of acronyms, NOT COMPULSORY
    #print-index(
      title: page-title(i18n(doc_language, "acronym-table-title"), mult:1, top:1em, bottom: 1em),
      sorted: "up",
      delimiter: " : ",
      row-gutter: 0.7em,
      outlined: false,  
    ) 
    ```

## Executive summary
- German translation
- Reduce the user-facing interface for the example if possible (`doc-type` etc.)

## Document
- German translation as well

## Poster
- Print one to see how it looks like, and adjust the font size if needed, for (0.8.0)

## Global
- have something like a global enum to choose among the different majors, and use it in the various templates throughout
- some easter egg game in the library ? 
- Put more than one picture in the README.md of the different templates, to make it more appealing.
- Verify on the typst universe that the templates are tagged as official.
- Make a whole review of the code to check for any possible improvement, and to make sure that the code is clean and well documented.
- Include feedback from all stakeholders, review after everyone handed in their project, and make the necessary adjustments to the templates for the next academic year.