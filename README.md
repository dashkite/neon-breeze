# Neon Breeze
Web Component that combines the Breeze authentication API and Neon routing API

## Install

```
npm i @dashkite/neon-breeze
```

## Usage

Neon-Breeze includes:

- A Web Component for displaying HX for your app's interface with the Breeze API. The component contains a graph for dealing with OAuth login cases by wrapping the lower-level Breeze Client.
- Designed to work well with the Neon page generation and Oxygen routing interfaces.

To use the component, simply import `@dashkite/neon-breeze` and render the component using the `neon-breeze` tag.

To handle the OAuth redirect, add an appropriate route and call combinators to access Breeze API resources, depending on the circumstances.

### Helium Configuration

The Breeze Client uses `@dashkite/helium` to reference singleton configuration across the application modules.

#### configuration:breeze

```yaml
api: URL for the Breeze API or compatible.
authority: Name of the capability authority.
redirectURL: Return URL when redirected back from OAuth identity provider.
entry: Name for the entry tag the application profile is stored under.
entryDisplayName: Human-friendly name of the entry.
postSuccessPage: Name of the page to route after successful login.
```

#### profiles:application

The high-level Zinc profile management interface. Modulization and naming is TBD.

### Example: Login From OAuth redirect

This component is designed to be high-level and super simple to use. Place the neon-breeze tag into your markup and give it the Breeze identity token as a data attribute. It will render and handle HX flow cases automatically for you.

```coffeescript
import {wrap, tee, pipe, flow} from "@pandastrike/garden"
import * as k from "@dashkite/katana"
import * as n from "@dashkite/neon"
import Registry from "@dashkite/helium"
import header from "templates/header.pug"
import {standard} from "../helpers"
import p from "profiles/hype"

router = Registry.get "router"

token = ({bindings}) -> bindings.token

router.add "/oauth{?parameters*}",
  name: "oauth"
  flow [
    n.properties
      title: -> "Hype: Validating OAuth Authentication"
      description: -> "This page validates your authentication from an OAuth provider and associates or retrieves your Hype profile for you."

    standard

    n.view "main", ({parameters: {token}}) ->
      "<neon-breeze data-token = '#{token}' />"

    n.show
  ]

```
