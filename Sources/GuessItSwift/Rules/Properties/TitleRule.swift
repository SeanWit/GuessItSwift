import Foundation

/// Rule for extracting title information from media filenames
public struct TitleRule: Rule {
    
    public let name = "TitleRule"
    public let priority = RulePriority.low  // Run after other rules to avoid conflicts
    public let properties = ["title"]
    
    public func matches(in context: ParseContext) -> [RuleMatch] {
        guard shouldApply(in: context) else { return [] }
        
        // Clean the original string for title extraction
        let string = cleanStringForTitleExtraction(context.originalString)
        let words = string.components(separatedBy: .whitespacesAndNewlines)
        
        // Find the title by removing known non-title parts
        let titleWords = extractTitleWords(from: words, context: context)
        
        guard !titleWords.isEmpty else { return [] }
        
        let title = titleWords.joined(separator: " ")
        let cleanedTitle = cleanTitle(title)
        
        guard !cleanedTitle.isEmpty else { return [] }
        
        // Create a range for the title (approximate)
        let titleRange = string.startIndex..<string.endIndex
        
        let match = RuleMatch(
            property: "title",
            value: cleanedTitle,
            range: titleRange,
            confidence: 0.8,
            ruleName: name,
            tags: ["extracted"]
        )
        
        return [match]
    }
    
    private func extractTitleWords(from words: [String], context: ParseContext) -> [String] {
        // First pass: find the most likely release year
        let mostLikelyYearIndex = findMostLikelyYearIndex(in: words)
        
        var titleWords: [String] = []
        
        for (index, word) in words.enumerated() {
            let cleanWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Skip empty words
            guard !cleanWord.isEmpty else { continue }
            
            // Stop at the most likely year position
            if let yearIndex = mostLikelyYearIndex, index >= yearIndex {
                break
            }
            
            // Stop at known markers (but not years, since we handle them above)
            if isStopWord(cleanWord, context: context, ignoreYears: true) {
                break
            }
            
            // Skip known non-title patterns
            if isNonTitleWord(cleanWord) {
                continue
            }
            
            titleWords.append(cleanWord)
        }
        
        return titleWords
    }
    
    private func findMostLikelyYearIndex(in words: [String]) -> Int? {
        var yearCandidates: [(index: Int, year: Int)] = []
        
        for (index, word) in words.enumerated() {
            if let year = Int(word.trimmingCharacters(in: .whitespacesAndNewlines)), 
               YearRule.isValidMediaYear(year) {
                yearCandidates.append((index: index, year: year))
            }
        }
        
        // If no year candidates, return nil
        guard !yearCandidates.isEmpty else { return nil }
        
        // If only one candidate, return it
        if yearCandidates.count == 1 {
            return yearCandidates[0].index
        }
        
        // If multiple candidates, prefer the last one (most likely to be the release year)
        // unless it's clearly part of the title
        let lastCandidate = yearCandidates.last!
        
        // Always prefer the last year candidate as it's most likely the release year
        // The year in the title (like "2001" in "2001 A Space Odyssey") will typically
        // come before the actual release year
        return lastCandidate.index
    }
    
    private func isStopWord(_ word: String, context: ParseContext, ignoreYears: Bool = false) -> Bool {
        let lowercaseWord = word.lowercased()
        
        // Years - but be more careful about years in titles
        if !ignoreYears, let year = Int(word), YearRule.isValidMediaYear(year) {
            // If this is a very old year (like movies from the early 1900s), it might be part of the title
            // Only consider it a stop word if it's likely to be a release year
            if year >= 1980 { // Most media files are from 1980 onwards
                return true
            }
            // For older years, check if there's a more recent year later in the context
            // This is a simplified heuristic - a full implementation would be more sophisticated
            return false
        }
        
        // Season/Episode markers
        let seasonEpisodeMarkers = ["s01", "s1", "s02", "s2", "s03", "s3", "s04", "s4", "s05", "s5",
                                   "season", "episode", "ep", "e01", "e1", "e02", "e2"]
        if seasonEpisodeMarkers.contains(lowercaseWord) {
            return true
        }
        
        // Video quality markers
        let qualityMarkers = ["720p", "1080p", "1080i", "2160p", "4k", "480p"]
        if qualityMarkers.contains(lowercaseWord) {
            return true
        }
        
        // Source markers
        let sourceMarkers = ["bluray", "blu-ray", "bdrip", "brrip", "dvd", "dvdrip", 
                            "hdtv", "web-dl", "webdl", "webrip", "cam", "ts", "tc"]
        if sourceMarkers.contains(lowercaseWord) {
            return true
        }
        
        // Codec markers
        let codecMarkers = ["x264", "x265", "h264", "h265", "hevc", "xvid", "divx"]
        if codecMarkers.contains(lowercaseWord) {
            return true
        }
        
        // Check for SxxExx pattern
        if word.matches(pattern: #"[Ss]\d{1,2}[Ee]\d{1,3}"#) {
            return true
        }
        
        // Check for 1x01 pattern  
        if word.matches(pattern: #"\d{1,2}x\d{1,3}"#) {
            return true
        }
        
        return false
    }
    
    private func isNonTitleWord(_ word: String) -> Bool {
        let lowercaseWord = word.lowercased()
        
        // Common separators that might remain
        let separators = [".", "-", "_", "+", "[", "]", "(", ")", "{", "}"]
        if separators.contains(word) {
            return true
        }
        
        // Very short words that are likely not part of title
        if word.count <= 1 {
            return true
        }
        
        // Audio info
        let audioMarkers = ["aac", "ac3", "dts", "flac", "mp3", "5.1", "7.1", "stereo", "mono"]
        if audioMarkers.contains(lowercaseWord) {
            return true
        }
        
        // Container formats
        let containers = ["mkv", "mp4", "avi", "mov", "wmv", "flv", "webm", "m4v"]
        if containers.contains(lowercaseWord) {
            return true
        }
        
        // Release group indicators
        if word.hasPrefix("-") && word.count > 3 {
            return true
        }
        
        return false
    }
    
    private func cleanTitle(_ title: String) -> String {
        var cleaned = title
        
        // Remove extra spaces
        cleaned = cleaned.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        
        // Trim whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Capitalize properly
        cleaned = cleaned.capitalized
        
        // Fix common title formatting issues
        cleaned = cleaned.replacingOccurrences(of: " Of ", with: " of ")
        cleaned = cleaned.replacingOccurrences(of: " The ", with: " the ")
        cleaned = cleaned.replacingOccurrences(of: " And ", with: " and ")
        cleaned = cleaned.replacingOccurrences(of: " A ", with: " a ")
        cleaned = cleaned.replacingOccurrences(of: " An ", with: " an ")
        cleaned = cleaned.replacingOccurrences(of: " In ", with: " in ")
        cleaned = cleaned.replacingOccurrences(of: " On ", with: " on ")
        cleaned = cleaned.replacingOccurrences(of: " At ", with: " at ")
        cleaned = cleaned.replacingOccurrences(of: " To ", with: " to ")
        cleaned = cleaned.replacingOccurrences(of: " For ", with: " for ")
        cleaned = cleaned.replacingOccurrences(of: " With ", with: " with ")
        cleaned = cleaned.replacingOccurrences(of: " By ", with: " by ")
        
        // Ensure first letter is capitalized
        if !cleaned.isEmpty {
            cleaned = String(cleaned.prefix(1)).uppercased() + String(cleaned.dropFirst())
        }
        
        return cleaned
    }
    
    private func cleanStringForTitleExtraction(_ string: String) -> String {
        var cleaned = string
        
        // Remove file extension
        cleaned = cleaned.withoutExtension
        
        // Replace common separators with spaces, but preserve some structure
        cleaned = cleaned.replacingOccurrences(of: ".", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "_", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "-", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "+", with: " ")
        
        // Remove brackets and parentheses but keep their content
        cleaned = cleaned.replacingOccurrences(of: "[", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "]", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "(", with: " ")
        cleaned = cleaned.replacingOccurrences(of: ")", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "{", with: " ")
        cleaned = cleaned.replacingOccurrences(of: "}", with: " ")
        
        // Normalize multiple spaces to single space
        cleaned = cleaned.replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
        
        // Trim whitespace
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
}

// MARK: - Post-processing for Title Rule
extension TitleRule: PostProcessingRule {
    
    public func postProcess(matches: [RuleMatch], context: ParseContext) -> [RuleMatch] {
        let titleMatches = matches.filter { $0.property == "title" }
        let otherMatches = matches.filter { $0.property != "title" }
        
        // If we have multiple title matches, keep the longest one
        guard !titleMatches.isEmpty else { return matches }
        
        let bestTitle = titleMatches.max { first, second in
            // Prefer longer titles
            if first.value.count != second.value.count {
                return first.value.count < second.value.count
            }
            // Then prefer higher confidence
            return first.confidence < second.confidence
        }
        
        if let bestTitle = bestTitle {
            return otherMatches + [bestTitle]
        }
        
        return otherMatches
    }
}

// MARK: - Title Utilities
extension TitleRule {
    
    /// Validates if a string could be a valid title
    public static func isValidTitle(_ title: String) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Must not be empty
        guard !trimmed.isEmpty else { return false }
        
        // Must be at least 2 characters
        guard trimmed.count >= 2 else { return false }
        
        // Should contain at least one letter
        guard trimmed.rangeOfCharacter(from: .letters) != nil else { return false }
        
        // Should not be all numbers
        guard !trimmed.allSatisfy({ $0.isNumber }) else { return false }
        
        return true
    }
    
    /// Extracts potential episode title from the remaining text after main title
    public static func extractEpisodeTitle(from text: String, afterMainTitle title: String) -> String? {
        // This is a simplified implementation
        // In a full implementation, this would be more sophisticated
        
        let components = text.components(separatedBy: title)
        guard components.count > 1 else { return nil }
        
        let afterTitle = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let words = afterTitle.components(separatedBy: .whitespacesAndNewlines)
        
        var episodeTitleWords: [String] = []
        
        for word in words {
            let cleanWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Stop at known non-title markers
            if cleanWord.matches(pattern: #"\d{3,4}p"#) ||  // Resolution
               cleanWord.lowercased().contains("bluray") ||
               cleanWord.lowercased().contains("hdtv") ||
               cleanWord.matches(pattern: #"x26[45]"#) {    // Codec
                break
            }
            
            episodeTitleWords.append(cleanWord)
        }
        
        let episodeTitle = episodeTitleWords.joined(separator: " ").capitalized
        
        return isValidTitle(episodeTitle) ? episodeTitle : nil
    }
} 