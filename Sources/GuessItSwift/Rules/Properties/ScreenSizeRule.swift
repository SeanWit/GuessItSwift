import Foundation

/// Rule for matching screen size/resolution information in media filenames
public struct ScreenSizeRule: RegexRule {
    
    public let name = "ScreenSizeRule"
    public let priority = RulePriority.normal
    public let properties = ["screenSize"]
    
    public var patterns: [RegexPattern] {
        return [
            // Standard HD resolutions
            RegexPattern(
                pattern: #"\b720p?\b"#,
                property: "screenSize",
                confidence: 0.9,
                tags: ["hd"],
                formatter: { _ in "720p" }
            ),
            
            RegexPattern(
                pattern: #"\b1080p?\b"#,
                property: "screenSize",
                confidence: 0.9,
                tags: ["fullhd"],
                formatter: { _ in "1080p" }
            ),
            
            RegexPattern(
                pattern: #"\b1080i?\b"#,
                property: "screenSize",
                confidence: 0.9,
                tags: ["fullhd", "interlaced"],
                formatter: { _ in "1080i" }
            ),
            
            // 4K and Ultra HD
            RegexPattern(
                pattern: #"\b2160p?\b"#,
                property: "screenSize",
                confidence: 0.9,
                tags: ["4k", "uhd"],
                formatter: { _ in "2160p" }
            ),
            
            RegexPattern(
                pattern: #"\b4K\b"#,
                property: "screenSize",
                confidence: 0.85,
                tags: ["4k"],
                formatter: { _ in "4K" }
            ),
            
            RegexPattern(
                pattern: #"\bUHD\b"#,
                property: "screenSize",
                confidence: 0.8,
                tags: ["uhd"],
                formatter: { _ in "2160p" }
            ),
            
            // 8K
            RegexPattern(
                pattern: #"\b4320p?\b"#,
                property: "screenSize",
                confidence: 0.9,
                tags: ["8k"],
                formatter: { _ in "4320p" }
            ),
            
            RegexPattern(
                pattern: #"\b8K\b"#,
                property: "screenSize",
                confidence: 0.85,
                tags: ["8k"],
                formatter: { _ in "8K" }
            ),
            
            // Standard Definition
            RegexPattern(
                pattern: #"\b480p?\b"#,
                property: "screenSize",
                confidence: 0.9,
                tags: ["sd"],
                formatter: { _ in "480p" }
            ),
            
            RegexPattern(
                pattern: #"\b576p?\b"#,
                property: "screenSize",
                confidence: 0.9,
                tags: ["sd"],
                formatter: { _ in "576p" }
            ),
            
            // Less common resolutions
            RegexPattern(
                pattern: #"\b540p?\b"#,
                property: "screenSize",
                confidence: 0.8,
                tags: ["sd"],
                formatter: { _ in "540p" }
            ),
            
            RegexPattern(
                pattern: #"\b360p?\b"#,
                property: "screenSize",
                confidence: 0.8,
                tags: ["sd"],
                formatter: { _ in "360p" }
            ),
            
            RegexPattern(
                pattern: #"\b240p?\b"#,
                property: "screenSize",
                confidence: 0.8,
                tags: ["sd"],
                formatter: { _ in "240p" }
            )
        ]
    }
    
    public func shouldApply(in context: ParseContext) -> Bool {
        guard context.options.shouldProcess(property: "screenSize") else { return false }
        return !context.hasMatch(for: "screenSize")
    }
}

// MARK: - Post-processing for Screen Size Rule
extension ScreenSizeRule: PostProcessingRule {
    
    public func postProcess(matches: [RuleMatch], context: ParseContext) -> [RuleMatch] {
        let screenSizeMatches = matches.filter { $0.property == "screenSize" }
        let otherMatches = matches.filter { $0.property != "screenSize" }
        
        // If no screen size matches, return all matches as-is
        guard !screenSizeMatches.isEmpty else { return matches }
        
        // Sort screen size matches by preference
        let sortedMatches = screenSizeMatches.sorted { first, second in
            // Prefer progressive over interlaced
            if first.hasTag("interlaced") && !second.hasTag("interlaced") {
                return false
            }
            if second.hasTag("interlaced") && !first.hasTag("interlaced") {
                return true
            }
            
            // Prefer higher resolution
            let firstResolution = getResolutionPriority(first.value)
            let secondResolution = getResolutionPriority(second.value)
            
            if firstResolution != secondResolution {
                return firstResolution > secondResolution
            }
            
            // Prefer higher confidence
            return first.confidence > second.confidence
        }
        
        // Return the best screen size match plus all other matches
        if let bestMatch = sortedMatches.first {
            return otherMatches + [bestMatch]
        }
        
        return otherMatches
    }
    
    private func getResolutionPriority(_ screenSize: String) -> Int {
        switch screenSize.lowercased() {
        case "8k", "4320p": return 8
        case "4k", "2160p": return 7
        case "1080p": return 6
        case "1080i": return 5
        case "720p": return 4
        case "576p": return 3
        case "540p": return 2
        case "480p": return 1
        case "360p": return 0
        case "240p": return -1
        default: return 0
        }
    }
}

// MARK: - Screen Size Utilities
extension ScreenSizeRule {
    
    /// Returns true if the screen size is considered high definition
    public static func isHD(_ screenSize: String) -> Bool {
        let hdResolutions = ["720p", "1080p", "1080i"]
        return hdResolutions.contains(screenSize)
    }
    
    /// Returns true if the screen size is considered ultra high definition
    public static func isUHD(_ screenSize: String) -> Bool {
        let uhdResolutions = ["4K", "2160p", "8K", "4320p"]
        return uhdResolutions.contains(screenSize)
    }
    
    /// Returns the approximate pixel count for the screen size
    public static func getPixelCount(_ screenSize: String) -> Int? {
        switch screenSize.lowercased() {
        case "240p": return 320 * 240
        case "360p": return 640 * 360
        case "480p": return 854 * 480
        case "540p": return 960 * 540
        case "576p": return 1024 * 576
        case "720p": return 1280 * 720
        case "1080p", "1080i": return 1920 * 1080
        case "2160p", "4k": return 3840 * 2160
        case "4320p", "8k": return 7680 * 4320
        default: return nil
        }
    }
    
    /// Returns the aspect ratio for the screen size
    public static func getAspectRatio(_ screenSize: String) -> String? {
        switch screenSize.lowercased() {
        case "240p", "360p", "480p", "540p", "720p", "1080p", "1080i", "2160p", "4k", "4320p", "8k":
            return "16:9"
        case "576p":
            return "16:9" // PAL widescreen
        default:
            return nil
        }
    }
} 