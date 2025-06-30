import Foundation

/// Rule for matching source information in media filenames
public struct SourceRule: RegexRule {
    
    public let name = "SourceRule"
    public let priority = RulePriority.normal
    public let properties = ["source"]
    
    public var patterns: [RegexPattern] {
        return [
            // Blu-ray variants
            RegexPattern(
                pattern: #"\b(?:BluRay|Blu-Ray|BDRip|BRRip|BD)\b"#,
                property: "source",
                confidence: 0.9,
                tags: ["bluray"],
                formatter: { _ in "Blu-ray" }
            ),
            
            // DVD variants
            RegexPattern(
                pattern: #"\b(?:DVD|DVDRip)\b"#,
                property: "source",
                confidence: 0.9,
                tags: ["dvd"],
                formatter: { _ in "DVD" }
            ),
            
            // HDTV
            RegexPattern(
                pattern: #"\bHDTV\b"#,
                property: "source",
                confidence: 0.95,
                tags: ["hdtv"],
                formatter: { _ in "HDTV" }
            ),
            
            // WEB-DL variants
            RegexPattern(
                pattern: #"\b(?:WEB-DL|WEBDL|WEB\.DL)\b"#,
                property: "source",
                confidence: 0.9,
                tags: ["web-dl"],
                formatter: { _ in "WEB-DL" }
            ),
            
            // WEBRip variants
            RegexPattern(
                pattern: #"\b(?:WEBRip|WEB-Rip|WEB\.Rip)\b"#,
                property: "source",
                confidence: 0.9,
                tags: ["webrip"],
                formatter: { _ in "WEBRip" }
            ),
            
            // CAM
            RegexPattern(
                pattern: #"\bCAM\b"#,
                property: "source",
                confidence: 0.8,
                tags: ["cam"],
                formatter: { _ in "CAM" }
            ),
            
            // TS (TeleSync)
            RegexPattern(
                pattern: #"\b(?:TS|TeleSync)\b"#,
                property: "source",
                confidence: 0.8,
                tags: ["ts"],
                formatter: { _ in "TS" }
            ),
            
            // TC (TeleCine)
            RegexPattern(
                pattern: #"\b(?:TC|TeleCine)\b"#,
                property: "source",
                confidence: 0.8,
                tags: ["tc"],
                formatter: { _ in "TC" }
            ),
            
            // VHS
            RegexPattern(
                pattern: #"\bVHS\b"#,
                property: "source",
                confidence: 0.8,
                tags: ["vhs"],
                formatter: { _ in "VHS" }
            ),
            
            // HD-DVD
            RegexPattern(
                pattern: #"\b(?:HD-DVD|HDDVD)\b"#,
                property: "source",
                confidence: 0.9,
                tags: ["hddvd"],
                formatter: { _ in "HD-DVD" }
            )
        ]
    }
}

// MARK: - Post-processing for Source Rule
extension SourceRule: PostProcessingRule {
    
    public func postProcess(matches: [RuleMatch], context: ParseContext) -> [RuleMatch] {
        let sourceMatches = matches.filter { $0.property == "source" }
        let otherMatches = matches.filter { $0.property != "source" }
        
        // If we have multiple source matches, keep the highest confidence one
        guard !sourceMatches.isEmpty else { return matches }
        
        let bestSource = sourceMatches.max { first, second in
            if first.confidence != second.confidence {
                return first.confidence < second.confidence
            }
            
            // Prefer more specific sources
            let sourcePriority = getSourcePriority(first.value)
            let otherPriority = getSourcePriority(second.value)
            return sourcePriority < otherPriority
        }
        
        if let bestSource = bestSource {
            return otherMatches + [bestSource]
        }
        
        return otherMatches
    }
    
    private func getSourcePriority(_ source: String) -> Int {
        // Higher numbers = higher priority
        switch source.lowercased() {
        case "blu-ray": return 10
        case "web-dl": return 9
        case "webrip": return 8
        case "hdtv": return 7
        case "dvd": return 6
        case "hd-dvd": return 5
        case "vhs": return 4
        case "ts": return 3
        case "tc": return 2
        case "cam": return 1
        default: return 0
        }
    }
}

// MARK: - Source Utilities
extension SourceRule {
    
    /// Returns true if the source is considered high quality
    public static func isHighQualitySource(_ source: String) -> Bool {
        let highQualitySources = ["Blu-ray", "WEB-DL", "WEBRip"]
        return highQualitySources.contains(source)
    }
    
    /// Returns true if the source is a physical media
    public static func isPhysicalMedia(_ source: String) -> Bool {
        let physicalSources = ["Blu-ray", "DVD", "HD-DVD", "VHS"]
        return physicalSources.contains(source)
    }
    
    /// Returns true if the source is digital/streaming
    public static func isDigitalSource(_ source: String) -> Bool {
        let digitalSources = ["WEB-DL", "WEBRip", "HDTV"]
        return digitalSources.contains(source)
    }
    
    /// Returns the typical quality expectation for a source
    public static func getQualityExpectation(_ source: String) -> String {
        switch source {
        case "Blu-ray": return "High"
        case "WEB-DL": return "High"
        case "WEBRip": return "Medium-High"
        case "HDTV": return "Medium"
        case "DVD": return "Medium"
        case "HD-DVD": return "High"
        case "VHS": return "Low"
        case "TS": return "Low"
        case "TC": return "Low"
        case "CAM": return "Very Low"
        default: return "Unknown"
        }
    }
} 