import Foundation

/// Rule for matching year information in media filenames
public struct YearRule: RegexRule {
    
    public let name = "YearRule"
    public let priority = RulePriority.high
    public let properties = ["year"]
    
    public var patterns: [RegexPattern] {
        return [
            // Year in parentheses: (2020), (1999)
            RegexPattern(
                pattern: #"\((\d{4})\)"#,
                property: "year",
                confidence: 0.9,
                tags: ["parentheses"],
                formatter: RuleFormatters.integer,
                validator: RuleValidators.year
            ),
            
            // Year with brackets: [2020], [1999]
            RegexPattern(
                pattern: #"\[(\d{4})\]"#,
                property: "year",
                confidence: 0.85,
                tags: ["brackets"],
                formatter: RuleFormatters.integer,
                validator: RuleValidators.year
            ),
            
            // Year standalone: 2020, 1999 (with word boundaries)
            RegexPattern(
                pattern: #"\b(\d{4})\b"#,
                property: "year",
                confidence: 0.7,
                tags: ["standalone"],
                formatter: RuleFormatters.integer,
                validator: RuleValidators.year
            ),
            
            // Year with dots: .2020., .1999.
            RegexPattern(
                pattern: #"\.(\d{4})\."#,
                property: "year",
                confidence: 0.8,
                tags: ["dots"],
                formatter: RuleFormatters.integer,
                validator: RuleValidators.year
            ),
            
            // Year with spaces: " 2020 ", " 1999 "
            RegexPattern(
                pattern: #"\s(\d{4})\s"#,
                property: "year",
                confidence: 0.6,
                tags: ["spaces"],
                formatter: RuleFormatters.integer,
                validator: RuleValidators.year
            )
        ]
    }
    
    public func shouldApply(in context: ParseContext) -> Bool {
        // Don't apply if year is excluded or if we already have a year match
        guard context.options.shouldProcess(property: "year") else { return false }
        return !context.hasMatch(for: "year")
    }
}

// MARK: - Post-processing for Year Rule
extension YearRule: PostProcessingRule {
    
    public func postProcess(matches: [RuleMatch], context: ParseContext) -> [RuleMatch] {
        let yearMatches = matches.filter { $0.property == "year" }
        let otherMatches = matches.filter { $0.property != "year" }
        
        // If no year matches, return all matches as-is
        guard !yearMatches.isEmpty else { return matches }
        
        // Sort year matches by confidence and preference
        let sortedYearMatches = yearMatches.sorted { first, second in
            // Prefer years in parentheses or brackets
            if first.hasTag("parentheses") && !second.hasTag("parentheses") {
                return true
            }
            if second.hasTag("parentheses") && !first.hasTag("parentheses") {
                return false
            }
            
            if first.hasTag("brackets") && !second.hasTag("brackets") {
                return true
            }
            if second.hasTag("brackets") && !first.hasTag("brackets") {
                return false
            }
            
            // Prefer higher confidence
            if first.confidence != second.confidence {
                return first.confidence > second.confidence
            }
            
            // Prefer more recent years (but not future years)
            let currentYear = Calendar.current.component(.year, from: Date())
            let firstYear = Int(first.value) ?? 0
            let secondYear = Int(second.value) ?? 0
            
            // If both are valid years, prefer the one closer to current year but not in the future
            if firstYear <= currentYear && secondYear <= currentYear {
                return abs(currentYear - firstYear) < abs(currentYear - secondYear)
            } else if firstYear <= currentYear {
                return true
            } else if secondYear <= currentYear {
                return false
            }
            
            return firstYear > secondYear
        }
        
        // Return the best year match plus all other matches
        if let bestYearMatch = sortedYearMatches.first {
            return otherMatches + [bestYearMatch]
        }
        
        return otherMatches
    }
}

// MARK: - Year Validation Utilities
extension YearRule {
    
    /// Validates if a year value is reasonable for media content
    public static func isValidMediaYear(_ year: Int) -> Bool {
        let currentYear = Calendar.current.component(.year, from: Date())
        return year >= 1888 && year <= currentYear + 2 // Movies started around 1888
    }
    
    /// Extracts year from various date formats
    public static func extractYearFromDate(_ dateString: String) -> Int? {
        // Try different date formats
        let dateFormatters = [
            "yyyy-MM-dd",
            "yyyy/MM/dd",
            "dd-MM-yyyy",
            "dd/MM/yyyy",
            "MM-dd-yyyy",
            "MM/dd/yyyy"
        ]
        
        for formatString in dateFormatters {
            let formatter = DateFormatter()
            formatter.dateFormat = formatString
            
            if let date = formatter.date(from: dateString) {
                return Calendar.current.component(.year, from: date)
            }
        }
        
        return nil
    }
}

// MARK: - Enhanced Year Validators
extension RuleValidators {
    
    /// Enhanced year validator that considers media-specific constraints
    public static let mediaYear: (String) -> Bool = { string in
        guard let year = Int(string.trimmingCharacters(in: .whitespacesAndNewlines)) else { return false }
        return YearRule.isValidMediaYear(year)
    }
    
    /// Validator for years that should not be in the future
    public static let pastYear: (String) -> Bool = { string in
        guard let year = Int(string.trimmingCharacters(in: .whitespacesAndNewlines)) else { return false }
        let currentYear = Calendar.current.component(.year, from: Date())
        return year >= 1888 && year <= currentYear
    }
    
    /// Validator for years that allows near-future dates (for upcoming releases)
    public static let nearFutureYear: (String) -> Bool = { string in
        guard let year = Int(string.trimmingCharacters(in: .whitespacesAndNewlines)) else { return false }
        let currentYear = Calendar.current.component(.year, from: Date())
        return year >= 1888 && year <= currentYear + 5
    }
} 