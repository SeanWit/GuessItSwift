import Foundation

/// Main engine class for GuessIt Swift - the primary entry point for parsing media filenames
public class GuessItEngine {
    
    private let ruleEngine: RuleEngine
    private let configuration: RuleConfiguration
    
    // MARK: - Initialization
    
    /// Initialize with default configuration
    public init() {
        self.configuration = .default
        self.ruleEngine = RuleEngine(configuration: configuration)
    }
    
    /// Initialize with custom configuration
    public init(configuration: RuleConfiguration) {
        self.configuration = configuration
        self.ruleEngine = RuleEngine(configuration: configuration)
    }
    
    /// Initialize with custom configuration and rules
    public init(configuration: RuleConfiguration, customRules: [Rule]) {
        self.configuration = configuration
        self.ruleEngine = RuleEngine(configuration: configuration, customRules: customRules)
    }
    
    // MARK: - Main Parsing Methods
    
    /// Parse a filename and return the extracted information
    /// - Parameters:
    ///   - filename: The filename or path to parse
    ///   - options: Parsing options to customize behavior
    /// - Returns: A Result containing either the parsed information or an error
    public func guessit(_ filename: String, options: ParseOptions = ParseOptions()) -> GuessItResult<MatchResult> {
        // Validate input
        guard !filename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.invalidInput("Filename cannot be empty"))
        }
        
        // Clean the filename for processing
        let cleanedFilename = preprocessFilename(filename)
        
        // Process using the rule engine
        return ruleEngine.process(filename: cleanedFilename, options: options)
    }
    
    /// Parse a filename and return the result synchronously, throwing on error
    /// - Parameters:
    ///   - filename: The filename or path to parse
    ///   - options: Parsing options to customize behavior
    /// - Returns: The parsed MatchResult
    /// - Throws: GuessItError if parsing fails
    public func parse(_ filename: String, options: ParseOptions = ParseOptions()) throws -> MatchResult {
        let result = guessit(filename, options: options)
        switch result {
        case .success(let matchResult):
            return matchResult
        case .failure(let error):
            throw error
        }
    }
    
    /// Parse multiple filenames in batch
    /// - Parameters:
    ///   - filenames: Array of filenames to parse
    ///   - options: Parsing options to customize behavior
    /// - Returns: Array of results for each filename
    public func guessBatch(_ filenames: [String], options: ParseOptions = ParseOptions()) -> [GuessItResult<MatchResult>] {
        return filenames.map { guessit($0, options: options) }
    }
    
    /// Parse multiple filenames in batch, returning only successful results
    /// - Parameters:
    ///   - filenames: Array of filenames to parse
    ///   - options: Parsing options to customize behavior
    /// - Returns: Array of successful MatchResults
    public func guessSuccessful(_ filenames: [String], options: ParseOptions = ParseOptions()) -> [MatchResult] {
        return guessBatch(filenames, options: options).compactMap { result in
            if case .success(let matchResult) = result {
                return matchResult
            }
            return nil
        }
    }
    
    // MARK: - Utility Methods
    
    /// Get all available properties that can be detected
    /// - Returns: Array of property names
    public func availableProperties() -> [String] {
        let allRules = ruleEngine.getAllRules()
        var properties = Set<String>()
        
        for rule in allRules {
            properties.formUnion(rule.properties)
        }
        
        return Array(properties).sorted()
    }
    
    /// Get rules that can detect a specific property
    /// - Parameter property: The property name
    /// - Returns: Array of rules that can detect this property
    public func rules(for property: String) -> [Rule] {
        return ruleEngine.getRules(for: property)
    }
    
    /// Validate a filename without fully parsing it
    /// - Parameter filename: The filename to validate
    /// - Returns: True if the filename appears to be a valid media filename
    public func isValidMediaFilename(_ filename: String) -> Bool {
        // Quick checks first
        let trimmed = filename.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return false
        }
        
        // Check for common media file extensions
        let mediaExtensions = ["mp4", "mkv", "avi", "mov", "wmv", "flv", "webm", "m4v", "3gp", "ts", "m2ts", "vob", "mpg", "mpeg"]
        let fileExtension = trimmed.fileExtension
        
        // If it has a non-media extension, it's likely not a media file
        if !fileExtension.isEmpty {
            if !mediaExtensions.contains(fileExtension) {
                // Check for common non-media extensions
                let nonMediaExtensions = ["txt", "doc", "docx", "pdf", "jpg", "jpeg", "png", "gif", "zip", "rar", "exe", "dmg"]
                if nonMediaExtensions.contains(fileExtension) {
                    return false
                }
            }
        }
        
        // If it's just random text without structure, reject it
        if !trimmed.contains(where: { $0.isNumber }) && !trimmed.contains(".") && !trimmed.contains(" ") {
            return false
        }
        
        let result = guessit(filename)
        
        switch result {
        case .success(let matchResult):
            // Consider it valid if we found meaningful media properties
            let hasTitle = matchResult.title != nil && !matchResult.title!.isEmpty
            let hasYear = matchResult.year != nil && matchResult.year! > 0
            let hasSeasonEpisode = matchResult.season != nil || matchResult.episode != nil
            let hasVideoCodec = matchResult.videoCodec != nil
            let hasSource = matchResult.source != nil
            let hasContainer = matchResult.container != nil
            
            // Must have at least title or year, plus some other media-related property
            let hasBasicInfo = hasTitle || hasYear
            let hasMediaInfo = hasSeasonEpisode || hasVideoCodec || hasSource || hasContainer
            
            return hasBasicInfo && hasMediaInfo
        case .failure:
            return false
        }
    }
    
    /// Get detailed information about what was detected in a filename
    /// - Parameters:
    ///   - filename: The filename to analyze
    ///   - options: Parsing options
    /// - Returns: Detailed analysis information
    public func analyze(_ filename: String, options: ParseOptions = ParseOptions()) -> GuessItResult<AnalysisResult> {
        let parseResult = guessit(filename, options: options)
        
        switch parseResult {
        case .success(let matchResult):
            let analysis = AnalysisResult(
                filename: filename,
                matchResult: matchResult,
                detectedProperties: getDetectedProperties(matchResult),
                confidence: matchResult.confidence,
                processingTime: matchResult.processingTime
            )
            return .success(analysis)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - Configuration Methods
    
    /// Get the current configuration
    /// - Returns: The current RuleConfiguration
    public func getConfiguration() -> RuleConfiguration {
        return configuration
    }
    
    /// Create a new engine with modified configuration
    /// - Parameter configuration: The new configuration
    /// - Returns: A new GuessItEngine instance
    public func withConfiguration(_ configuration: RuleConfiguration) -> GuessItEngine {
        return GuessItEngine(configuration: configuration)
    }
    
    // MARK: - Private Methods
    
    private func preprocessFilename(_ filename: String) -> String {
        var processed = filename
        
        // Extract filename from path if needed
        processed = processed.filename
        
        // Don't remove file extension - we need it for container detection
        // The individual rules can handle extensions as needed
        
        // Normalize common patterns (but preserve dots for extension detection)
        processed = normalizeFilename(processed)
        
        return processed
    }
    
    private func normalizeFilename(_ filename: String) -> String {
        // For now, return the filename as-is to preserve structure for regex rules
        // Individual rules will handle their own normalization as needed
        return filename
    }
    
    private func getDetectedProperties(_ matchResult: MatchResult) -> [String] {
        var properties: [String] = []
        
        let mirror = Mirror(reflecting: matchResult)
        for child in mirror.children {
            guard let propertyName = child.label else { continue }
            
            // Skip metadata properties
            if ["inputString", "confidence", "processingTime"].contains(propertyName) {
                continue
            }
            
            // Check if property has a non-nil value
            let hasValue: Bool
            if let stringValue = child.value as? String {
                hasValue = !stringValue.isEmpty
            } else if let arrayValue = child.value as? [Any] {
                hasValue = !arrayValue.isEmpty
            } else if let intValue = child.value as? Int {
                hasValue = intValue != 0
            } else if let doubleValue = child.value as? Double {
                hasValue = doubleValue != 0.0
            } else if child.value is Date {
                hasValue = true
            } else if child.value is MediaType {
                hasValue = true
            } else {
                hasValue = false
            }
            
            if hasValue {
                properties.append(propertyName)
            }
        }
        
        return properties.sorted()
    }
}

// MARK: - Analysis Result
public struct AnalysisResult {
    public let filename: String
    public let matchResult: MatchResult
    public let detectedProperties: [String]
    public let confidence: Double
    public let processingTime: TimeInterval
    
    /// Returns a summary of what was detected
    public var summary: String {
        var components: [String] = []
        
        if let title = matchResult.title {
            components.append("Title: \(title)")
        }
        
        if let year = matchResult.year {
            components.append("Year: \(year)")
        }
        
        if let season = matchResult.season, let episode = matchResult.episode {
            components.append("Episode: S\(String(format: "%02d", season))E\(String(format: "%02d", episode))")
        }
        
        if let videoCodec = matchResult.videoCodec {
            components.append("Video: \(videoCodec)")
        }
        
        if let source = matchResult.source {
            components.append("Source: \(source)")
        }
        
        return components.joined(separator: " | ")
    }
    
    /// Returns true if this appears to be a high-quality release
    public var isHighQuality: Bool {
        guard let videoCodec = matchResult.videoCodec else { return false }
        
        let highQualityCodecs = ["H.265", "AV1", "VP9"]
        if highQualityCodecs.contains(videoCodec) {
            return true
        }
        
        if let screenSize = matchResult.screenSize {
            let highQualityResolutions = ["1080p", "2160p", "4K", "8K"]
            return highQualityResolutions.contains(screenSize)
        }
        
        return false
    }
}

// MARK: - Convenience Extensions
extension GuessItEngine {
    
    /// Quick parse method that returns only the title
    public func getTitle(from filename: String) -> String? {
        return try? parse(filename).title
    }
    
    /// Quick parse method that returns only the year
    public func getYear(from filename: String) -> Int? {
        return try? parse(filename).year
    }
    
    /// Quick parse method that returns season and episode
    public func getSeasonEpisode(from filename: String) -> (season: Int, episode: Int)? {
        guard let result = try? parse(filename),
              let season = result.season,
              let episode = result.episode else {
            return nil
        }
        return (season: season, episode: episode)
    }
    
    /// Quick parse method that returns video codec
    public func getVideoCodec(from filename: String) -> String? {
        return try? parse(filename).videoCodec
    }
} 