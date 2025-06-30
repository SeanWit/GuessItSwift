import Foundation

/// Rule for matching season and episode information in TV show filenames
public struct EpisodeRule: RegexRule {
    
    public let name = "EpisodeRule"
    public let priority = RulePriority.high
    public let properties = ["season", "episode", "episodeTitle"]
    
    public var patterns: [RegexPattern] {
        return [
            // Standard SxxExx format: S01E01, S1E1, s01e01
            RegexPattern(
                pattern: #"[Ss](\d{1,2})[Ee](\d{1,3})"#,
                property: "season",
                confidence: 0.95,
                tags: ["standard", "season_episode"],
                formatter: { value in
                    // Extract season from match groups
                    return value
                }
            ),
            
            // Season only: Season 1, S01
            RegexPattern(
                pattern: #"[Ss]eason\s*(\d{1,2})"#,
                property: "season",
                confidence: 0.8,
                tags: ["season_word"],
                formatter: RuleFormatters.integer
            ),
            
            RegexPattern(
                pattern: #"\b[Ss](\d{1,2})\b"#,
                property: "season",
                confidence: 0.7,
                tags: ["season_short"],
                formatter: RuleFormatters.integer
            ),
            
            // Episode only: Episode 1, Ep 1, E01
            RegexPattern(
                pattern: #"[Ee]pisode\s*(\d{1,3})"#,
                property: "episode",
                confidence: 0.8,
                tags: ["episode_word"],
                formatter: RuleFormatters.integer
            ),
            
            RegexPattern(
                pattern: #"\b[Ee]p?\s*(\d{1,3})\b"#,
                property: "episode",
                confidence: 0.7,
                tags: ["episode_short"],
                formatter: RuleFormatters.integer
            ),
            
            // Alternative format: 1x01, 01x01
            RegexPattern(
                pattern: #"(\d{1,2})x(\d{1,3})"#,
                property: "season",
                confidence: 0.9,
                tags: ["x_format", "season_episode"],
                formatter: RuleFormatters.integer
            )
        ]
    }
    
    // Override matches to handle season/episode pairs properly
    public func matches(in context: ParseContext) -> [RuleMatch] {
        guard shouldApply(in: context) else { return [] }
        
        var allMatches: [RuleMatch] = []
        let string = context.cleanedString
        
        // Handle SxxExx format specially
        let seasonEpisodeResults = RegexUtilities.matches(for: #"[Ss](\d{1,2})[Ee](\d{1,3})"#, in: string)
        for result in seasonEpisodeResults {
            if result.numberOfRanges >= 3 {
                let groups = RegexUtilities.captureGroups(from: result, in: string)
                if groups.count >= 3 {
                    // Season match
                    if let seasonRange = Range(result.range(at: 1), in: string) {
                        let seasonMatch = RuleMatch(
                            property: "season",
                            value: groups[1],
                            range: seasonRange,
                            confidence: 0.95,
                            ruleName: name,
                            tags: ["standard", "season_episode"]
                        )
                        allMatches.append(seasonMatch)
                    }
                    
                    // Episode match
                    if let episodeRange = Range(result.range(at: 2), in: string) {
                        let episodeMatch = RuleMatch(
                            property: "episode",
                            value: groups[2],
                            range: episodeRange,
                            confidence: 0.95,
                            ruleName: name,
                            tags: ["standard", "season_episode"]
                        )
                        allMatches.append(episodeMatch)
                    }
                }
            }
        }
        
        // Handle 1x01 format
        let xFormatResults = RegexUtilities.matches(for: #"(\d{1,2})x(\d{1,3})"#, in: string)
        for result in xFormatResults {
            if result.numberOfRanges >= 3 {
                let groups = RegexUtilities.captureGroups(from: result, in: string)
                if groups.count >= 3 {
                    // Season match
                    if let seasonRange = Range(result.range(at: 1), in: string) {
                        let seasonMatch = RuleMatch(
                            property: "season",
                            value: groups[1],
                            range: seasonRange,
                            confidence: 0.9,
                            ruleName: name,
                            tags: ["x_format", "season_episode"]
                        )
                        allMatches.append(seasonMatch)
                    }
                    
                    // Episode match
                    if let episodeRange = Range(result.range(at: 2), in: string) {
                        let episodeMatch = RuleMatch(
                            property: "episode",
                            value: groups[2],
                            range: episodeRange,
                            confidence: 0.9,
                            ruleName: name,
                            tags: ["x_format", "season_episode"]
                        )
                        allMatches.append(episodeMatch)
                    }
                }
            }
        }
        
        // Only add individual season/episode patterns if we haven't found paired ones
        let hasSeasonEpisodePair = allMatches.contains { $0.hasTag("season_episode") }
        
        if !hasSeasonEpisodePair {
            // Process other patterns individually
            for pattern in patterns {
                if !pattern.tags.contains("season_episode") {
                    let results = RegexUtilities.matches(for: pattern.pattern, in: string)
                    for result in results {
                        if let match = createMatch(from: result, pattern: pattern, in: string) {
                            allMatches.append(match)
                        }
                    }
                }
            }
        }
        
        return allMatches
    }
    
    private func createMatch(from result: NSTextCheckingResult, pattern: RegexPattern, in string: String) -> RuleMatch? {
        let matchedText = string.substring(from: result)
        
        // For capture group patterns, use the first capture group
        var value = matchedText
        if result.numberOfRanges > 1 {
            let groups = RegexUtilities.captureGroups(from: result, in: string)
            if groups.count > 1 {
                value = groups[1]
            }
        }
        
        let formattedValue = pattern.formatter?(value) ?? value
        
        guard let range = Range(result.range, in: string) else { return nil }
        
        return RuleMatch(
            property: pattern.property,
            value: formattedValue,
            range: range,
            confidence: pattern.confidence,
            ruleName: name,
            tags: pattern.tags
        )
    }
}

// MARK: - Post-processing for Episode Rule
extension EpisodeRule: PostProcessingRule {
    
    public func postProcess(matches: [RuleMatch], context: ParseContext) -> [RuleMatch] {
        let seasonMatches = matches.filter { $0.property == "season" }
        let episodeMatches = matches.filter { $0.property == "episode" }
        let otherMatches = matches.filter { $0.property != "season" && $0.property != "episode" }
        
        // Keep the best season and episode matches
        var processedMatches = otherMatches
        
        if let bestSeason = selectBestMatch(seasonMatches) {
            processedMatches.append(bestSeason)
        }
        
        if let bestEpisode = selectBestMatch(episodeMatches) {
            processedMatches.append(bestEpisode)
        }
        
        return processedMatches
    }
    
    private func selectBestMatch(_ matches: [RuleMatch]) -> RuleMatch? {
        guard !matches.isEmpty else { return nil }
        
        // Prefer matches that are part of season/episode pairs
        let pairedMatches = matches.filter { $0.hasTag("season_episode") }
        if !pairedMatches.isEmpty {
            return pairedMatches.max { $0.confidence < $1.confidence }
        }
        
        // Otherwise, prefer highest confidence
        return matches.max { $0.confidence < $1.confidence }
    }
}

// MARK: - Episode Validation
extension EpisodeRule {
    
    /// Validates if a season number is reasonable
    public static func isValidSeason(_ season: Int) -> Bool {
        return season >= 1 && season <= 50  // Most shows don't exceed 50 seasons
    }
    
    /// Validates if an episode number is reasonable
    public static func isValidEpisode(_ episode: Int) -> Bool {
        return episode >= 1 && episode <= 999  // Some anime series have many episodes
    }
    
    /// Checks if season and episode combination is reasonable
    public static func isValidSeasonEpisode(season: Int, episode: Int) -> Bool {
        return isValidSeason(season) && isValidEpisode(episode)
    }
} 