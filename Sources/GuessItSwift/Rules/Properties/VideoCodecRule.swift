import Foundation

/// Rule for matching video codec information in media filenames
public struct VideoCodecRule: RegexRule {
    
    public let name = "VideoCodecRule"
    public let priority = RulePriority.normal
    public let properties = ["videoCodec", "videoProfile"]
    
    public var patterns: [RegexPattern] {
        return [
            // H.264 variants
            RegexPattern(
                pattern: #"\b[Hh]\.?264\b"#,
                property: "videoCodec",
                confidence: 0.9,
                tags: ["h264"],
                formatter: { _ in "H.264" }
            ),
            
            // x264 encoder
            RegexPattern(
                pattern: #"\bx264\b"#,
                property: "videoCodec",
                confidence: 0.95,
                tags: ["x264"],
                formatter: { _ in "H.264" }
            ),
            
            // AVC (Advanced Video Coding)
            RegexPattern(
                pattern: #"\bAVC\b"#,
                property: "videoCodec",
                confidence: 0.85,
                tags: ["avc"],
                formatter: { _ in "H.264" }
            ),
            
            // H.265 variants
            RegexPattern(
                pattern: #"\b[Hh]\.?265\b"#,
                property: "videoCodec",
                confidence: 0.9,
                tags: ["h265"],
                formatter: { _ in "H.265" }
            ),
            
            // x265 encoder
            RegexPattern(
                pattern: #"\bx265\b"#,
                property: "videoCodec",
                confidence: 0.95,
                tags: ["x265"],
                formatter: { _ in "H.265" }
            ),
            
            // HEVC (High Efficiency Video Coding)
            RegexPattern(
                pattern: #"\bHEVC\b"#,
                property: "videoCodec",
                confidence: 0.9,
                tags: ["hevc"],
                formatter: { _ in "H.265" }
            ),
            
            // XviD
            RegexPattern(
                pattern: #"\bXviD\b"#,
                property: "videoCodec",
                confidence: 0.9,
                tags: ["xvid"],
                formatter: { _ in "XviD" }
            ),
            
            // DivX
            RegexPattern(
                pattern: #"\bDivX\b"#,
                property: "videoCodec",
                confidence: 0.9,
                tags: ["divx"],
                formatter: { _ in "DivX" }
            ),
            
            // VP9
            RegexPattern(
                pattern: #"\bVP9\b"#,
                property: "videoCodec",
                confidence: 0.9,
                tags: ["vp9"],
                formatter: { _ in "VP9" }
            ),
            
            // AV1
            RegexPattern(
                pattern: #"\bAV1\b"#,
                property: "videoCodec",
                confidence: 0.9,
                tags: ["av1"],
                formatter: { _ in "AV1" }
            ),
            
            // MPEG-2
            RegexPattern(
                pattern: #"\bMPEG-?2\b"#,
                property: "videoCodec",
                confidence: 0.8,
                tags: ["mpeg2"],
                formatter: { _ in "MPEG-2" }
            ),
            
            // Video profiles
            RegexPattern(
                pattern: #"\b(High|Main|Baseline|Extended)\s*Profile\b"#,
                property: "videoProfile",
                confidence: 0.8,
                tags: ["profile"],
                formatter: RuleFormatters.titleCase
            ),
            
            // Simplified profile indicators
            RegexPattern(
                pattern: #"\b(Hi|HP|MP|BP|XP)\b"#,
                property: "videoProfile",
                confidence: 0.6,
                tags: ["profile", "abbreviated"],
                formatter: { value in
                    switch value.uppercased() {
                    case "HI", "HP": return "High"
                    case "MP": return "Main"
                    case "BP": return "Baseline"
                    case "XP": return "Extended"
                    default: return value
                    }
                }
            )
        ]
    }
    

    
    public func shouldApply(in context: ParseContext) -> Bool {
        return context.options.shouldProcess(property: "videoCodec") || 
               context.options.shouldProcess(property: "videoProfile")
    }
    
    // Override matches to combine regex and string matching
    public func matches(in context: ParseContext) -> [RuleMatch] {
        guard shouldApply(in: context) else { return [] }
        
        var allMatches: [RuleMatch] = []
        
        // Get regex matches from the default implementation
        let string = context.cleanedString
        for pattern in patterns {
            let results = RegexUtilities.matches(for: pattern.pattern, in: string)
            
            for result in results {
                if let match = createMatch(from: result, pattern: pattern, in: string, context: context) {
                    allMatches.append(match)
                }
            }
        }
        
        // Add string matches
        allMatches.append(contentsOf: matchStringPatterns(in: context))
        
        return allMatches
    }
    
    private func createMatch(from result: NSTextCheckingResult, pattern: RegexPattern, in string: String, context: ParseContext) -> RuleMatch? {
        let matchedText = string.substring(from: result)
        let value = pattern.formatter?(matchedText) ?? matchedText
        
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
    
    // String matching implementation
    private func matchStringPatterns(in context: ParseContext) -> [RuleMatch] {
        guard shouldApply(in: context) else { return [] }
        
        var matches: [RuleMatch] = []
        let string = context.cleanedString.lowercased()
        
        let stringPatterns = [
            // Additional string-based matching for edge cases
            StringPattern(
                strings: ["h264", "h.264"],
                property: "videoCodec",
                value: "H.264",
                confidence: 0.8,
                tags: ["string_match"]
            ),
            
            StringPattern(
                strings: ["h265", "h.265"],
                property: "videoCodec",
                value: "H.265",
                confidence: 0.8,
                tags: ["string_match"]
            ),
            
            StringPattern(
                strings: ["hevc"],
                property: "videoCodec",
                value: "H.265",
                confidence: 0.8,
                tags: ["string_match"]
            )
        ]
        
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

// MARK: - Post-processing for Video Codec Rule
extension VideoCodecRule: PostProcessingRule {
    
    public func postProcess(matches: [RuleMatch], context: ParseContext) -> [RuleMatch] {
        let codecMatches = matches.filter { $0.property == "videoCodec" }
        let profileMatches = matches.filter { $0.property == "videoProfile" }
        let otherMatches = matches.filter { $0.property != "videoCodec" && $0.property != "videoProfile" }
        
        // Process codec matches - keep the highest confidence one
        let processedCodecMatches = processCodecMatches(codecMatches)
        
        // Process profile matches - associate with codec if possible
        let processedProfileMatches = processProfileMatches(profileMatches, codecMatches: processedCodecMatches)
        
        return otherMatches + processedCodecMatches + processedProfileMatches
    }
    
    private func processCodecMatches(_ matches: [RuleMatch]) -> [RuleMatch] {
        guard !matches.isEmpty else { return [] }
        
        // Group by normalized codec name
        var codecGroups: [String: [RuleMatch]] = [:]
        
        for match in matches {
            let normalizedCodec = normalizeCodecName(match.value)
            codecGroups[normalizedCodec, default: []].append(match)
        }
        
        // For each codec group, keep the highest confidence match
        var result: [RuleMatch] = []
        
        for (_, groupMatches) in codecGroups {
            if let bestMatch = groupMatches.max(by: { $0.confidence < $1.confidence }) {
                result.append(bestMatch)
            }
        }
        
        // If we have multiple different codecs, prefer the most specific one
        if result.count > 1 {
            result = [selectBestCodecMatch(result)]
        }
        
        return result
    }
    
    private func processProfileMatches(_ matches: [RuleMatch], codecMatches: [RuleMatch]) -> [RuleMatch] {
        guard !matches.isEmpty else { return [] }
        
        // If we have a codec match, validate that the profile is compatible
        if let codecMatch = codecMatches.first {
            let compatibleProfiles = getCompatibleProfiles(for: codecMatch.value)
            return matches.filter { match in
                compatibleProfiles.contains(match.value)
            }
        }
        
        // If no codec match, keep all profile matches
        return matches
    }
    
    private func normalizeCodecName(_ codecName: String) -> String {
        let normalized = codecName.lowercased()
        
        switch normalized {
        case "h.264", "h264", "x264", "avc":
            return "h.264"
        case "h.265", "h265", "x265", "hevc":
            return "h.265"
        case "xvid":
            return "xvid"
        case "divx":
            return "divx"
        case "vp9":
            return "vp9"
        case "av1":
            return "av1"
        case "mpeg-2", "mpeg2":
            return "mpeg-2"
        default:
            return normalized
        }
    }
    
    private func selectBestCodecMatch(_ matches: [RuleMatch]) -> RuleMatch {
        // Preference order: newer codecs first, then by confidence
        let codecPriority = [
            "av1": 10,
            "h.265": 9,
            "vp9": 8,
            "h.264": 7,
            "xvid": 6,
            "divx": 5,
            "mpeg-2": 4
        ]
        
        return matches.max { first, second in
            let firstPriority = codecPriority[normalizeCodecName(first.value)] ?? 0
            let secondPriority = codecPriority[normalizeCodecName(second.value)] ?? 0
            
            if firstPriority != secondPriority {
                return firstPriority < secondPriority
            }
            
            return first.confidence < second.confidence
        } ?? matches[0]
    }
    
    private func getCompatibleProfiles(for codec: String) -> [String] {
        let normalizedCodec = normalizeCodecName(codec)
        
        switch normalizedCodec {
        case "h.264", "h.265":
            return ["High", "Main", "Baseline", "Extended"]
        default:
            return [] // Other codecs don't typically have profile specifications in filenames
        }
    }
}

// MARK: - Video Codec Utilities
extension VideoCodecRule {
    
    /// Returns true if the codec is considered modern/high-quality
    public static func isModernCodec(_ codec: String) -> Bool {
        let modernCodecs = ["H.265", "AV1", "VP9"]
        return modernCodecs.contains(codec)
    }
    
    /// Returns true if the codec supports HDR
    public static func supportsHDR(_ codec: String) -> Bool {
        let hdrCodecs = ["H.265", "AV1", "VP9"]
        return hdrCodecs.contains(codec)
    }
    
    /// Returns the typical file size efficiency compared to H.264
    public static func getCompressionEfficiency(_ codec: String) -> Double {
        switch codec {
        case "AV1": return 0.5      // 50% smaller than H.264
        case "H.265": return 0.6    // 40% smaller than H.264
        case "VP9": return 0.65     // 35% smaller than H.264
        case "H.264": return 1.0    // Baseline
        case "XviD": return 1.2     // 20% larger than H.264
        case "DivX": return 1.3     // 30% larger than H.264
        case "MPEG-2": return 2.0   // 100% larger than H.264
        default: return 1.0
        }
    }
} 