import Registry from "@dashkite/helium"
import * as k from "@dashkite/katana"

# This is the metal version of the high level application interface.
_p =
  toJSON: ->
    profile = Registry.get "profiles:application"
    profile.toJSON()

  createFromJSON: (json) ->
    profile = Registry.get "profiles:application"
    profile.createFromJSON json

  create: (context) ->
    profile = Registry.get "profiles:application"
    profile.create context

  get: ->
    profile = Registry.get "profiles:application"
    profile.get()

  exists: (context) ->
    profile = Registry.get "profiles:application"
    profile.exists()

  delete: ->
    profile = Registry.get "profiles:application"
    profile.delete()


# This is a stack-aware version of the high level application interface.
p =

  toJSON: k.push -> _p.toJSON()

  createFromJSON: k.push (json) -> _p.createFromJSON json

  create: k.push (context) -> _p.create context

  get: k.push -> _p.get()

  exists: k.push -> _p.exists()

  delete: k.push -> _p.delete()

export {p, _p}
