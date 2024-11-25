# Quick start

Before you continue, make sure you have followed all the steps from the [Installation section](installation).

## Initializing a Map instance

After following all installation steps, you can follow this small guide to quickly setup a simple Map instance.

### Setting up your HTML

The Maps SDK renders a native element (`MapView`) behind your webapp (`WebView`). You need to specify the boundaries (which is explained later) that is rendered in. So it is NOT an HTMLElement, but rather a native element. It can therefore not be styled, mutated or listened to like you would with a 'normal' HTMLElement.

> Read more about this concept in the "Advanced concepts" section.

At the moment, the only drawback of this is, that the map instance does not size and move along with the div that it is attached to. This is a known limitation and it may be solved in the future as there are some known solutions as well. However, most use cases would use a Map instance that stays at a fixed position anyway.

Therefore the only requirement right now is to make sure the 'foster element' (the element which you are going to attach the Map instance to) remains at the same position. This can be achieved by preventing it to be able to scroll and to make the current view portrait (or landscape) only.

So let's get to it. Let's assume you have the following layout:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1.0" />
    <title>Maps SDK for Capacitor - Basic Example</title>
    <style>
      body {
        margin: 0;
      }
      #container {
        width: 100vw;
        height: 100vh;
        background: #000;
      }
    </style>
  </head>
  <body>
    <div id="container"></div>
  </body>
</html>
```

Note that it can be anything really. Like with Capacitor itself, it does not matter what framework you are using. Angular, Vue, React, Svelte... they are all supported.

### Setting up your JavaScript

The Plugin can be imported as follows:

```javascript
import { CapacitorGoogleMaps } from "@capacitor-community/google-maps";
```

Let's assume you have imported the Plugin correctly. A simple Maps instance can then be initialized as follows:

```javascript
const initializeMap = async () => {
  // first of all, you should initialize the Maps SDK:
  await CapacitorGoogleMaps.initialize({
    key: "YOUR_IOS_MAPS_API_KEY",
    devicePixelRatio: window.devicePixelRatio, // this line is very important
  });

  // then get the element you want to attach the Maps instance to:
  const element = document.getElementById("container");

  // we can now create the map using the boundaries of #container
  try {
    const result = await CapacitorGoogleMaps.createMap(element);

    // remove background, so map can be seen
    // (you can read more about this in the "Setting up the WebView" guide)
    element.style.background = "";

    // finally set `data-maps-id` attribute for delegating touch events
    element.setAttribute("data-maps-id", result.googleMap.mapId);

    alert("Map loaded successfully");
  } catch (e) {
    alert("Map failed to load");
  }
};

(function () {
  // on page load, execute the above method
  initializeMap();

  // Some frameworks and a recommended lifecycle hook you could use to initialize the Map:
  // Ionic: `ionViewDidEnter`
  // Angular: `mounted`
  // Vue: `mounted`
  // React: `componentDidMount`

  // Of course you can also initialize the Map on different events, like clicking on a button.
  // Just make sure you do not unnecessarily initialize it multiple times.
})();
```

## What's next?

As the previous example shows, it is really easy to integrate the Maps SDK into your app. But, of course, there are many more possibilities.

- Read the Guides to learn more about the plugin.
- Refer to the [API Reference](api.md#api-reference-🔌) to see all available methods the plugin offers.
- Take a look at some examples [here](https://github.com/capacitor-community/google-maps-examples).
