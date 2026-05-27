// Shared document-wide constants and package metadata.
// Paths here are relative to lib/, so the package root is one level up.

#import "includes.typ" as inc

// Heading / typography metrics shared across every document type.
#let space-after-heading = 0.8em
#let chapter-font-size = 1.5em
#let chapter-font-weight = 700
#let body-font-size = 11pt

// Background fill used behind inline code and code listings.
#let _luma-background = luma(250)

// Re-exported convenience handles.
#let global-keywords = inc.global-keywords
#let version = toml("../typst.toml").package.version
