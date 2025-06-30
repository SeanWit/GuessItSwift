import Foundation

/// Errors that can occur during GuessIt parsing
public enum GuessItError: Error, LocalizedError, Equatable {
    case invalidInput(String)
    case parsingFailed(String)
    case configurationError(String)
    case ruleError(String, rule: String)
    case patternError(String, pattern: String)
    case processingError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .parsingFailed(let message):
            return "Parsing failed: \(message)"
        case .configurationError(let message):
            return "Configuration error: \(message)"
        case .ruleError(let message, let rule):
            return "Rule error in '\(rule)': \(message)"
        case .patternError(let message, let pattern):
            return "Pattern error in '\(pattern)': \(message)"
        case .processingError(let message):
            return "Processing error: \(message)"
        }
    }
    
    public var failureReason: String? {
        return errorDescription
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidInput:
            return "Please provide a valid filename or path string."
        case .parsingFailed:
            return "Try with a different filename format or check the input."
        case .configurationError:
            return "Check the configuration file format and content."
        case .ruleError:
            return "Verify the rule configuration and patterns."
        case .patternError:
            return "Check the regular expression pattern syntax."
        case .processingError:
            return "Review the processing pipeline configuration."
        }
    }
}

/// Result type for GuessIt operations
public typealias GuessItResult<T> = Result<T, GuessItError> 