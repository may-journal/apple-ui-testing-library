import Testing

/// The one serialized parent every requirement suite nests under (ADR 0005). Both bundles
/// compile this folder, so each platform-neutral acceptance has one test run on both.
@Suite(.serialized)
struct UITestingLibraryTests {}
