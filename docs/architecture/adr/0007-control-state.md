---
relatedConfigurations: ['../../../.fitnessrc.json']
---

# 0007

## Context

A test must read disabled controls without reaching into native views. Sending native actions directly can bypass the disabled state.

## Decision

1. Add `Element.isEnabled`, defaulting to true for manually built elements.
2. Read UIKit control state and disabled traits, and AppKit accessibility enabled state.
3. Refuse disabled taps and custom actions before activation and include disabled state in element descriptions.

## Consequences

1. Tests assert state through the same public reading on both platforms.
2. Existing element initializers keep their behavior.
3. Failure reports show disabled controls without native view inspection.
