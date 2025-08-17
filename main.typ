#import "lincoln.typ" as lincoln


#let citet(..citation) = {
  cite(..citation, form: "prose")
}

// #bibliography("references.bib", title:"References", style:"ieee")

// #show: lincoln.with(
//   title: [My amazing project],
//   abstract: [
//     I did a thing.
//   ],
//   acknowledgements: [
//     To me, myself, and I.
//   ],
//   authors: (
//     (
//       name: "name name",
//       department: [School of Engineering and Physical Sciences],
//       organization: [College of ?],
//       location: [University of Lincoln],
//       email: "number@students.lincoln.ac.uk"
//     ),
//   ),
//   bibliography: bibliography("references.bib"),
//   paper-size: "lincoln",
//   figure-supplement: [Fig.],
// )
//
// = Introduction
// // Scientific writing is a crucial part of the research process, allowing researchers to share their findings with the wider scientific community. However, the process of typesetting scientific documents can often be a frustrating and time-consuming affair, particularly when using outdated tools such as LaTeX. Despite being over 30 years old, it remains a popular choice for scientific writing due to its power and flexibility. However, it also comes with a steep learning curve, complex syntax, and long compile times, leading to frustration and despair for many researchers @netwok2020 @netwok2022.
// Amazing introduction.
// @stevenson2024open did good work.
//
// = Methods <sec:methods>
//
//
//
// #figure(
//   caption: [The Planets of the Solar System and Their Average Distance from the Sun],
//   placement: none,
//   table(
//     // Table styling is not mandated by the IEEE. Feel free to adjust these
//     // settings and potentially move them into a set rule.
//     columns: (6em, auto),
//     align: (left, right),
//     inset: (x: 8pt, y: 4pt),
//     stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
//     fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },
//
//     table.header[Planet][Distance (million km)],
//     [Mercury], [57.9],
//     [Venus], [108.2],
//     [Earth], [149.6],
//     [Mars], [227.9],
//     [Jupiter], [778.6],
//     [Saturn], [1,433.5],
//     [Uranus], [2,872.5],
//     [Neptune], [4,495.1],
//   )
// ) <tab:planets>
//
// In @tab:planets, you see the planets of the solar system and their average distance from the Sun.
// The distances were calculated with @eq:gamma that we presented in @sec:methods.



#show: doc => lincoln.init(doc)
#show: doc => lincoln.TitlePage(doc)
#include "chapters/title-page.typ"
#pagebreak()

#show: doc => lincoln.MainBody(doc)
#include "chapters/acknowledgements.typ"
#include "chapters/abstract.typ"
//
// // Table of contents
//
#outline(title: "List of Figures", target: figure.where(kind: image))

// #pagebreak()

#outline(title: "List of Tables", target: figure.where(kind: table))

// TODO: List of listings

// // Reset heading counter (so the chapters start from 1).
#counter(heading).update(0)
//
#show: doc => lincoln.MainBody(doc)
#include "chapters/introduction.typ"

// @stevenson2024open what

#figure(
  placement: none,
  circle(radius: 15pt),
  caption: [A circle representing the Sun.]
) <fig:sun>
//
// #pagebreak()
//
// // References section
#show: doc => lincoln.References(doc)
#bibliography("references.bib", title:"References", style: "harvard-cite-them-right")
