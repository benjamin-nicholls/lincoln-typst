#let current-chapter-title() = context {
  let headings = query(heading.where(level: 1).before(here()))
  if headings == () { "" } else {
  headings.last().body}
}

#let lincoln(
  // The paper's title.
  title: [Paper Title],

  // An array of authors. For each author you can specify a name,
  // department, organization, location, and email. Everything but
  // but the name is optional.
  authors: (),

  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,
  acknowledgements: none,

  // A list of index terms to display after the abstract.
  index-terms: (),

  // The article's paper size. Also affects the margins.
  paper-size: "lincoln",

  // The result of a call to the `bibliography` function or `none`.
  bibliography: none,

  // How figures are referred to from within the text.
  // Use "Figure" instead of "Fig." for computer-related publications.
  figure-supplement: [Figure],

  // The paper's content.
  body
) = {
  let indent-amount = 1em
  // Set document metadata.
  set document(title: title, author: authors.map(author => author.name))

  // Set the body font.
  // As of 2024-08, the IEEE LaTeX template uses wider interword spacing
  // - See e.g. the definition \def\@IEEEinterspaceratioM{0.35} in IEEEtran.cls
  //TeX Gyre Termes
  set text(font: "CMU Serif", size: 12pt, weight:"regular", spacing: 200%)

  // Enums numbering
  set enum(numbering: "1.1.1")

  // Tables & figures
  show figure: set block(spacing: 15.5pt)
  show figure: set place(clearance: 15.5pt)
  show figure.where(kind: table): set figure.caption(position: top, separator: [\ ])
  show figure.where(kind: table): set text(size: 8pt)
  show figure.where(kind: table): set figure(numbering: "I")
  show figure.where(kind: image): set figure(supplement: figure-supplement, numbering: "1")
  show figure.caption: set text(size: 8pt)
  show figure.caption: set align(start)
  show figure.caption.where(kind: table): set align(center)

  // Adapt supplement in caption independently from supplement used for
  // references.
  set figure.caption(separator: [. ])
  show figure: fig => {
    let prefix = (
      if fig.kind == table [TABLE]
      else if fig.kind == image [Fig.]
      else [#fig.supplement]
    )
    let numbers = numbering(fig.numbering, ..fig.counter.at(fig.location()))
    // Wrap figure captions in block to prevent the creation of paragraphs. In
    // particular, this means `par.first-line-indent` does not apply.
    // See https://github.com/typst/templates/pull/73#discussion_r2112947947.
    show figure.caption: it => block[#prefix~#numbers#it.separator#it.body]
    show figure.caption.where(kind: table): smallcaps
    fig
  }

  // Code blocks
  show raw: set text(
    font: "TeX Gyre Cursor",
    ligatures: false,
    size: 1em / 0.8,
    spacing: 100%,
  )

  // Configure the page and multi-column properties.
  set columns(gutter: 12pt)
  set page(
    columns: 1,
    // paper: paper-size,
    paper: if paper-size == "lincoln" { "a4" } else { paper-size },
    // The margins depend on the paper size.
    margin: if paper-size == "a4" {
      (x: 41.5pt, top: 80.51pt, bottom: 89.51pt)
    } else if paper-size == "lincoln" {
      (top: 15mm, bottom: 25mm, right: 25mm, left: 40mm,)
    } else { 
      (
        x: (50pt / 216mm) * 100%,
        top: (55pt / 279mm) * 100%,
        bottom: (64pt / 279mm) * 100%,
      )
    },
    footer: context [
        #set align(right)
        #set text(size: 10pt)
        // TODO: This should not be shown on pages where the title is defined.
        #emph[#current-chapter-title()]
        #h(0.25cm)
        #text(weight: "bold")[
        #counter(page).display("1")
    ]]
  )

  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 0.65em)

  // Configure appearance of equation references.
  show ref: it => {
    if it.element != none and it.element.func() == math.equation {
      // Override equation references.
      link(it.element.location(), numbering(
        it.element.numbering,
        ..counter(math.equation).at(it.element.location())
      ))
    } else {
      // Other references as usual.
      it
    }
  }

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  set heading(numbering: "1.1.1")
  show heading: it => {
  //   // Find out the final number of the heading counter.
    let levels = counter(heading).get()
    let deepest = if levels != () {
      levels.last()
    } else {
      1
    }
    set text(12pt, weight: "regular")
    set par(first-line-indent: (amount: 0em))
    if it.level == 1 {
      pagebreak(weak:true)
      // We don't want to number the acknowledgment section.
      let is-ack = it.body in ([Acknowledgment], [Acknowledgement], [Acknowledgments], [Acknowledgements])
      let is-abstract = it.body in ([Abstract],)
      // set align(center)
      // set text(if is-ack { 10pt } else { 11pt })
      // set text(24.88pt, weight: "bold")
      set text(20.74pt, weight: "bold")
      show: block.with(above: 15pt, below: 13.75pt, sticky: true)
      show: smallcaps
      if it.numbering != none and not is-ack and not is-abstract {
        // [Chapter #numbering("1", deepest) \ ] 
        [Chapter #counter(heading).display(it.numbering) \ ]
        // h(7pt, weak: true)
      }
      it.body
      v(20mm, weak: false)
    } else if it.level == 2 {
      // TODO: check font size.
      set text(18pt, weight:"bold")
      counter(heading).display(it.numbering)
      h(7pt, weak: true)
      it.body
  //     [wow]
  //   } else [
  //     // Third level headings are run-ins too, but different.
  //     #if it.level == 3 {
  //       numbering("1.1.1", deepest)
  //       [ ]
  //     }
  //     _#(it.body):_
    }
  }

  // Style bibliography.
  show std.bibliography: set text(8pt)
  show std.bibliography: set block(spacing: 0.5em)
  set std.bibliography(title: text(10pt)[References], style: "ieee")

  // Display the paper's title and authors at the top of the page,
  // spanning all columns (hence floating at the scope of the
  // columns' parent, which is the page).
  set page(margin: (
      top:40mm, bottom:25mm, right:30mm,left:40mm,
    )
  )
  place(
    top,
    float: true,
    scope: "parent",
    clearance: 30pt,
    {
      {
        set align(center)
        set par(leading: 0.5em)
        set text(size: 24pt)
        block(below: 8.35mm, title)
      }

      // TODO: title page, logo, supervisors, etc.
      // TODO: remove multiple authors.
      // Display the authors list.
      set par(leading: 0.6em)
      for i in range(calc.ceil(authors.len() / 3)) {
        let end = calc.min((i + 1) * 3, authors.len())
        let is-last = authors.len() == end
        let slice = authors.slice(i * 3, end)
        grid(
          columns: slice.len() * (1fr,),
          gutter: 12pt,
          ..slice.map(author => align(center, {
            text(size: 11pt, author.name)
            if "department" in author [
              \ #emph(author.department)
            ]
            if "organization" in author [
              \ #emph(author.organization)
            ]
            if "location" in author [
              \ #author.location
            ]
            if "email" in author {
              if type(author.email) == str [
                \ #link("mailto:" + author.email)
              ] else [
                \ #author.email
              ]
            }
          }))
        )

        if not is-last {
          v(16pt, weak: true)
        }
      }
    }
  )
  set page(
      margin: (top: 25mm, bottom: 25mm, right: 25mm, left: 40mm,)
  )

  set par(
    justify: true,
    first-line-indent: (
      amount: indent-amount, 
      all: true
    ), 
    spacing: 0.5em, 
    leading: 0.5em
  )

  if acknowledgements != none {
    [= Acknowledgements
    #acknowledgements] 
  }

  if abstract != none {
    [= Abstract
    #abstract]
  }

  // Display the paper's contents.
  body

  // Display bibliography.
  bibliography
}
