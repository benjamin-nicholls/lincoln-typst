#let current-chapter-title() = context {
    let headings = query(heading.where(level: 1).before(here()))
    if headings == () { "" } else {
        headings.last().body}
    }

// Init
#let init(doc) = { 
    set text(font: "CMU Serif", size: 12pt, weight:"regular", spacing: 200%)
    set columns(gutter: 12pt)
    set page(
        columns: 1,
        paper: "a4",
    )
    doc
}
// Title Page
#let TitlePage(doc) = {
    set page(
        margin: (top:40mm, bottom:25mm, right:30mm,left:40mm),
        footer: none
    )
    set text(size: 10pt)
    set align(center)
    // set document(title: title, author: authors.map(author => author.name))
    doc
}

#let References(doc) = {
    set par(first-line-indent: 0in)
    set align(left)
}
// Main body
#let MainBody(doc) = {
    set page(
        margin: (top: 15mm, bottom: 25mm, right: 25mm, left: 40mm),
        footer: context [
            #set align(right)
            #set text(size: 10pt)
            // TODO: This should not be shown on pages where the title is defined.
            
            #let i = here().page()
            // If current header NOT defined on this page, show header in footer.
            // #if query(heading).any(it => it.location().page() == i) {
            // #if query(heading.where(level: 1).before(here())).any(it => it.location().page() != i) {
            #if query(heading).any(it => it.location().page() == i) {
            } else { 
                            emph[#current-chapter-title()]
}
            // #let header_before = query(selector(heading).before(here()))
            // #if query(header_before).
            //     emph[#current-chapter-title()]
            // }
            #h(0.25cm)
            #text(weight: "bold")[
                #counter(page).display("1")
            ]
        ],
    )
    set align(left)
    let indent-amount = 1em

    // To Check
    show figure: set block(spacing: 15.5pt)
    show figure: set place(clearance: 15.5pt)
    show figure.where(kind: table): set figure.caption(position: top, separator: [\ ])
    show figure.where(kind: table): set text(size: 8pt)
    show figure.where(kind: table): set figure(numbering: "I")

    show figure.where(kind: image): set figure(supplement: "Figure", numbering: "1.1")

    show figure.caption: set text(size: 8pt)
    show figure.caption: set align(start)
    show figure.caption.where(kind: table): set align(center)

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

    set enum(numbering: "1.1.1")

    // Code blocks
    show raw: set text(
      font: "TeX Gyre Cursor",
      ligatures: false,
      size: 1em / 0.8,
      spacing: 100%,
    )

    // Configure lists.
    set enum(indent: 10pt, body-indent: 9pt)
    set list(indent: 10pt, body-indent: 9pt)

    // FIGURES.
    set figure.caption(separator: [: ])
    show figure: fig => {
      let prefix = (
        if fig.kind == table [TABLE]
        else if fig.kind == image [Figure]
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
        let is-ack = it.body in ([Acknowledgment], [Acknowledgement], [Acknowledgments], [Acknowledgements])
        let is-abstract = it.body in ([Abstract],)
        set text(20.74pt, weight: "bold")
        show: block.with(above: 15pt, below: 13.75pt, sticky: true)
        show: smallcaps
        if it.numbering != none and not is-ack and not is-abstract {
          // [Chapter #numbering("1", deepest) \ ] 
          [Chapter #counter(heading).display(it.numbering) \ ]
        }
        it.body
        v(20mm, weak: false)
      } else if it.level == 2 {
        // TODO: check font size.
        set text(18pt, weight:"bold")
        counter(heading).display(it.numbering)
        h(7pt, weak: true)
        it.body
      } else {
        // numbering("1.1.1", deepest)
        emph[#counter(heading).display(it.numbering) #it.body ]
      }
    }
    doc
  }
