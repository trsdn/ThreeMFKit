import XCTest
@testable import ThreeMFKit

/// The README shows an API sketch. A README that does not compile is worse than no README, and
/// nothing else in the suite would notice if the shown names were renamed, so the example is
/// compiled here in exactly the shape it is documented.
final class READMEExampleTests: XCTestCase {
    func testDocumentedExampleCompilesAndHandlesEveryCase() {
        let extractor = ThreeMFPreviewExtractor()
        let url = URL(fileURLWithPath: "/nonexistent/example.3mf")

        switch extractor.preview(for: url) {
        case .preview(let image):
            XCTAssertFalse(image.data.isEmpty)
        case .fallback(let fallback):
            XCTAssertEqual(fallback.reason, .unreadablePackage)
        }
    }

    func testDocumentedMaxPixelDimensionArgumentExists() {
        let extractor = ThreeMFPreviewExtractor()
        let result = extractor.preview(
            for: URL(fileURLWithPath: "/nonexistent/example.3mf"),
            maxPixelDimension: 512
        )
        guard case .fallback = result else { return XCTFail("expected a fallback") }
    }

    func testEveryDocumentedFallbackReasonExists() {
        // Named individually so renaming one fails to compile rather than silently drifting.
        let documented: [PreviewFallbackReason] = [
            .notAThreeMFPackage, .noSupportedImage, .unreadablePackage, .imageNormalizationFailed
        ]
        XCTAssertEqual(Set(documented).count, 4)
    }
}
