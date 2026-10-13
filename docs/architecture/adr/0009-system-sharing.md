---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# 0009 — System sessions and delivered images

## Context

Hosted accessibility actions cannot drive system shares. A renderer input cannot prove what a destination received. Plan #40 needs a real share and image evidence without contacting anyone.

## Decision

1. Add an opt-in `UITestingLibrarySystem` product for UI-test targets. `SystemSession` launches the app and uses XCTest automation with the existing `Query` and `Failure` types.
2. Every query waits for one match under a deadline. Failures keep the calling test's location and the current accessibility read.
3. Add a separate UIKit-only `UITestingLibraryShareDestination` product with a local `UIActivity`. Test builds add it to their sheet's activities; release builds omit it.
4. The destination exports only the items UIKit delivers to `prepare`. It exposes received PNG bytes and messages as a receipt through accessibility.
5. The driver selects the real sheet's activity and uses Vision on received pixels, checking messages and required and forbidden image text.
6. Simulator tests are opt-in and serialized. Their runner shuts down only the named simulator, even on failure. Default hosted runs stay native.

## Consequences

1. Consumers drive system UI through the library from a separate UI-test target.
2. A local destination seam is required in the app's test build. No message goes to a contact.
3. Image evidence covers UIKit images, image data, and strings. File URLs, movies, and arbitrary item providers are outside this destination's scope.
4. OCR runs once over received bytes after the bounded delivery wait. Recognition quality depends on the image; failures include the recognized words.
5. The default in-process API keeps its hosted lifecycle and platform support.
