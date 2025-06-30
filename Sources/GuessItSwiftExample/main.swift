import Foundation
import GuessItSwift

print("=== GuessItSwift Demo ===")

// Debug: Check registered rules
let debugEngine = GuessItEngine()
let allRules = debugEngine.availableProperties()
print("🔧 Available properties: \(allRules.joined(separator: ", "))")

let testFilenames = [
    "Treme.1x03.Right.Place,.Wrong.Time.HDTV.XviD-NoTV.avi",
    "The.Dark.Knight.2008.1080p.BluRay.x264-GROUP.mkv",
    "Game.of.Thrones.S01E01.Winter.Is.Coming.720p.HDTV.x264-CTU.mkv",
    "Breaking.Bad.S02E05.Breakage.720p.mkv",
    "Avengers.Endgame.2019.2160p.UHD.BluRay.x265-GROUP.mkv",
    "The.Matrix.1999.1080p.BluRay.x264-GROUP.mkv"
]

for filename in testFilenames {
    print("\n--- Parsing: \(filename) ---")
    
    print("  🔍 Parsing filename: \(filename)")
    
    let result = guessit(filename)
    
    switch result {
    case .success(let match):
        print("✅ Successfully parsed:")
        print("  Title: \(match.title ?? "N/A")")
        if let episodeTitle = match.episodeTitle {
            print("  Episode Title: \(episodeTitle)")
        }
        print("  Year: \(match.year?.description ?? "N/A")")
        print("  Season: \(match.season?.description ?? "N/A")")
        print("  Episode: \(match.episode?.description ?? "N/A")")
        print("  Video Codec: \(match.videoCodec ?? "N/A")")
        print("  Source: \(match.source ?? "N/A")")
        print("  Release Group: \(match.releaseGroup ?? "N/A")")
        print("  Container: \(match.container ?? "N/A")")
        print("  MIME Type: \(match.mimetype ?? "N/A")")
        print("  Type: \(match.type?.rawValue ?? "N/A")")
        print("  Confidence: \(String(format: "%.2f", match.confidence))")
        
        // 特别验证原版GuessIt示例
        if filename.contains("Treme") {
            print("\n  🎯 验证原版GuessIt示例:")
            print("  Expected: title='Treme', season=1, episode=3, episode_title='Right Place, Wrong Time'")
            print("  Expected: source='HDTV', video_codec='Xvid', release_group='NoTV', container='avi'")
            print("  Actual matches:")
            print("    ✓ Title: \(match.title == "Treme" ? "✅" : "❌") (\(match.title ?? "nil"))")
            print("    ✓ Season: \(match.season == 1 ? "✅" : "❌") (\(match.season?.description ?? "nil"))")
            print("    ✓ Episode: \(match.episode == 3 ? "✅" : "❌") (\(match.episode?.description ?? "nil"))")
            print("    ✓ Episode Title: \(match.episodeTitle?.contains("Right Place") == true ? "✅" : "❌") (\(match.episodeTitle ?? "nil"))")
            print("    ✓ Source: \(match.source?.uppercased() == "HDTV" ? "✅" : "❌") (\(match.source ?? "nil"))")
            print("    ✓ Video Codec: \(match.videoCodec?.contains("XviD") == true ? "✅" : "❌") (\(match.videoCodec ?? "nil"))")
            print("    ✓ Release Group: \(match.releaseGroup == "NoTV" ? "✅" : "❌") (\(match.releaseGroup ?? "nil"))")
            print("    ✓ Container: \(match.container == "avi" ? "✅" : "❌") (\(match.container ?? "nil"))")
        }
        
    case .failure(let error):
        print("❌ Failed to parse: \(error.localizedDescription)")
    }
}

print("\n=== Available Properties ===")
let engine = GuessItEngine()
let properties = engine.availableProperties()
print("Available properties: \(properties.joined(separator: ", "))")

print("\n=== Demo Complete ===") 