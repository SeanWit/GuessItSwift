import Foundation

/// Rule for matching container format information from file extensions
public struct ContainerRule: RegexRule {
    
    public let name = "ContainerRule"
    public let priority = RulePriority.low
    public let properties = ["container"]
    
    public var patterns: [RegexPattern] {
        return [
            // AVI container
            RegexPattern(
                pattern: #"\.avi$"#,
                property: "container",
                confidence: 0.95,
                tags: ["video"],
                formatter: { match in
                    return String(match.dropFirst()) // Remove the dot
                }
            ),
            
            // MKV container
            RegexPattern(
                pattern: #"\.mkv$"#,
                property: "container",
                confidence: 0.95,
                tags: ["video"],
                formatter: { match in
                    return String(match.dropFirst()) // Remove the dot
                }
            ),
            
            // MP4 container
            RegexPattern(
                pattern: #"\.mp4$"#,
                property: "container",
                confidence: 0.95,
                tags: ["video"],
                formatter: { match in
                    return String(match.dropFirst()) // Remove the dot
                }
            ),
            
            // Audio containers (for completeness)
            RegexPattern(
                pattern: #"\.(?:mp3|flac|aac|ogg|wav|m4a|wma)$"#,
                property: "container",
                confidence: 0.95,
                tags: ["audio"],
                formatter: { match in
                    return String(match.dropFirst()) // Remove the dot
                }
            )
        ]
    }
}

// MARK: - Post-processing for Container Rule
extension ContainerRule: PostProcessingRule {
    
    public func postProcess(matches: [RuleMatch], context: ParseContext) -> [RuleMatch] {
        let containerMatches = matches.filter { $0.property == "container" }
        let otherMatches = matches.filter { $0.property != "container" }
        
        guard !containerMatches.isEmpty else { return matches }
        
        // For container, we typically only want one match (the file extension)
        // Keep the highest confidence match
        if let bestContainer = containerMatches.max(by: { $0.confidence < $1.confidence }) {
            return otherMatches + [bestContainer]
        }
        
        return otherMatches
    }
}

// MARK: - Container Utilities
extension ContainerRule {
    
    /// Returns the MIME type for a given container format
    public static func getMimeType(for container: String) -> String? {
        let mimeTypes = [
            "mp4": "video/mp4",
            "mkv": "video/x-matroska",
            "avi": "video/x-msvideo",
            "mov": "video/quicktime",
            "wmv": "video/x-ms-wmv",
            "flv": "video/x-flv",
            "webm": "video/webm",
            "m4v": "video/x-m4v",
            "3gp": "video/3gpp",
            "ts": "video/mp2t",
            "m2ts": "video/mp2t",
            "vob": "video/dvd",
            "mpg": "video/mpeg",
            "mpeg": "video/mpeg",
            "mp3": "audio/mpeg",
            "flac": "audio/flac",
            "aac": "audio/aac",
            "ogg": "audio/ogg",
            "wav": "audio/wav",
            "m4a": "audio/mp4",
            "wma": "audio/x-ms-wma"
        ]
        
        return mimeTypes[container.lowercased()]
    }
    
    /// Returns true if the container is a video format
    public static func isVideoContainer(_ container: String) -> Bool {
        let videoContainers = ["mp4", "mkv", "avi", "mov", "wmv", "flv", "webm", "m4v", "3gp", "ts", "m2ts", "vob", "mpg", "mpeg"]
        return videoContainers.contains(container.lowercased())
    }
    
    /// Returns true if the container is an audio format
    public static func isAudioContainer(_ container: String) -> Bool {
        let audioContainers = ["mp3", "flac", "aac", "ogg", "wav", "m4a", "wma"]
        return audioContainers.contains(container.lowercased())
    }
    
    /// Returns the quality expectation for a container format
    public static func getQualityExpectation(_ container: String) -> String {
        switch container.lowercased() {
        case "mkv": return "High"
        case "mp4": return "High"
        case "mov": return "High"
        case "webm": return "Medium-High"
        case "avi": return "Medium"
        case "wmv": return "Medium"
        case "flv": return "Low"
        case "3gp": return "Low"
        default: return "Unknown"
        }
    }
} 