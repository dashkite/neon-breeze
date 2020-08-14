import {curry} from "@pandastrike/garden"
import * as k from "@dashkite/katana"
import Registry from "@dashkite/helium"

router = Registry.get "router"

browse = k.peek (name, parameters) -> router.browse {name, parameters}

attempt = ([fx..., g]) ->
  (ax...) ->
    for f, i in fx
      try
        return await f ax...
      catch error
        console.warn "attempt: branch #{i} failed"
        console.error error
    g ax...

sleep = (ms) ->
  new Promise (resolve) ->
    setTimeout resolve, ms

export {attempt, browse, sleep}
