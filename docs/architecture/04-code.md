---
relatedConfigurations: ['../../.fitnessrc.json']
---

# Code

This grounds the components in [03-components.md](03-components.md) in source files. Hosted library Swift lives under `Sources/UITestingLibrary/`; optional products have their own folders under `Sources/`.

Each type sits in its own folder, and a folder depends only on the ones below it. Everything runs on the main actor, as UIKit, AppKit and the tree require.

```mermaid
classDiagram
    class User["1 User"]
    class Screen["2 Screen"]
    class ScreenSize["3 ScreenSize"]
    class Look["4 Look"]
    class HostWindow["5 HostWindow"]
    class Query["6 Query"]
    class Role["7 Role"]
    class Wait["8 Wait"]
    class ScreenReport["9 ScreenReport"]
    class Failure["10 Failure"]
    class SourceLocation["11 SourceLocation"]
    class Canary["12 Canary"]
    class AccessibilityTree["13 AccessibilityTree"]
    class Element["14 Element"]
    class Automation["15 Automation"]
    class Key["16 Key"]
    class Modifier["17 Modifier"]
    class ScrollDirection["18 ScrollDirection"]
    class SwipeDirection["19 SwipeDirection"]
    class AdjustDirection["20 AdjustDirection"]
    class PinchDirection["21 PinchDirection"]
    class DragSpeed["22 DragSpeed"]

    User --> Screen : A
    User --> Wait : B
    User --> Element : C
    User --> SourceLocation : D
    User --> Failure : E
    User --> ScreenReport : F
    User --> AccessibilityTree : G
    User --> Query : H
    User --> ScrollDirection : I
    User --> DragSpeed : J
    User --> SwipeDirection : K
    User --> AdjustDirection : L
    User --> PinchDirection : M
    User --> Key : N
    User --> Modifier : O
    Query --> Role : P
    Query --> Element : Q
    Canary --> Screen : R
    Canary --> SourceLocation : S
    Canary --> Failure : T
    Canary --> ScreenReport : U
    Failure --> ScreenReport : V
    Failure --> SourceLocation : W
    ScreenReport --> Element : X
    ScreenReport --> AccessibilityTree : Y
    HostWindow --> ScreenSize : Z
    HostWindow --> Look : AA
    Screen --> HostWindow : BB
    Screen --> Canary : CC
    Screen --> ScreenSize : DD
    Screen --> Look : EE
    Screen --> Failure : FF
    Screen --> ScreenReport : GG
    Screen --> SourceLocation : HH
    AccessibilityTree --> Element : II
    AccessibilityTree --> Screen : JJ
    AccessibilityTree --> Automation : KK
    Element --> Role : LL
    Wait --> Screen : MM
    Wait --> AccessibilityTree : NN

    style User fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Screen fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style ScreenSize fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Look fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style HostWindow fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Query fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Role fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Wait fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style ScreenReport fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Failure fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style SourceLocation fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Canary fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style AccessibilityTree fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Element fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Automation fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Key fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Modifier fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style ScrollDirection fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style SwipeDirection fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style AdjustDirection fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style PinchDirection fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style DragSpeed fill:#6d28d9,stroke:#4c1d95,color:#ffffff
```

```mermaid
classDiagram
    class Example {
        +property
        +method()
    }
    class Parent
    class Child
    Parent <|-- Child : inherits
    Parent --> Child : uses

    style Example fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Parent fill:#6d28d9,stroke:#4c1d95,color:#ffffff
    style Child fill:#6d28d9,stroke:#4c1d95,color:#ffffff
```

Numbers on classes and letters on relationships match the callout table. See [02-containers.md](02-containers.md) and [03-components.md](03-components.md).

| #   | Description | Why |
| --- | --- | --- |
| 1   | [`User`](../../Sources/UITestingLibrary/Actions/User.swift) is the public verbs a test reads in. It lives with `UserActs.swift`, `UserKeys.swift`, `UserGestures.swift`, `UserDrags.swift` and `UserSees.swift` in `Actions/`. | The public verbs a test reads in. |
| 2   | [`Screen`](../../Sources/UITestingLibrary/Screen/Screen.swift) draws a root view and closes it at teardown. | Drawing stays apart from reading. |
| 3   | [`ScreenSize`](../../Sources/UITestingLibrary/Screen/ScreenSize.swift) is the fixed size a root is drawn at. | A fixed size makes layout the same on any Mac or simulator. |
| 4   | [`Look`](../../Sources/UITestingLibrary/Screen/Look.swift) is the text size and appearance a root is drawn with. | A test checks a layout in each look a person can choose. |
| 5   | [`HostWindow`](../../Sources/UITestingLibrary/Screen/HostWindow.swift) holds the platform branch ([ADR 0006](adr/0006-one-api-two-backends.md)). It keeps a Mac's window off every display ([ADR 0011](adr/0011-person-actions-in-process.md)). | One window per process ([ADR 0005](adr/0005-one-window-per-process.md)). |
| 6   | [`Query`](../../Sources/UITestingLibrary/Queries/Query.swift) matches elements by role and label, by text, or by identifier, with `Match.swift` in `Queries/`. | Matching rules live in one place. |
| 7   | [`Role`](../../Sources/UITestingLibrary/Queries/Role.swift) is the roles a query names, each mapped to accessibility traits. | A role never matches static text that shares its label ([ADR 0002](adr/0002-query-priority.md)). |
| 8   | [`Wait`](../../Sources/UITestingLibrary/Waits/Wait.swift) polls a condition until it holds or the deadline passes, with `Stalls.swift` in `Waits/`. | Every wait shares one deadline rule; stalls are timed on the main run loop ([ADR 0010](adr/0010-keys-watches-share-sheet.md)). |
| 9   | [`ScreenReport`](../../Sources/UITestingLibrary/Reports/ScreenReport.swift) prints what is on and off screen. | A failure shows the screen as a person hears it. |
| 10  | [`Failure`](../../Sources/UITestingLibrary/Reports/Failure.swift) is the one error every look and act throws. | Failures read the same everywhere. |
| 11  | [`SourceLocation`](../../Sources/UITestingLibrary/Reports/SourceLocation.swift) is the test line a failure names. | The test fails at its own line. |
| 12  | [`Canary`](../../Sources/UITestingLibrary/Reports/Canary.swift) fails a test that never read a non-empty tree. | An OS change that empties the tree cannot pass silently. |
| 13  | [`AccessibilityTree`](../../Sources/UITestingLibrary/Tree/AccessibilityTree.swift) walks the window and drives elements, with `Timing.swift`, `Trackpad.swift` and the `UIKit*` and `AppKit*` backends in `Tree/`. | The only code that touches accessibility objects, one backend per platform. `Timing` signposts each phase, since a read is the lowest one. |
| 14  | [`Element`](../../Sources/UITestingLibrary/Tree/Element.swift) is what the tree reads of one element. | Queries and reports share one reading. |
| 15  | [`Automation`](../../Sources/UITestingLibrary/Tree/Automation.swift) turns the process-wide switch on once. | SwiftUI builds its tree only while assistive technology asks ([ADR 0004](adr/0004-automation-canary.md)). |
| 16  | [`Key`](../../Sources/UITestingLibrary/Tree/AccessibilityTree.swift#L55) is a key a person presses. | A key names what user-event's `keyboard` names. |
| 17  | [`Modifier`](../../Sources/UITestingLibrary/Tree/AccessibilityTree.swift#L92) is a key held while another is pressed. | A shortcut needs its modifiers. |
| 18  | [`ScrollDirection`](../../Sources/UITestingLibrary/Tree/AccessibilityTree.swift#L48) is which way a person scrolls. | A scroll names its direction. |
| 19  | [`SwipeDirection`](../../Sources/UITestingLibrary/Tree/AccessibilityTree.swift#L97) is which way a person swipes a row. | A swipe shows leading or trailing actions. |
| 20  | [`AdjustDirection`](../../Sources/UITestingLibrary/Tree/AccessibilityTree.swift#L103) is which way a person adjusts a slider or stepper. | An adjust steps a value up or down. |
| 21  | [`PinchDirection`](../../Sources/UITestingLibrary/Tree/AccessibilityTree.swift#L110) is which way a person pinches. | A pinch zooms in or out. |
| 22  | [`DragSpeed`](../../Sources/UITestingLibrary/Tree/AccessibilityTree.swift#L124) is how fast a person drags by a distance. | A drag comes to rest or flicks. |
| A   | `User` uses `Screen`. | The code makes this dependency. |
| B   | `User` calls `Wait`. | The code makes this dependency. |
| C   | `User` uses `Element`. | The code makes this dependency. |
| D   | `User` calls `SourceLocation`. | The code makes this dependency. |
| E   | `User` calls `Failure`. | The code makes this dependency. |
| F   | `User` calls `ScreenReport`. | The code makes this dependency. |
| G   | `User` uses `AccessibilityTree`. | The code makes this dependency. |
| H   | `User` uses `Query`. | The code makes this dependency. |
| I   | `User` uses `ScrollDirection`. | The code makes this dependency. |
| J   | `User` uses `DragSpeed`. | The code makes this dependency. |
| K   | `User` uses `SwipeDirection`. | The code makes this dependency. |
| L   | `User` uses `AdjustDirection`. | The code makes this dependency. |
| M   | `User` uses `PinchDirection`. | The code makes this dependency. |
| N   | `User` uses `Key`. | The code makes this dependency. |
| O   | `User` uses `Modifier`. | The code makes this dependency. |
| P   | `Query` uses `Role`. | The code makes this dependency. |
| Q   | `Query` uses `Element`. | The code makes this dependency. |
| R   | `Canary` uses `Screen`. | The code makes this dependency. |
| S   | `Canary` uses `SourceLocation`. | The code makes this dependency. |
| T   | `Canary` calls `Failure`. | The code makes this dependency. |
| U   | `Canary` calls `ScreenReport`. | The code makes this dependency. |
| V   | `Failure` uses `ScreenReport`. | The code makes this dependency. |
| W   | `Failure` uses `SourceLocation`. | The code makes this dependency. |
| X   | `ScreenReport` uses `Element`. | The code makes this dependency. |
| Y   | `ScreenReport` uses `AccessibilityTree`. | The code makes this dependency. |
| Z   | `HostWindow` uses `ScreenSize`. | The code makes this dependency. |
| AA  | `HostWindow` uses `Look`. | The code makes this dependency. |
| BB  | `Screen` calls `HostWindow`. | The code makes this dependency. |
| CC  | `Screen` uses `Canary`. | The code makes this dependency. |
| DD  | `Screen` uses `ScreenSize`. | The code makes this dependency. |
| EE  | `Screen` uses `Look`. | The code makes this dependency. |
| FF  | `Screen` calls `Failure`. | The code makes this dependency. |
| GG  | `Screen` calls `ScreenReport`. | The code makes this dependency. |
| HH  | `Screen` calls `SourceLocation`. | The code makes this dependency. |
| II  | `AccessibilityTree` uses `Element`. | The code makes this dependency. |
| JJ  | `AccessibilityTree` uses `Screen`. | The code makes this dependency. |
| KK  | `AccessibilityTree` uses `Automation`. | The code makes this dependency. |
| LL  | `Element` uses `Role`. | The code makes this dependency. |
| MM  | `Wait` uses `Screen`. | The code makes this dependency. |
| NN  | `Wait` uses `AccessibilityTree`. | The code makes this dependency. |

## States

| Concern | States |
| ------- | ------ |
| `Automation` | not tried; on; symbol missing. A missing symbol leaves the tree empty, and the canary fails. |
| `Match` | one found; none found; many found. `sees` waits for one and fails on none or many; `doesNotSee` waits for none. |
| `Wait` | held; timed out. A timeout fails with the `ScreenReport`. |
| `Role` | button, link, heading, image, text, text field, search field, adjustable, toggle, selected. |
| Act outcome | done; nothing to act on; not actionable; did nothing. Each failure names the query and prints the report. |
| Key | enter; end; home; escape; tab; delete; arrows; any character; each with modifiers. A shortcut or menu command answers first. Otherwise a key needs a field being edited, and fails "No field is being edited, and no shortcut answers" at the deadline. `clears` and `selectsAll` find their field and edit it first. |
| Clipboard | kept; put back. The first copy, cut or paste keeps what the clipboard holds. Closing the screen puts it back. |
| Gesture | done; no menu; no drag; refused; unchanged; no pointer; nothing to press. Each failure names the query. A swipe on a Mac's list fails, saying it needs a trackpad. A swipe on anything but a list row flicks it. |
| Window | off every display; on a display, see-through. The iOS app's scene window comes onto a display, see-through, only for a hover or a pinch. A drag by a distance keeps it off. |
| Watch | held for its set time; failed at the first miss. `neverSees` fails on the first match, or a screen that only read empty. `staysResponsive` fails on a stall at or over its limit. |
| Share sheet | up; not up. `seesShareSheet` waits for the sheet's controller over the window and never reads its contents. |
| `Canary` | read elements; read nothing. Reading nothing fails `close()`, and a `doesNotSee` that only read empty. |
| Menu | closed; open. While a menu is open, a read holds only its items. Tapping an item runs it and closes the menu, and so does `close()`. `goesBack()` closes it without running an item, and each act settles after the Mac finishes closing it, on both backends. A read lays out the window first, so a `Menu` that just drew or redrew opens. |
| `Failure` | message; report; location. Thrown from every look and act, so the test fails at its own line. |

## Platforms

The optional `UITestingLibrarySystem` product runs in an iOS UI-test target through XCTest. `SystemSession` uses the same `Query` and `Failure` types. Siri failures distinguish setup, indeterminate text, and forbidden text in a verified answer ([ADR 0008](adr/0008-siri-system-requests.md)).

The separate UIKit product `UITestingLibraryShareDestination` adds a local activity in test builds. It exports delivered images and messages, which the driver reads and checks with Vision ([ADR 0009](adr/0009-system-sharing.md)).

One Swift package, iOS 26 and macOS 26 and later, Swift 6 with complete strict concurrency, built with Xcode 27.

| Platform | How it runs |
| -------- | ----------- |
| iOS, Designed for iPad | Hosted tests in the iOS app's process, running natively on this Mac through the UIKit backend, with no simulator boot. The Mac draws an alert natively and hides UIKit's copy, so the backend reads that copy and presses its buttons through the alert. It draws a control's menu natively too: the backend reads the items from UIKit's visible menu once, then closes the Mac's menu by name. A navigation bar's menu button answers no activation, so the backend runs its primary action, which opens the menu. A text size reaches the root, so a layout that reads it changes, but the Mac draws text at one size whatever the setting. The scene's Mac window moves off every display and takes pointer events made in process. |
| Mac | Hosted tests in a Mac app's process, through the AppKit backend, with no simulator boot. A pressed menu control's menu tracks in its own run loop mode, so the backend reads it from the tracking menu. A navigation stack's items live in the window's toolbar, which the backend reads before the content. The window keeps the test's size, so no toolbar item hides in an overflow menu. A text size reaches the root as an environment value; text draws at one size here too. The window sits off every display and counts as key, so the app never comes forward. |

## Repo tree (outline)

```
apple-ui-testing-library/
├── Package.swift           # products UITestingLibrary, UITestingLibrarySystem, UITestingLibraryShareDestination
├── project.yml             # XcodeGen: TestHost and TestHostMac with hosted bundles, plus the system UI-test target
├── Sources/
│   ├── UITestingLibrary/
│   │   ├── Actions/        # User, UserActs, UserSees
│   │   ├── Screen/         # Screen, Look, HostWindow
│   │   ├── Queries/        # Role, Query, Match
│   │   ├── Waits/          # Wait
│   │   ├── Reports/        # ScreenReport, Canary
│   │   └── Tree/           # Automation, AccessibilityTree, Element, UIKit and AppKit backends
│   ├── UITestingLibrarySystem/            # SystemSession, Siri, SharedDelivery
│   └── UITestingLibraryShareDestination/  # LocalShareDestination
├── TestHost/               # TestHostApp.swift and Fixtures/, shared by both hosts
├── Tests/
│   ├── Shared/                    # both bundles: one test per platform-neutral acceptance
│   ├── UITestingLibraryTests/     # the iOS bundle only: the phone and iPad layouts
│   ├── UITestingLibraryMacTests/  # the macOS bundle only: the Mac layout
│   └── System/                    # the opt-in system UI-test target, scheme SystemTests
├── docs/
│   ├── architecture/
│   └── requirements/
├── scripts/                # requirements-coverage.sh and requirements-timing.sh
├── config/                 # timing-phases.json
├── Makefile
├── CHANGELOG.md
└── README.md
```

## Tests

| Concern | Rule |
| ------- | ---- |
| Proof | Each acceptance in `docs/requirements/` is proven by one test named for it, against a real fixture screen in `TestHost`. |
| Run | `make requirements` builds both bundles, then runs them serialized, one test at a time, each under a time limit. Each platform runs `build-for-testing` and then `test-without-building`, so a build failure reads apart from a test failure, and no diagnostics are collected. All output goes to `.build/DerivedData` inside the checkout, so parallel checkouts never share build state. The iOS bundle runs natively on this Mac as Designed for iPad and never boots a simulator. 0001.1 keeps its phone layout, since the host controller sets a compact size class. |
| Coverage | `make requirements-coverage` runs both bundles with coverage on, then `scripts/requirements-coverage.sh` prints line coverage of `Sources/UITestingLibrary/` per platform and combined. Xcode leaves the package's static code out of `.xcresult` coverage, so the script reads each run's `Coverage.profdata` with `llvm-cov` against the test bundle that links the package, leaving out fixtures and tests. It keeps the per-line hits as `.lcov` files in `.build/coverage`. |
| Timing | `make requirements-timing` runs both bundles, then `scripts/requirements-timing.sh` reads the library's signposts from the unified log since the run began. It prints one row per host and phase with the count, total and mean in milliseconds, even after a failing test. Phases nest: an act holds its settle, and a settle holds its reads. The log drops a Designed for iPad run's signpost names, so the phase comes from the code in each interval's ID. `config/timing-phases.json` maps each code to its name and mirrors `Tree/Timing.swift`. |
| Never | Tests never read view types, view models, or private state. |
| Flip | Before a test lands, its Given is flipped once, and the failure must name the Then. |
