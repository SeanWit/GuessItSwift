import Foundation

/// Utility class for regular expression operations
public struct RegexUtilities {
    
    /// Cache for compiled regular expressions
    private static var regexCache: [String: NSRegularExpression] = [:]
    private static let cacheQueue = DispatchQueue(label: "regex.cache", attributes: .concurrent)
    
    /// Compiles and caches a regular expression
    public static func regex(for pattern: String, options: NSRegularExpression.Options = [.caseInsensitive]) throws -> NSRegularExpression {
        let cacheKey = "\(pattern)|\(options.rawValue)"
        
        return try cacheQueue.sync {
            if let cached = regexCache[cacheKey] {
                return cached
            }
            
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            regexCache[cacheKey] = regex
            return regex
        }
    }
    
    /// Finds all matches for a pattern in the given string
    public static func matches(for pattern: String, in string: String, options: NSRegularExpression.Options = [.caseInsensitive]) -> [NSTextCheckingResult] {
        do {
            let regex = try self.regex(for: pattern, options: options)
            return regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
        } catch {
            return []
        }
    }
    
    /// Finds the first match for a pattern in the given string
    public static func firstMatch(for pattern: String, in string: String, options: NSRegularExpression.Options = [.caseInsensitive]) -> NSTextCheckingResult? {
        do {
            let regex = try self.regex(for: pattern, options: options)
            return regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
        } catch {
            return nil
        }
    }
    
    /// Tests if a string matches a pattern
    public static func test(pattern: String, string: String, options: NSRegularExpression.Options = [.caseInsensitive]) -> Bool {
        return firstMatch(for: pattern, in: string, options: options) != nil
    }
    
    /// Extracts captured groups from a match
    public static func captureGroups(from match: NSTextCheckingResult, in string: String) -> [String] {
        var groups: [String] = []
        
        for i in 0..<match.numberOfRanges {
            let range = match.range(at: i)
            if range.location != NSNotFound {
                let substring = (string as NSString).substring(with: range)
                groups.append(substring)
            } else {
                groups.append("")
            }
        }
        
        return groups
    }
    
    /// Extracts named capture groups from a match
    public static func namedCaptureGroups(from match: NSTextCheckingResult, in string: String, regex: NSRegularExpression) -> [String: String] {
        let groups: [String: String] = [:]
        
        // Note: NSRegularExpression doesn't directly support named groups in the same way as other regex engines
        // This is a simplified implementation that would need enhancement for full named group support
        
        return groups
    }
    
    /// Clears the regex cache
    public static func clearCache() {
        cacheQueue.async(flags: .barrier) {
            regexCache.removeAll()
        }
    }
}

// MARK: - String Extensions for Regex
extension String {
    
    /// Tests if the string matches a regular expression pattern
    func matches(pattern: String, options: NSRegularExpression.Options = [.caseInsensitive]) -> Bool {
        return RegexUtilities.test(pattern: pattern, string: self, options: options)
    }
    
    /// Returns all matches for a pattern in this string
    func allMatches(for pattern: String, options: NSRegularExpression.Options = [.caseInsensitive]) -> [NSTextCheckingResult] {
        return RegexUtilities.matches(for: pattern, in: self, options: options)
    }
    
    /// Returns the first match for a pattern in this string
    func firstMatch(for pattern: String, options: NSRegularExpression.Options = [.caseInsensitive]) -> NSTextCheckingResult? {
        return RegexUtilities.firstMatch(for: pattern, in: self, options: options)
    }
    
    /// Extracts the matched substring from a text checking result
    func substring(from result: NSTextCheckingResult) -> String {
        return (self as NSString).substring(with: result.range)
    }
    
    /// Extracts capture groups from a text checking result
    func captureGroups(from result: NSTextCheckingResult) -> [String] {
        return RegexUtilities.captureGroups(from: result, in: self)
    }
    
    /// Replaces matches of a pattern with a replacement string
    func replacingMatches(of pattern: String, with replacement: String, options: NSRegularExpression.Options = [.caseInsensitive]) -> String {
        do {
            let regex = try RegexUtilities.regex(for: pattern, options: options)
            return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count), withTemplate: replacement)
        } catch {
            return self
        }
    }
}

// MARK: - Common Regex Patterns
extension RegexUtilities {
    
    /// Common regex patterns used in media file parsing
    public struct Patterns {
        
        // Year patterns
        public static let year = #"\b(19|20)\d{2}\b"#
        public static let yearInParentheses = #"\((19|20)\d{2}\)"#
        
        // Season and Episode patterns
        public static let seasonEpisode = #"[Ss](\d{1,2})[Ee](\d{1,2})"#
        public static let seasonEpisodeX = #"(\d{1,2})x(\d{1,2})"#
        public static let episode = #"[Ee]p?(\d{1,3})"#
        public static let season = #"[Ss]eason\s*(\d{1,2})"#
        
        // Quality patterns
        public static let resolution = #"\b(480p|720p|1080p|1080i|2160p|4K|8K)\b"#
        public static let source = #"\b(BluRay|Blu-Ray|BDRip|BRRip|DVD|DVDRip|HDTV|WEB-DL|WEBRip|CAM|TS|TC)\b"#
        
        // Codec patterns
        public static let videoCodec = #"\b(H\.?264|H\.?265|x264|x265|XviD|DivX|AVC|HEVC|VP9|AV1)\b"#
        public static let audioCodec = #"\b(AAC|AC3|DTS|FLAC|MP3|Opus|TrueHD|Atmos)\b"#
        
        // Audio channels
        public static let audioChannels = #"\b(1\.0|2\.0|5\.1|7\.1|mono|stereo)\b"#
        
        // Language patterns
        public static let language = #"\b(english|french|spanish|german|italian|japanese|korean|chinese|russian|portuguese|dutch|swedish|norwegian|danish|finnish)\b"#
        
        // Release group patterns
        public static let releaseGroup = #"-([A-Za-z0-9]+)$"#
        public static let releaseGroupBrackets = #"\[([A-Za-z0-9]+)\]"#
        
        // Container formats
        public static let container = #"\.(mkv|mp4|avi|mov|wmv|flv|webm|m4v|3gp|ts|m2ts)$"#
        
        // Edition patterns
        public static let edition = #"\b(Director'?s?\s*Cut|Extended|Unrated|Theatrical|IMAX|Remastered|Criterion)\b"#
        
        // Other patterns
        public static let proper = #"\b(PROPER|REPACK|REAL)\b"#
        public static let region = #"\bR[1-6]\b"#
        public static let crc32 = #"\b[A-Fa-f0-9]{8}\b"#
        
        // Website patterns
        public static let website = #"\b(?:www\.)?([a-zA-Z0-9-]+\.[a-zA-Z]{2,})\b"#
        
        // Size patterns
        public static let fileSize = #"\b(\d+(?:\.\d+)?)\s*(GB|MB|KB|TB)\b"#
        
        // Bit rate patterns
        public static let bitRate = #"\b(\d+)\s*kbps\b"#
    }
}

// MARK: - Pattern Validation
extension RegexUtilities {
    
    /// Validates if a string is a valid regular expression pattern
    public static func isValidPattern(_ pattern: String) -> Bool {
        do {
            _ = try NSRegularExpression(pattern: pattern, options: [])
            return true
        } catch {
            return false
        }
    }
    
    /// Escapes special regex characters in a string
    public static func escape(_ string: String) -> String {
        return NSRegularExpression.escapedPattern(for: string)
    }
} 