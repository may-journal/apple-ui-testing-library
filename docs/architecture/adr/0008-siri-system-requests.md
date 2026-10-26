# 0008 — Submit Siri requests through the system

## Context

An intent handler test misses phrase routing and the answer Siri presents. Hosted tests cannot reach Siri's process. System tests need explicit setup and a deadline.

## Decision

1. The optional system session submits recognized speech with Apple's Siri automation service.
2. It reads static text from that service's tree, rather than an app view or intent result.
3. Each request first dismisses prior Siri UI. The expected answer must appear before the deadline.
4. Empty text is a setup failure. Unexpected nonempty text is indeterminate; its source could be setup, service, routing, or the app.
5. An iOS UI test bundle runs requests. Other platforms throw a setup error. Tests leave Siri and account setup to the owner.
6. Forbidden text in a verified answer is a response failure. Each failure names the phrase, observed text and caller's line.
7. Keep the last nonempty transcript if Siri dismisses itself before the deadline. Positive assertions still require two equal current reads.

## Consequences

1. Hosted tests stay fast and offline. Siri tests are a separate opt-in system run.
2. The fixture uses a shipped App Shortcut and three people. Tests never call its handler.
3. This checks the visible transcript, not audio synthesis. Network and OS setup can block a run.
4. Simulator owners must shut down their devices even when tests fail.
5. The system suite needs English Siri. Its arithmetic question proves only that answers are read and kept, never app routing.
