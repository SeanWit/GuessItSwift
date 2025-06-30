import Foundation

// MARK: - Global API Functions

/// Parse a media filename and extract information
/// - Parameters:
///   - filename: The filename or path to parse
///   - options: Optional parsing options
/// - Returns: A Result containing the parsed information or an error
public func guessit(_ filename: String, options: ParseOptions = ParseOptions()) -> GuessItResult<MatchResult> {
    return GuessItSwift.shared.guessit(filename, options: options)
}

/// Parse a media filename and extract information, throwing on error
/// - Parameters:
///   - filename: The filename or path to parse
///   - options: Optional parsing options
/// - Returns: The parsed MatchResult
/// - Throws: GuessItError if parsing fails
public func parse(_ filename: String, options: ParseOptions = ParseOptions()) throws -> MatchResult {
    return try GuessItSwift.shared.parse(filename, options: options)
}

/// Parse multiple filenames in batch
/// - Parameters:
///   - filenames: Array of filenames to parse
///   - options: Optional parsing options
/// - Returns: Array of results for each filename
public func guessBatch(_ filenames: [String], options: ParseOptions = ParseOptions()) -> [GuessItResult<MatchResult>] {
    return GuessItSwift.shared.guessBatch(filenames, options: options)
}

// MARK: - GuessItSwift Main Class

/// Main class providing the GuessIt Swift functionality
public class GuessItSwift {
    
    /// Shared singleton instance
    public static let shared = GuessItSwift()
    
    private let engine: GuessItEngine
    
    // MARK: - Initialization
    
    /// Initialize with default configuration
    public init() {
        self.engine = GuessItEngine()
    }
    
    /// Initialize with custom configuration
    public init(configuration: RuleConfiguration) {
        self.engine = GuessItEngine(configuration: configuration)
    }
    
    /// Initialize with custom configuration and rules
    public init(configuration: RuleConfiguration, customRules: [Rule]) {
        self.engine = GuessItEngine(configuration: configuration, customRules: customRules)
    }
    
    // MARK: - Parsing Methods
    
    /// Parse a filename and return the extracted information
    public func guessit(_ filename: String, options: ParseOptions = ParseOptions()) -> GuessItResult<MatchResult> {
        return engine.guessit(filename, options: options)
    }
    
    /// Parse a filename and return the result synchronously, throwing on error
    public func parse(_ filename: String, options: ParseOptions = ParseOptions()) throws -> MatchResult {
        return try engine.parse(filename, options: options)
    }
    
    /// Parse multiple filenames in batch
    public func guessBatch(_ filenames: [String], options: ParseOptions = ParseOptions()) -> [GuessItResult<MatchResult>] {
        return engine.guessBatch(filenames, options: options)
    }
    
    /// Parse multiple filenames in batch, returning only successful results
    public func guessSuccessful(_ filenames: [String], options: ParseOptions = ParseOptions()) -> [MatchResult] {
        return engine.guessSuccessful(filenames, options: options)
    }
    
    // MARK: - Utility Methods
    
    /// Get all available properties that can be detected
    public func availableProperties() -> [String] {
        return engine.availableProperties()
    }
    
    /// Validate a filename without fully parsing it
    public func isValidMediaFilename(_ filename: String) -> Bool {
        return engine.isValidMediaFilename(filename)
    }
    
    /// Get detailed analysis of a filename
    public func analyze(_ filename: String, options: ParseOptions = ParseOptions()) -> GuessItResult<AnalysisResult> {
        return engine.analyze(filename, options: options)
    }
    
    // MARK: - Configuration
    
    /// Get the current configuration
    public func getConfiguration() -> RuleConfiguration {
        return engine.getConfiguration()
    }
    
    /// Create a new instance with modified configuration
    public func withConfiguration(_ configuration: RuleConfiguration) -> GuessItSwift {
        return GuessItSwift(configuration: configuration)
    }
    
    // MARK: - Quick Access Methods
    
    /// Extract just the title from a filename
    public func getTitle(from filename: String) -> String? {
        return engine.getTitle(from: filename)
    }
    
    /// Extract just the year from a filename
    public func getYear(from filename: String) -> Int? {
        return engine.getYear(from: filename)
    }
    
    /// Extract season and episode from a filename
    public func getSeasonEpisode(from filename: String) -> (season: Int, episode: Int)? {
        return engine.getSeasonEpisode(from: filename)
    }
    
    /// Extract video codec from a filename
    public func getVideoCodec(from filename: String) -> String? {
        return engine.getVideoCodec(from: filename)
    }
}

// MARK: - Convenience Extensions

extension String {
    
    /// Parse this string as a media filename
    /// - Parameter options: Optional parsing options
    /// - Returns: A Result containing the parsed information or an error
    public func guessit(options: ParseOptions = ParseOptions()) -> GuessItResult<MatchResult> {
        return GuessItSwift.shared.guessit(self, options: options)
    }
    
    /// Parse this string as a media filename, throwing on error
    /// - Parameter options: Optional parsing options
    /// - Returns: The parsed MatchResult
    /// - Throws: GuessItError if parsing fails
    public func parseAsMedia(options: ParseOptions = ParseOptions()) throws -> MatchResult {
        return try GuessItSwift.shared.parse(self, options: options)
    }
    
    /// Check if this string appears to be a valid media filename
    /// - Returns: True if it appears to be a valid media filename
    public var isValidMediaFilename: Bool {
        return GuessItSwift.shared.isValidMediaFilename(self)
    }
    
    /// Extract the title from this media filename
    /// - Returns: The extracted title, if any
    public var mediaTitle: String? {
        return GuessItSwift.shared.getTitle(from: self)
    }
    
    /// Extract the year from this media filename
    /// - Returns: The extracted year, if any
    public var mediaYear: Int? {
        return GuessItSwift.shared.getYear(from: self)
    }
    
    /// Extract season and episode from this media filename
    /// - Returns: A tuple containing season and episode, if found
    public var mediaSeasonEpisode: (season: Int, episode: Int)? {
        return GuessItSwift.shared.getSeasonEpisode(from: self)
    }
    
    /// Extract video codec from this media filename
    /// - Returns: The extracted video codec, if any
    public var mediaVideoCodec: String? {
        return GuessItSwift.shared.getVideoCodec(from: self)
    }
}

// MARK: - Array Extensions

extension Array where Element == String {
    
    /// Parse all strings in this array as media filenames
    /// - Parameter options: Optional parsing options
    /// - Returns: Array of results for each filename
    public func guessitBatch(options: ParseOptions = ParseOptions()) -> [GuessItResult<MatchResult>] {
        return GuessItSwift.shared.guessBatch(self, options: options)
    }
    
    /// Parse all strings in this array as media filenames, returning only successful results
    /// - Parameter options: Optional parsing options
    /// - Returns: Array of successful MatchResults
    public func guessitSuccessful(options: ParseOptions = ParseOptions()) -> [MatchResult] {
        return GuessItSwift.shared.guessSuccessful(self, options: options)
    }
    
    /// Filter this array to only include valid media filenames
    /// - Returns: Array containing only strings that appear to be valid media filenames
    public var validMediaFilenames: [String] {
        return self.filter { GuessItSwift.shared.isValidMediaFilename($0) }
    }
}

// MARK: - Version Information

extension GuessItSwift {
    
    /// The version of GuessIt Swift
    public static let version = "1.0.0"
    
    /// Information about the library
    public static let info: [String: Any] = [
        "name": "GuessItSwift",
        "version": version,
        "description": "Swift library for extracting information from media filenames",
        "author": "GuessItSwift Contributors",
        "license": "MIT"
    ]
    
    /// Print version and library information
    public static func printInfo() {
        print("GuessItSwift v\(version)")
        print("Swift library for extracting information from media filenames")
        print("Based on the original GuessIt Python library")
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension GuessItSwift {
    
    /// Debug method to analyze a filename with detailed output
    public func debugAnalyze(_ filename: String, options: ParseOptions = ParseOptions()) {
        print("=== GuessIt Debug Analysis ===")
        print("Input: \(filename)")
        print("Options: \(options)")
        
        let result = analyze(filename, options: options)
        
        switch result {
        case .success(let analysis):
            print("✅ Parsing successful")
            print("Summary: \(analysis.summary)")
            print("Confidence: \(String(format: "%.2f", analysis.confidence))")
            print("Processing time: \(String(format: "%.3f", analysis.processingTime))s")
            print("Detected properties: \(analysis.detectedProperties.joined(separator: ", "))")
            print("Full result: \(analysis.matchResult)")
        case .failure(let error):
            print("❌ Parsing failed: \(error.localizedDescription)")
        }
        
        print("=============================")
    }
}
#endif 