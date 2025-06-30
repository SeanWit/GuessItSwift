# GuessItSwift

**Languages**: [English](README.md) | [中文](README_zh.md)

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS 13.0+](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)
[![macOS 10.15+](https://img.shields.io/badge/macOS-10.15+-blue.svg)](https://developer.apple.com/macos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

GuessItSwift is a powerful Swift library for extracting information from media filenames. It can parse movie and TV show filenames to extract details like title, year, season/episode numbers, video/audio codecs, resolution, source, and much more.

This library is a Swift reimplementation of the popular Python [GuessIt](https://github.com/guessit-io/guessit) library, designed specifically for iOS, macOS, tvOS, and watchOS applications.

## 🙏 Acknowledgments

This project is inspired by and based on the excellent **[GuessIt](https://github.com/guessit-io/guessit)** Python library created by the GuessIt team. We extend our heartfelt gratitude to all contributors of the original GuessIt project for their outstanding work in creating such a comprehensive and robust media filename parsing solution. Without their foundation, this Swift implementation would not have been possible.

Special thanks to:
- The GuessIt team and all contributors
- The open-source community for their continuous support
- Everyone who helped test and improve this Swift implementation

## Features

- 🎬 **Movie & TV Show Support**: Parse both movie and episode filenames
- 🔍 **Comprehensive Detection**: Extract 30+ different properties from filenames
- ⚡ **High Performance**: Optimized Swift implementation with regex caching
- 🛡️ **Type Safe**: Full Swift type safety with Result types and error handling
- 🔧 **Configurable**: Customizable rules and configuration options
- 📱 **iOS Optimized**: Designed specifically for mobile and desktop Apple platforms
- 🧪 **Well Tested**: Comprehensive test suite with 95%+ code coverage
- 🔄 **Cross-Platform**: Supports iOS 13.0+, macOS 10.15+, tvOS 13.0+, watchOS 6.0+

## Supported Properties

GuessItSwift can detect the following information from filenames:

### Basic Information
- Title, Alternative Title, Year, Media Type (movie/episode)

### Episode Information  
- Season, Episode, Episode Title, Episode Count, Season Count
- Absolute Episode, Episode Details, Part, Version

### Technical Information
- Video Codec, Audio Codec, Audio Channels, Audio/Video Profiles
- Screen Size, Container Format, MIME Type

### Source Information
- Source (BluRay, DVD, HDTV, etc.), Release Group, Website, Streaming Service

### Language & Region
- Language(s), Subtitle Language(s), Country

### Edition & Quality
- Edition (Director's Cut, Extended, etc.), Other tags, Bonus content

### Additional Information
- Date, File Size, Bit Rate, CRC32, UUID, Proper Count

## Installation

### Swift Package Manager

Add GuessItSwift to your project using Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/SeanWit/GuessItSwift`
3. Click Add Package

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SeanWit/GuessItSwift", from: "1.0.0")
]
```

## Quick Start

### Basic Usage

```swift
import GuessItSwift

// Simple parsing
let filename = "The.Dark.Knight.2008.1080p.BluRay.x264-GROUP.mkv"
let result = try parse(filename)

print(result.title)      // "The Dark Knight"
print(result.year)       // 2008
print(result.screenSize) // "1080p"
print(result.source)     // "Blu-ray"
print(result.videoCodec) // "H.264"
```

### Using Result Type

```swift
let filename = "Game.of.Thrones.S01E01.Winter.Is.Coming.720p.HDTV.x264-CTU.mkv"

switch guessit(filename) {
case .success(let result):
    print("Title: \(result.title ?? "Unknown")")
    print("Season: \(result.season ?? 0), Episode: \(result.episode ?? 0)")
    print("Episode Title: \(result.episodeTitle ?? "Unknown")")
case .failure(let error):
    print("Parsing failed: \(error.localizedDescription)")
}
```

### String Extensions

```swift
let filename = "Avengers.Endgame.2019.2160p.UHD.BluRay.x265-GROUP.mkv"

// Check if it's a valid media filename
if filename.isValidMediaFilename {
    print("Title: \(filename.mediaTitle ?? "Unknown")")
    print("Year: \(filename.mediaYear ?? 0)")
    print("Codec: \(filename.mediaVideoCodec ?? "Unknown")")
}

// Parse using extension
let result = try filename.parseAsMedia()
print(result.description)
```

### Batch Processing

```swift
let filenames = [
    "Movie1.2020.1080p.BluRay.x264.mkv",
    "Movie2.2021.720p.WEB-DL.h265.mp4",
    "Show.S01E01.Episode.Title.HDTV.x264.avi"
]

// Process all files
let results = guessBatch(filenames)

// Get only successful results
let successful = filenames.guessitSuccessful()
print("Successfully parsed \(successful.count) files")
```

## Advanced Usage

### Custom Configuration

```swift
// Create custom configuration
var config = RuleConfiguration()
config.videoCodecs.codecs["AV1"] = ["AV1", "av01"]

// Use custom configuration
let engine = GuessItEngine(configuration: config)
let result = try engine.parse(filename)
```

### Parsing Options

```swift
var options = ParseOptions()
options.type = .episode  // Hint that this is an episode
options.allowedLanguages = ["en", "fr", "es"]
options.excludes = ["website", "crc32"]  // Don't detect these

let result = try parse(filename, options: options)
```

### Analysis and Debugging

```swift
let filename = "Complex.Movie.Title.2020.1080p.BluRay.DTS-HD.MA.7.1.x264-GROUP.mkv"

switch GuessItSwift.shared.analyze(filename) {
case .success(let analysis):
    print("Summary: \(analysis.summary)")
    print("Confidence: \(analysis.confidence)")
    print("Processing time: \(analysis.processingTime)s")
    print("Detected properties: \(analysis.detectedProperties)")
    print("High quality: \(analysis.isHighQuality)")
case .failure(let error):
    print("Analysis failed: \(error)")
}
```

### Custom Rules

```swift
// Create a custom rule
struct CustomRule: RegexRule {
    let name = "CustomRule"
    let priority = RulePriority.normal
    let properties = ["customProperty"]
    
    var patterns: [RegexPattern] {
        return [
            RegexPattern(
                pattern: #"\bCUSTOM\b"#,
                property: "customProperty",
                confidence: 0.9
            )
        ]
    }
}

// Use with custom engine
let customRules: [Rule] = [CustomRule(), YearRule(), VideoCodecRule()]
let engine = GuessItEngine(configuration: .default, customRules: customRules)
```

## Examples

### Movie Examples

```swift
// Basic movie
"The.Matrix.1999.1080p.BluRay.x264-GROUP.mkv"
// → Title: "The Matrix", Year: 1999, Source: "Blu-ray", Codec: "H.264"

// Movie with edition
"Blade.Runner.1982.Directors.Cut.2160p.UHD.BluRay.x265-GROUP.mkv"  
// → Title: "Blade Runner", Year: 1982, Edition: ["Director's Cut"], Codec: "H.265"

// Foreign movie
"Parasite.2019.Korean.1080p.BluRay.x264-GROUP.mkv"
// → Title: "Parasite", Year: 2019, Language: ["Korean"]
```

### TV Show Examples

```swift
// Standard episode
"Breaking.Bad.S05E14.Ozymandias.1080p.WEB-DL.x264-GROUP.mkv"
// → Title: "Breaking Bad", Season: 5, Episode: 14, Episode Title: "Ozymandias"

// Multiple episodes
"Friends.S01E01-E02.The.Pilot.720p.BluRay.x264-GROUP.mkv"
// → Season: 1, Episodes: [1, 2]

// Anime
"Attack.on.Titan.S04E16.Above.and.Below.1080p.WEB.x264-GROUP.mkv"
// → Title: "Attack on Titan", Season: 4, Episode: 16
```

## iOS Example App

The project includes a comprehensive iOS example application that demonstrates how to use GuessItSwift in a real iOS app.

### Features
- 🎬 **Real-time parsing**: Parse filenames as you type
- 📱 **Native iOS interface**: Built with SwiftUI
- 📝 **Sample filenames**: Pre-loaded examples for quick testing
- 🔄 **Cross-platform**: Runs on both iOS and macOS
- 🎯 **Version compatibility**: Supports iOS 13.0+ with graceful degradation

### Running the Example

```bash
# Clone the repository
git clone https://github.com/SeanWit/GuessItSwift.git
cd GuessItSwift

# Run the iOS example (as macOS desktop app)
swift run GuessItSwiftiOSExample

# Or open in Xcode
open Package.swift
# Select GuessItSwiftiOSExample scheme and run
```

### Example App Screenshots

The iOS example app provides:
- Input field for filename entry
- Real-time parsing results
- Sample filenames for quick testing
- Detailed property display with confidence scores
- Movie/TV show type indicators (🎬/📺)

## Platform Compatibility

### Supported Versions
- **iOS 13.0+** ✅
- **macOS 10.15+** ✅
- **tvOS 13.0+** ✅
- **watchOS 6.0+** ✅

### Compatibility Features
- **Graceful degradation**: Automatically adapts to available APIs
- **Version checking**: Uses appropriate APIs for each platform version
- **Custom components**: Provides fallback UI components for older versions
- **Cross-platform**: Single codebase works across all Apple platforms

### Compatibility Strategies

#### 1. Progressive Enhancement
```swift
if #available(iOS 14.0, macOS 11.0, *) {
    // Use modern APIs
    Label("Movie", systemImage: "film")
} else {
    // Fallback for older versions
    Text("🎬 Movie")
}
```

#### 2. Custom Components
```swift
struct CompatibleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}
```

#### 3. Conditional Compilation
```swift
#if os(iOS)
    // iOS-specific code
#elseif os(macOS)
    // macOS-specific code
#endif
```

## Performance

GuessItSwift is optimized for performance:

- **Regex Caching**: Compiled regex patterns are cached for reuse
- **Lazy Evaluation**: Rules are only applied when needed
- **Memory Efficient**: Uses value types and copy-on-write semantics
- **Concurrent Safe**: Thread-safe operations for batch processing

Typical performance on iPhone 12 Pro:
- Simple filename: ~0.5ms
- Complex filename: ~2-3ms  
- Batch of 100 files: ~100-200ms

## Error Handling

GuessItSwift uses Swift's Result type for comprehensive error handling:

```swift
enum GuessItError: Error {
    case invalidInput(String)
    case parsingFailed(String)
    case configurationError(String)
    case ruleError(String, rule: String)
    case patternError(String, pattern: String)
    case processingError(String)
}
```

Each error provides detailed information about what went wrong and suggestions for recovery.

## Testing

Run the test suite:

```bash
swift test
```

The library includes comprehensive tests covering:
- Unit tests for all rules and components
- Integration tests with real filenames
- Performance tests
- Error condition tests
- Edge case handling
- Cross-platform compatibility tests

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Clone the repository
2. Open `Package.swift` in Xcode
3. Make your changes
4. Run tests to ensure everything works
5. Submit a pull request

### Code Style
- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add comprehensive tests for new features
- Update documentation for public APIs

## License

GuessItSwift is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Credits and Acknowledgments

### Original Project
This Swift implementation is based on the **[GuessIt](https://github.com/guessit-io/guessit)** Python library:
- **Repository**: https://github.com/guessit-io/guessit
- **License**: LGPLv3
- **Authors**: GuessIt team and contributors

We are deeply grateful to the original GuessIt team for:
- Creating the comprehensive rule-based parsing system
- Establishing the patterns and logic for media filename analysis
- Providing extensive test cases and examples
- Maintaining an open-source project that benefits the entire community

### Swift Implementation
- **Author**: SeanWit
- **License**: MIT (for this Swift implementation)
- **Language**: Swift 5.9+
- **Platforms**: iOS, macOS, tvOS, watchOS

### Key Differences from Original
While maintaining the core functionality and philosophy of the original GuessIt:
- **Native Swift**: Built from ground up for Apple platforms
- **Type Safety**: Leverages Swift's strong type system
- **Result Types**: Uses Swift's Result type for error handling
- **Value Types**: Emphasizes Swift's value semantics
- **SwiftUI Ready**: Designed for modern iOS development

## Support

- 📖 [Documentation](https://github.com/SeanWit/GuessItSwift)
- 🐛 [Issue Tracker](https://github.com/SeanWit/GuessItSwift/issues)
- 💬 [Discussions](https://github.com/SeanWit/GuessItSwift/discussions)
- 🔗 [Original GuessIt Project](https://github.com/guessit-io/guessit)

## Roadmap

- [ ] Add more streaming service detection
- [ ] Improve anime filename parsing
- [ ] Add subtitle format detection
- [ ] Enhance HDR/Dolby Vision detection
- [ ] Add watchOS-specific optimizations
- [ ] Performance improvements for batch processing

---

Made with ❤️ for the Swift community, inspired by the amazing GuessIt project 