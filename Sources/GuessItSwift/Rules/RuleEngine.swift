import Foundation

/// Engine responsible for coordinating rule execution and processing results
public class RuleEngine {
    
    private let configuration: RuleConfiguration
    private let rules: [Rule]
    
    public init(configuration: RuleConfiguration = .default) {
        self.configuration = configuration
        self.rules = Self.createDefaultRules()
    }
    
    public init(configuration: RuleConfiguration, customRules: [Rule]) {
        self.configuration = configuration
        self.rules = customRules
    }
    
    /// Processes a filename using all configured rules
    public func process(filename: String, options: ParseOptions = ParseOptions()) -> GuessItResult<MatchResult> {
        do {
            let context = ParseContext(
                originalString: filename,
                options: options,
                configuration: configuration
            )
            
            let matches = try executeRules(context: context)
            let processedMatches = try postProcessMatches(matches, context: context)
            let result = try buildMatchResult(from: processedMatches, context: context)
            
            return .success(result)
        } catch let error as GuessItError {
            return .failure(error)
        } catch {
            return .failure(.processingError("Unexpected error: \(error.localizedDescription)"))
        }
    }
    
    // MARK: - Private Methods
    
    private func executeRules(context: ParseContext) throws -> [RuleMatch] {
        var allMatches: [RuleMatch] = []
        var mutableContext = context
        
        // Sort rules by priority (highest first)
        let sortedRules = rules.sorted { $0.priority > $1.priority }
        
        for rule in sortedRules {
            guard rule.shouldApply(in: mutableContext) else { continue }
            
            do {
                let ruleMatches = rule.matches(in: mutableContext)
                allMatches.append(contentsOf: ruleMatches)
                
                // Add matches to context for subsequent rules
                for match in ruleMatches {
                    mutableContext.addMatch(match)
                }
            } catch {
                throw GuessItError.ruleError("Failed to execute rule: \(error.localizedDescription)", rule: rule.name)
            }
        }
        
        return allMatches
    }
    
    private func postProcessMatches(_ matches: [RuleMatch], context: ParseContext) throws -> [RuleMatch] {
        var processedMatches = matches
        
        // Apply post-processing rules
        let postProcessingRules = rules.compactMap { $0 as? PostProcessingRule }
        
        for rule in postProcessingRules {
            guard rule.shouldApply(in: context) else { continue }
            
            do {
                processedMatches = rule.postProcess(matches: processedMatches, context: context)
            } catch {
                throw GuessItError.ruleError("Failed to post-process with rule: \(error.localizedDescription)", rule: rule.name)
            }
        }
        
        // Apply conflict resolution
        processedMatches = try resolveConflicts(processedMatches)
        
        return processedMatches
    }
    
    private func resolveConflicts(_ matches: [RuleMatch]) throws -> [RuleMatch] {
        var resolvedMatches: [RuleMatch] = []
        
        // Group matches by property
        let groupedMatches = Dictionary(grouping: matches) { $0.property }
        
        for (property, propertyMatches) in groupedMatches {
            if propertyMatches.count == 1 {
                resolvedMatches.append(propertyMatches[0])
            } else {
                // Resolve conflicts for this property
                let resolved = try resolvePropertyConflicts(propertyMatches, property: property)
                resolvedMatches.append(contentsOf: resolved)
            }
        }
        
        return resolvedMatches
    }
    
    private func resolvePropertyConflicts(_ matches: [RuleMatch], property: String) throws -> [RuleMatch] {
        // For most properties, prefer the highest confidence match
        // Some properties (like language) can have multiple values
        
        let multiValueProperties = ["language", "subtitleLanguage", "country", "edition", "other", "episodeDetails"]
        
        if multiValueProperties.contains(property) {
            // Keep all matches for multi-value properties, but remove duplicates
            var uniqueValues = Set<String>()
            return matches.filter { match in
                if uniqueValues.contains(match.value) {
                    return false
                }
                uniqueValues.insert(match.value)
                return true
            }
        } else {
            // For single-value properties, keep the highest confidence match
            guard let bestMatch = matches.max(by: { $0.confidence < $1.confidence }) else {
                throw GuessItError.processingError("No matches found for property: \(property)")
            }
            return [bestMatch]
        }
    }
    
    private func buildMatchResult(from matches: [RuleMatch], context: ParseContext) throws -> MatchResult {
        var result = MatchResult()
        
        // Set input string if requested
        if context.options.outputInputString {
            result.inputString = context.originalString
        }
        
        // Set processing time
        result.processingTime = context.processingTime
        
        // Calculate overall confidence
        result.confidence = calculateOverallConfidence(matches)
        
        // Group matches by property and populate result
        let groupedMatches = Dictionary(grouping: matches) { $0.property }
        
        for (property, propertyMatches) in groupedMatches {
            try populateResult(&result, property: property, matches: propertyMatches, context: context)
        }
        
        // Infer media type if not explicitly set
        if result.type == nil {
            result.type = inferMediaType(result)
        }
        
        // Set container and mimetype from file extension if not detected
        if result.container == nil {
            result.container = context.originalString.fileExtension
        }
        
        if result.mimetype == nil {
            if let container = result.container {
                result.mimetype = ContainerRule.getMimeType(for: container)
            } else {
                result.mimetype = getMimeType(for: result.container)
            }
        }
        
        return result
    }
    
    private func populateResult(_ result: inout MatchResult, property: String, matches: [RuleMatch], context: ParseContext) throws {
        switch property {
        case "title":
            result.title = matches.first?.value
        case "alternativeTitle":
            result.alternativeTitle = matches.first?.value
        case "year":
            if let yearString = matches.first?.value, let year = Int(yearString) {
                result.year = year
            }
        case "season":
            result.season = Int(matches.first?.value ?? "")
        case "episode":
            result.episode = Int(matches.first?.value ?? "")
        case "episodeTitle":
            result.episodeTitle = matches.first?.value
        case "episodeCount":
            result.episodeCount = Int(matches.first?.value ?? "")
        case "seasonCount":
            result.seasonCount = Int(matches.first?.value ?? "")
        case "absoluteEpisode":
            result.absoluteEpisode = Int(matches.first?.value ?? "")
        case "part":
            result.part = Int(matches.first?.value ?? "")
        case "version":
            result.version = Int(matches.first?.value ?? "")
        case "videoCodec":
            result.videoCodec = matches.first?.value
        case "audioCodec":
            result.audioCodec = matches.first?.value
        case "audioChannels":
            result.audioChannels = matches.first?.value
        case "audioProfile":
            result.audioProfile = matches.first?.value
        case "videoProfile":
            result.videoProfile = matches.first?.value
        case "screenSize":
            result.screenSize = matches.first?.value
        case "container":
            result.container = matches.first?.value
        case "source":
            result.source = matches.first?.value
        case "release_group":
            result.releaseGroup = matches.first?.value
        case "website":
            result.website = matches.first?.value
        case "streaming":
            result.streaming = matches.first?.value
        case "language":
            result.language = matches.map { $0.value }
        case "subtitleLanguage":
            result.subtitleLanguage = matches.map { $0.value }
        case "country":
            result.country = matches.map { $0.value }
        case "edition":
            result.edition = matches.map { $0.value }
        case "other":
            result.other = matches.map { $0.value }
        case "episodeDetails":
            result.episodeDetails = matches.map { $0.value }
        case "bonus":
            result.bonus = Int(matches.first?.value ?? "")
        case "bonusTitle":
            result.bonusTitle = matches.first?.value
        case "film":
            result.film = Int(matches.first?.value ?? "")
        case "filmTitle":
            result.filmTitle = matches.first?.value
        case "cd":
            result.cd = Int(matches.first?.value ?? "")
        case "cdCount":
            result.cdCount = Int(matches.first?.value ?? "")
        case "disc":
            result.disc = Int(matches.first?.value ?? "")
        case "discCount":
            result.discCount = Int(matches.first?.value ?? "")
        case "size":
            result.size = matches.first?.value
        case "bitRate":
            result.bitRate = matches.first?.value
        case "crc32":
            result.crc32 = matches.first?.value
        case "uuid":
            result.uuid = matches.first?.value
        case "properCount":
            result.properCount = Int(matches.first?.value ?? "")
        case "date":
            if let dateString = matches.first?.value {
                result.date = parseDate(dateString)
            }
        default:
            // Unknown property - could log or handle differently
            break
        }
    }
    
    private func calculateOverallConfidence(_ matches: [RuleMatch]) -> Double {
        guard !matches.isEmpty else { return 0.0 }
        
        let totalConfidence = matches.reduce(0.0) { $0 + $1.confidence }
        return totalConfidence / Double(matches.count)
    }
    
    private func inferMediaType(_ result: MatchResult) -> MediaType {
        if result.season != nil || result.episode != nil {
            return .episode
        } else if result.year != nil {
            return .movie
        } else {
            return .unknown
        }
    }
    
    private func getMimeType(for container: String?) -> String? {
        guard let container = container?.lowercased() else { return nil }
        
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
            "vob": "video/dvd"
        ]
        
        return mimeTypes[container]
    }
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatters = [
            "yyyy-MM-dd",
            "yyyy/MM/dd",
            "dd-MM-yyyy",
            "dd/MM/yyyy",
            "MM-dd-yyyy",
            "MM/dd/yyyy",
            "yyyyMMdd"
        ]
        
        for formatString in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = formatString
            
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        
        return nil
    }
    
    // MARK: - Default Rules
    
    private static func createDefaultRules() -> [Rule] {
        return [
            EpisodeRule(),
            EpisodeTitleRule(),
            YearRule(),
            VideoCodecRule(),
            ScreenSizeRule(),
            SourceRule(),
            ReleaseGroupRule(),
            ContainerRule(),
            TitleRule(),
            // Add other rules here as they are implemented
        ]
    }
}

// MARK: - Rule Registration
extension RuleEngine {
    
    /// Adds a custom rule to the engine
    public func addRule(_ rule: Rule) {
        // Note: In a mutable implementation, you'd add the rule to a mutable array
        // For now, this is a placeholder for the concept
    }
    
    /// Removes a rule by name
    public func removeRule(named name: String) {
        // Note: In a mutable implementation, you'd remove the rule from the array
        // For now, this is a placeholder for the concept
    }
    
    /// Returns all registered rules
    public func getAllRules() -> [Rule] {
        return rules
    }
    
    /// Returns rules that match the given property
    public func getRules(for property: String) -> [Rule] {
        return rules.filter { $0.properties.contains(property) }
    }
} 