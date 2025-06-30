import Foundation

/// Context for parsing operations, containing configuration and state
public struct ParseContext {
    // MARK: - Input Information
    public let originalString: String
    public let cleanedString: String
    public let options: ParseOptions
    
    // MARK: - Processing State
    public var currentPosition: String.Index
    public var matches: [RuleMatch] = []
    public var processingStartTime: Date
    
    // MARK: - Configuration
    public let configuration: RuleConfiguration
    
    public init(
        originalString: String,
        options: ParseOptions = ParseOptions(),
        configuration: RuleConfiguration = RuleConfiguration.default
    ) {
        self.originalString = originalString
        // Don't clean the string too aggressively - let rules work on the original
        self.cleanedString = originalString
        self.options = options
        self.configuration = configuration
        self.currentPosition = originalString.startIndex
        self.processingStartTime = Date()
    }
    
    // MARK: - Convenience Methods
    
    /// Returns the remaining string from current position
    public var remainingString: String {
        return String(cleanedString[currentPosition...])
    }
    
    /// Advances the current position by the given offset
    public mutating func advance(by offset: Int) {
        currentPosition = cleanedString.index(currentPosition, offsetBy: offset, limitedBy: cleanedString.endIndex) ?? cleanedString.endIndex
    }
    
    /// Resets the current position to the beginning
    public mutating func reset() {
        currentPosition = cleanedString.startIndex
    }
    
    /// Returns the elapsed processing time
    public var processingTime: TimeInterval {
        return Date().timeIntervalSince(processingStartTime)
    }
    
    /// Adds a match to the context
    public mutating func addMatch(_ match: RuleMatch) {
        matches.append(match)
    }
    
    /// Returns matches for a specific property
    public func matches(for property: String) -> [RuleMatch] {
        return matches.filter { $0.property == property }
    }
    
    /// Returns true if a property has already been matched
    public func hasMatch(for property: String) -> Bool {
        return matches.contains { $0.property == property }
    }
}

/// Options for parsing behavior
public struct ParseOptions: Codable {
    public var type: MediaType?
    public var nameOnly: Bool = false
    public var dateYearFirst: Bool = false
    public var dateDayFirst: Bool = false
    public var episodePreferNumber: Bool = false
    public var allowedLanguages: [String]?
    public var allowedCountries: [String]?
    public var expectedTitle: [String]?
    public var expectedGroup: [String]?
    public var includes: [String]?
    public var excludes: [String]?
    public var advanced: Bool = false
    public var singleValue: Bool = false
    public var enforceList: Bool = false
    public var outputInputString: Bool = false
    
    public init() {}
    
    /// Returns true if the given property should be processed
    public func shouldProcess(property: String) -> Bool {
        if let excludes = excludes, excludes.contains(property) {
            return false
        }
        
        if let includes = includes {
            return includes.contains(property)
        }
        
        return true
    }
}

/// Represents a match found by a rule
public struct RuleMatch: Equatable {
    public let property: String
    public let value: String
    public let range: Range<String.Index>
    public let confidence: Double
    public let ruleName: String
    public let tags: [String]
    
    public init(
        property: String,
        value: String,
        range: Range<String.Index>,
        confidence: Double = 1.0,
        ruleName: String,
        tags: [String] = []
    ) {
        self.property = property
        self.value = value
        self.range = range
        self.confidence = confidence
        self.ruleName = ruleName
        self.tags = tags
    }
    
    /// Returns the length of the matched text
    public var length: Int {
        return range.upperBound.utf16Offset(in: "") - range.lowerBound.utf16Offset(in: "")
    }
    
    /// Returns true if this match has the specified tag
    public func hasTag(_ tag: String) -> Bool {
        return tags.contains(tag)
    }
}

// MARK: - String Extensions for Parsing
extension String {
    /// Cleans the string for parsing by normalizing separators and removing unwanted characters
    func cleanedForParsing() -> String {
        var cleaned = self
        
        // Replace common separators with spaces
        let separators = [".", "_", "-", "+", "(", ")", "[", "]", "{", "}", " "]
        for separator in separators {
            cleaned = cleaned.replacingOccurrences(of: separator, with: " ")
        }
        
        // Normalize multiple spaces to single space
        cleaned = cleaned.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        
        // Trim whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
    
    /// Extracts the filename from a path
    var filename: String {
        return (self as NSString).lastPathComponent
    }
    
    /// Removes the file extension
    var withoutExtension: String {
        return (self as NSString).deletingPathExtension
    }
    
    /// Returns the file extension
    var fileExtension: String {
        return (self as NSString).pathExtension.lowercased()
    }
} 