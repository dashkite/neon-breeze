import {flow, curry, rtee, tee, wrap, unary} from "@pandastrike/garden"
import * as k from "@dashkite/katana"
import * as c from "@dashkite/carbon"
import * as b from "@dashkite/breeze-client"
import Registry from "@dashkite/helium"
import html from "./html.pug"
import css from "./css"
import {attempt, browse, sleep} from "../../helpers"
import {p, _p} from "../../application-profile"

expect = curry (status, context) -> context.response.status == status

isDefined = (context) -> context?
isUndefined = (context) -> !context?

HeRead = (field) ->
   k.push -> (Registry.get "configuration:breeze")[field]

reportMessage = (error) ->
  tee c.call ->
    message = @root.querySelector ".message"
    message.textContent = error


reportPips = (state) ->
  tee c.call ->
    pips = @root.querySelectorAll ".progress > .pip"
    for pip in pips
      pip.classList.remove "success", "failure"

    if state == false
      for pip in pips
        pip.classList.add "failure"
    else
      for pip, index in pips
        pip.classList.add "success"
        break if state == index + 1

showButtons = tee c.call ->
  show = (name) =>
    @root
    .querySelector ".#{name}"
    .classList.remove "hidden"

  buttons =
    if await _p.exists "button"
      [ "login", "home" ]
    else
      [ "login" ]

  show button for button in buttons

reportFailure = (string) ->
  flow [
    reportPips false
    showButtons
    reportMessage string
  ]

reportSuccess = flow [
  reportPips 3
  reportMessage "Success!"
  k.peek -> sleep 500
]

addEntry = flow [
  p.toJSON
  HeRead "entryDisplayName"
  HeRead "entry"
  k.mpoke (tag, displayName, content) -> { tag, displayName, content }
  b.addEntry
]

successNavigation = flow [
  p.get
  HeRead "postSuccessPage"
  reportSuccess
  browse
]

authenticate = flow [
  b.authenticate
  k.branch [
    [
      (expect 404),
      reportFailure "It looks like this login failed or is stale. Login with your identity provider to try again."
    ]
    [
      (expect 403),
      reportFailure "This login with your identity provider was successful, but it looks like you haven't connected it with your profile. Using a device with your existing profile, connect your profile to allow login across devices."
    ]
    [
      (expect 500),
      reportFailure "There's been a problem, and this login cannot continue."
    ]
    [
      (expect 200),
      flow [
        b.load
        HeRead "entry"
        b.fetchEntry
        k.branch [
          [
            isUndefined,
            reportFailure "This login with your identity provider was successful, but it looks like there isn't a profile connected to it. Using a logged in device, connect your profile to allow login across devices."
          ]
          [
            isDefined,
            flow [
              reportPips 2
              b.readEntry
              p.createFromJSON
              successNavigation
            ]
          ]
] ] ] ] ]


register = flow [
  b.authenticate
  k.branch [
    [
      (expect 404),
      reportFailure "It looks like this login failed or is stale. Login with your identity provider to try again."
    ]
    [
      (expect 500),
      reportFailure "There's been a problem, and this login cannot continue."
    ]
    [
      (expect 403),
      flow [
        reportPips 2
        k.discard
        b.register
        addEntry
        successNavigation
    ] ]
    [
      (expect 200),
      flow [
        b.load
        HeRead "entry"
        b.fetchEntry
        k.branch [
          [
            isDefined,
            flow [
              b.delete
              reportFailure "You already have a profile connected to this login."
          ] ]
          [
            isUndefined,
            flow [
              reportPips 2
              addEntry
              successNavigation
] ] ] ] ] ] ]



processToken = flow [
  c.description
  k.branch [
    [
      (context) -> context.token?
      flow [
        reportPips 1
        k.push ({token}) -> token
        k.branch [
          [ _p.exists, register ]
          [ (wrap true), authenticate ]
    ] ] ]
    [
      wrap true
      reportFailure "This login failed. You'll need to login with the idenity provider again."
    ]
] ]



class extends c.Handle

  c.mixin @, [
    c.tag "neon-breeze"
    c.diff
    c.initialize [
      c.shadow
      c.sheet "main", css
    ]
    c.connect [
      c.ready [
        c.render html
        attempt [
          processToken
          reportFailure "This authentication cannot be completed at this time."
  ] ] ] ]
