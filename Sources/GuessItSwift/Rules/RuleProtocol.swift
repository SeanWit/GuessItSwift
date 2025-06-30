import Foundation

/// Protocol that all parsing rules must conform to
public protocol Rule {
    /// The name of this rule
    var name: String { get }
    
    /// The priority of this rule (higher numbers = higher priority)
    var priority: Int { get }
    
    /// The properties that this rule can match
    var properties: [String] { get }
    
    /// Attempts to find matches in the given context
    /// - Parameter context: The parsing context containing the string and configuration
    /// - Returns: An array of matches found by this rule
    func matches(in context: ParseContext) -> [RuleMatch]
    
    /// Validates whether this rule should be applied given the current context
    /// - Parameter context: The parsing context
    /// - Returns: True if the rule should be applied, false otherwise
    func shouldApply(in context: ParseContext) -> Bool
}

/// Default implementation for Rule protocol
extension Rule {
    public var priority: Int { return 50 }
    
    public func shouldApply(in context: ParseContext) -> Bool {
        // Check if any of this rule's properties are excluded
        for property in properties {
            if !context.options.shouldProcess(property: property) {
                return false
            }
        }
        return true
    }
}

/// Protocol for rules that use regular expressions
public protocol RegexRule: Rule {
    /// The regex patterns used by this rule
    var patterns: [RegexPattern] { get }
}

/// Default implementation for RegexRule
extension RegexRule {
    public func matches(in context: ParseContext) -> [RuleMatch] {
        guard shouldApply(in: context) else { return [] }
        
        var matches: [RuleMatch] = []
        // Use original string for regex matching to preserve structure
        let string = context.originalString
        
        for pattern in patterns {
            let results = RegexUtilities.matches(for: pattern.pattern, in: string)
            
            for result in results {
                if let match = createMatch(from: result, pattern: pattern, in: string, context: context) {
                    matches.append(match)
                }
            }
        }
        
        return matches
    }
    
    /// Creates a RuleMatch from an NSTextCheckingResult
    private func createMatch(from result: NSTextCheckingResult, pattern: RegexPattern, in string: String, context: ParseContext) -> RuleMatch? {
        // Get the captured group if available, otherwise use the full match
        let capturedText: String
        if result.numberOfRanges > 1 {
            let captureRange = result.range(at: 1)
            if captureRange.location != NSNotFound {
                capturedText = (string as NSString).substring(with: captureRange)
            } else {
                capturedText = string.substring(from: result)
            }
        } else {
            capturedText = string.substring(from: result)
        }
        
        // Apply validator if present
        if let validator = pattern.validator, !validator(capturedText) {
            return nil
        }
        
        // Apply formatter
        let value = pattern.formatter?(capturedText) ?? capturedText
        
        // Convert NSRange to Range<String.Index>
        guard let range = Range(result.range, in: string) else { return nil }
        
        return RuleMatch(
            property: pattern.property,
            value: value,
            range: range,
            confidence: pattern.confidence,
            ruleName: name,
            tags: pattern.tags
        )
    }
}

/// Protocol for rules that use string matching
public protocol StringRule: Rule {
    /// The string patterns used by this rule
    var stringPatterns: [StringPattern] { get }
}

/// Default implementation for StringRule
extension StringRule {
    public func matches(in context: ParseContext) -> [RuleMatch] {
        guard shouldApply(in: context) else { return [] }
        
        var matches: [RuleMatch] = []
        // Use cleaned string for string matching as it's more flexible
        let string = context.cleanedString.lowercased()
        
        for pattern in stringPatterns {
            for searchString in pattern.strings {
                let searchLower = searchString.lowercased()
                var searchRange = string.startIndex..<string.endIndex
                
                while let range = string.range(of: searchLower, range: searchRange) {
                    let value = pattern.formatter?(searchString) ?? pattern.value ?? searchString
                    
                    let match = RuleMatch(
                        property: pattern.property,
                        value: value,
                        range: range,
                        confidence: pattern.confidence,
                        ruleName: name,
                        tags: pattern.tags
                    )
                    
                    matches.append(match)
                    
                    // Move search range past this match
                    searchRange = range.upperBound..<string.endIndex
                }
            }
        }
        
        return matches
    }
}

/// Protocol for rules that need post-processing
public protocol PostProcessingRule: Rule {
    /// Post-processes matches to resolve conflicts or enhance results
    /// - Parameters:
    ///   - matches: All matches found so far
    ///   - context: The parsing context
    /// - Returns: The processed matches
    func postProcess(matches: [RuleMatch], context: ParseContext) -> [RuleMatch]
}

/// Represents a regular expression pattern with metadata
public struct RegexPattern {
    public let pattern: String
    public let property: String
    public let confidence: Double
    public let tags: [String]
    public let formatter: ((String) -> String)?
    public let validator: ((String) -> Bool)?
    
    public init(
        pattern: String,
        property: String,
        confidence: Double = 1.0,
        tags: [String] = [],
        formatter: ((String) -> String)? = nil,
        validator: ((String) -> Bool)? = nil
    ) {
        self.pattern = pattern
        self.property = property
        self.confidence = confidence
        self.tags = tags
        self.formatter = formatter
        self.validator = validator
    }
}

/// Represents a string pattern with metadata
public struct StringPattern {
    public let strings: [String]
    public let property: String
    public let value: String?
    public let confidence: Double
    public let tags: [String]
    public let formatter: ((String) -> String)?
    public let validator: ((String) -> Bool)?
    
    public init(
        strings: [String],
        property: String,
        value: String? = nil,
        confidence: Double = 1.0,
        tags: [String] = [],
        formatter: ((String) -> String)? = nil,
        validator: ((String) -> Bool)? = nil
    ) {
        self.strings = strings
        self.property = property
        self.value = value
        self.confidence = confidence
        self.tags = tags
        self.formatter = formatter
        self.validator = validator
    }
    
    public init(
        string: String,
        property: String,
        value: String? = nil,
        confidence: Double = 1.0,
        tags: [String] = [],
        formatter: ((String) -> String)? = nil,
        validator: ((String) -> Bool)? = nil
    ) {
        self.init(
            strings: [string],
            property: property,
            value: value,
            confidence: confidence,
            tags: tags,
            formatter: formatter,
            validator: validator
        )
    }
}

/// Rule priority constants
public struct RulePriority {
    public static let veryLow = 10
    public static let low = 25
    public static let normal = 50
    public static let high = 75
    public static let veryHigh = 90
    public static let critical = 100
}

/// Common formatters used by rules
public struct RuleFormatters {
    /// Converts string to integer
    public static let integer: (String) -> String = { string in
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if let intValue = Int(trimmed) {
            return String(intValue)
        }
        return trimmed
    }
    
    /// Converts string to title case
    public static let titleCase: (String) -> String = { string in
        return string.capitalized
    }
    
    /// Cleans up and normalizes string
    public static let cleanup: (String) -> String = { string in
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
    }
    
    /// Converts to lowercase
    public static let lowercase: (String) -> String = { string in
        return string.lowercased()
    }
    
    /// Converts to uppercase
    public static let uppercase: (String) -> String = { string in
        return string.uppercased()
    }
}

/// Common validators used by rules
public struct RuleValidators {
    /// Validates that a string represents a valid year
    public static let year: (String) -> Bool = { string in
        guard let year = Int(string) else { return false }
        return year >= 1900 && year <= 2030
    }
    
    /// Validates that a string represents a valid season number
    public static let season: (String) -> Bool = { string in
        guard let season = Int(string) else { return false }
        return season >= 1 && season <= 50
    }
    
    /// Validates that a string represents a valid episode number
    public static let episode: (String) -> Bool = { string in
        guard let episode = Int(string) else { return false }
        return episode >= 1 && episode <= 999
    }
    
    /// Validates that a string is not empty after trimming
    public static let notEmpty: (String) -> Bool = { string in
        return !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
} 