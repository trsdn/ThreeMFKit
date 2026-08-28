import XCTest
import ZIPFoundation
@testable import ThreeMFKit

/// The uncompressed-size ceiling is the package's only defence against a decompression bomb, and a
/// `.3mf` arrives from the internet and is opened by merely selecting it in Finder. An untested
/// ceiling is indistinguishable from no ceiling, so both halves of it are exercised here: the
/// declared size in the archive metadata, and the running total while decompressing.
final class EntrySizeLimitTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        directory = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
    }

    func testAnEntryLargerThanTheCeilingIsRejected() throws {
        let url = try makeArchive(entryPath: "big.png", byteCount: 4096)
        let reader = ZIPFoundationThreeMFPackageReader(maximumEntrySize: 1024)
        let entry = try XCTUnwrap(try reader.fileEntries(in: url).first)

        XCTAssertThrowsError(try reader.data(for: entry, in: url)) { error in
            guard case ThreeMFPackageReaderError.entryTooLarge(let path, let limit) = error else {
                return XCTFail("expected entryTooLarge, got \(error)")
            }
            XCTAssertEqual(path, "big.png")
            XCTAssertEqual(limit, 1024)
        }
    }

    func testAnEntryUnderTheCeilingIsStillReturned() throws {
        let url = try makeArchive(entryPath: "small.png", byteCount: 512)
        let reader = ZIPFoundationThreeMFPackageReader(maximumEntrySize: 1024)
        let entry = try XCTUnwrap(try reader.fileEntries(in: url).first)

        XCTAssertEqual(try reader.data(for: entry, in: url).count, 512)
    }

    func testAHighlyCompressibleEntryCannotExceedTheCeilingWhileDecompressing() throws {
        // Zeroes compress to almost nothing, which is precisely the shape of a decompression bomb:
        // the archive is tiny, so nothing upstream looks suspicious until it is expanded.
        let url = try makeArchive(
            entryPath: "bomb.png", byteCount: 8 * 1024 * 1024, byte: 0, compressionMethod: .deflate
        )
        let reader = ZIPFoundationThreeMFPackageReader(maximumEntrySize: 64 * 1024)
        let entry = try XCTUnwrap(try reader.fileEntries(in: url).first)

        let compressed = try XCTUnwrap(
            try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int
        )
        XCTAssertLessThan(compressed, 1024 * 1024, "fixture is not actually compressed")

        XCTAssertThrowsError(try reader.data(for: entry, in: url)) { error in
            guard case ThreeMFPackageReaderError.entryTooLarge = error else {
                return XCTFail("expected entryTooLarge, got \(error)")
            }
        }
    }

    func testTheDefaultCeilingIsBoundedRatherThanEffectivelyUnlimited() throws {
        // A ceiling that no real file could reach is decoration. 256 MB is far above any genuine
        // 3MF preview and far below what would exhaust a Quick Look extension.
        XCTAssertEqual(ZIPFoundationThreeMFPackageReader.defaultMaximumEntrySize, 256 * 1024 * 1024)
    }

    private func makeArchive(
        entryPath: String,
        byteCount: Int,
        byte: UInt8 = 0x41,
        compressionMethod: CompressionMethod = .none
    ) throws -> URL {
        let url = directory.appendingPathComponent("\(UUID().uuidString).3mf")
        let archive = try Archive(url: url, accessMode: .create)
        let payload = Data(repeating: byte, count: byteCount)
        try archive.addEntry(
            with: entryPath,
            type: .file,
            uncompressedSize: Int64(payload.count),
            compressionMethod: compressionMethod
        ) { position, size in
            payload.subdata(in: Int(position)..<Int(position) + size)
        }
        return url
    }
}
