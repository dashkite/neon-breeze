import {pipeWith} from "@pandastrike/garden"
import * as q from "@dashkite/quark"

# TODO: This should come from hadron layer.
presets = pipeWith q.lookup

  narrow: q.maxWidth q.hrem 48

  "simple form": q.select "form", [

    q.normalize [ "links" ]

    q.form [
      "responsive"
      "header"
      "section"
      "label"
      "input"
      "textarea"
      "footer"
      "button"
    ]

    q.type "large copy"

    q.select "h1", [
      q.type "heading"
    ]

    q.select "label", [
      q.select "& > *", [
        q.margin bottom: q.rem 1
        q.select "&:last-child", [
          q.margin bottom: 0
        ]
      ]
      q.select "& > .hint", [
        q.type "caption"
        q.select "& > p", [
          q.reset [ "block" ]
          q.margin bottom: q.rem 1
        ]
        q.select "> :first-child", [
          q.select "&::before", [
            q.display "inline-block"
            q.bold
            q.set "content", "'Hint:'"
            q.margin right: q.em 1/4
          ]
        ]
      ]
    ]
  ]



css = q.build q.sheet [

  q.select ":host", [
    q.set "align-self", "center"
  ]

  presets [ "simple form" ]

  q.select "form", [
    presets [ "narrow" ]

    q.select ".message", [
      q.type "small label"
      q.color "black"
    ]

    q.select ".progress", [
      q.padding q.hrem 2
      q.flex "1 1 auto"
      q.rows
      q.justifyContent "space-around"

      q.select ".pip", [
        q.borders [ "round", "silver" ]
        q.background "transparent"
        q.height q.hrem 3
        q.width "20%"
        q.set "transition", "background 250ms"
      ]

      q.select ".pip.success", [
        q.background "green"
      ]

      q.select ".pip.failure", [
        q.background "red"
      ]
    ]

    q.select "nav > p.hidden", [
      q.display "none"
    ]
  ]
]

export default css
