import Testing
import UITestingLibrarySystem

/// Transcript policy only. System/SiriTests owns the real Siri routing evidence.
extension UITestingLibraryTests {
    @MainActor
    @Suite struct SiriTranscriptPolicy {
        @Test func test0007_3() throws {
            for text in ["Turn on Siri", "Network unavailable", "Sorry, something went wrong."] {
                let transcript = SiriTranscript(phrase: "Read my match", observed: [text])
                let line = UInt(#line) + 2
                do {
                    _ = try transcript.expecting("Morgan drew Riley.")
                    Issue.record("An unverified system reply passed")
                } catch let failure as SiriFailure {
                    #expect(failure.kind == .indeterminate)
                    #expect(failure.observed == [text])
                    #expect(failure.phrase == transcript.phrase)
                    #expect(failure.location.filePath == #filePath)
                    #expect(failure.location.line == line)
                }
            }
        }
    }
}
