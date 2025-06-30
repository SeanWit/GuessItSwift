import Foundation

/// Represents the result of parsing a filename
public struct MatchResult: Codable, Equatable {
    // MARK: - Basic Information
    public var title: String?
    public var alternativeTitle: String?
    public var year: Int?
    public var type: MediaType?
    
    // MARK: - Episode Information
    public var season: Int?
    public var episode: Int?
    public var episodeTitle: String?
    public var episodeCount: Int?
    public var seasonCount: Int?
    public var absoluteEpisode: Int?
    public var episodeDetails: [String]?
    public var part: Int?
    public var version: Int?
    
    // MARK: - Technical Information
    public var videoCodec: String?
    public var audioCodec: String?
    public var audioChannels: String?
    public var audioProfile: String?
    public var videoProfile: String?
    public var screenSize: String?
    public var container: String?
    public var mimetype: String?
    
    // MARK: - Source Information
    public var source: String?
    public var releaseGroup: String?
    public var website: String?
    public var streaming: String?
    
    // MARK: - Language and Region
    public var language: [String]?
    public var subtitleLanguage: [String]?
    public var country: [String]?
    
    // MARK: - Edition and Quality
    public var edition: [String]?
    public var other: [String]?
    public var bonus: Int?
    public var bonusTitle: String?
    public var film: Int?
    public var filmTitle: String?
    
    // MARK: - Disc Information
    public var cd: Int?
    public var cdCount: Int?
    public var disc: Int?
    public var discCount: Int?
    
    // MARK: - Additional Information
    public var date: Date?
    public var size: String?
    public var bitRate: String?
    public var crc32: String?
    public var uuid: String?
    public var properCount: Int?
    
    // MARK: - Metadata
    public var inputString: String?
    public var confidence: Double = 0.0
    public var processingTime: TimeInterval = 0.0
    
    public init() {}
    
    // MARK: - Convenience Methods
    
    /// Returns true if this appears to be a movie
    public var isMovie: Bool {
        return type == .movie || (season == nil && episode == nil && year != nil)
    }
    
    /// Returns true if this appears to be a TV episode
    public var isEpisode: Bool {
        return type == .episode || season != nil || episode != nil
    }
    
    /// Returns a formatted string representation of season and episode
    public var seasonEpisodeString: String? {
        guard let season = season else { return nil }
        if let episode = episode {
            return String(format: "S%02dE%02d", season, episode)
        }
        return String(format: "S%02d", season)
    }
    
    /// Returns a dictionary representation for JSON serialization
    public func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            guard let key = child.label else { continue }
            
            if let value = child.value as? String {
                dict[key] = value
            } else if let value = child.value as? Int {
                dict[key] = value
            } else if let value = child.value as? Double {
                dict[key] = value
            } else if let value = child.value as? [String] {
                dict[key] = value
            } else if let value = child.value as? Date {
                dict[key] = ISO8601DateFormatter().string(from: value)
            } else if let value = child.value as? MediaType {
                dict[key] = value.rawValue
            } else if let value = child.value as? TimeInterval {
                dict[key] = value
            }
        }
        
        return dict
    }
}

/// Media type enumeration
public enum MediaType: String, Codable, CaseIterable {
    case movie = "movie"
    case episode = "episode"
    case unknown = "unknown"
}

// MARK: - CustomStringConvertible
extension MatchResult: CustomStringConvertible {
    public var description: String {
        var components: [String] = []
        
        if let title = title {
            components.append("Title: \(title)")
        }
        
        if let year = year {
            components.append("Year: \(year)")
        }
        
        if let seasonEpisode = seasonEpisodeString {
            components.append("Episode: \(seasonEpisode)")
        }
        
        if let videoCodec = videoCodec {
            components.append("Video: \(videoCodec)")
        }
        
        if let audioCodec = audioCodec {
            components.append("Audio: \(audioCodec)")
        }
        
        if let source = source {
            components.append("Source: \(source)")
        }
        
        return components.joined(separator: ", ")
    }
}

// MARK: - Merge functionality
extension MatchResult {
    /// Merges another MatchResult into this one, with the other result taking precedence for non-nil values
    public mutating func merge(with other: MatchResult) {
        title = other.title ?? title
        alternativeTitle = other.alternativeTitle ?? alternativeTitle
        year = other.year ?? year
        type = other.type ?? type
        
        season = other.season ?? season
        episode = other.episode ?? episode
        episodeTitle = other.episodeTitle ?? episodeTitle
        episodeCount = other.episodeCount ?? episodeCount
        seasonCount = other.seasonCount ?? seasonCount
        absoluteEpisode = other.absoluteEpisode ?? absoluteEpisode
        episodeDetails = other.episodeDetails ?? episodeDetails
        part = other.part ?? part
        version = other.version ?? version
        
        videoCodec = other.videoCodec ?? videoCodec
        audioCodec = other.audioCodec ?? audioCodec
        audioChannels = other.audioChannels ?? audioChannels
        audioProfile = other.audioProfile ?? audioProfile
        videoProfile = other.videoProfile ?? videoProfile
        screenSize = other.screenSize ?? screenSize
        container = other.container ?? container
        mimetype = other.mimetype ?? mimetype
        
        source = other.source ?? source
        releaseGroup = other.releaseGroup ?? releaseGroup
        website = other.website ?? website
        streaming = other.streaming ?? streaming
        
        language = other.language ?? language
        subtitleLanguage = other.subtitleLanguage ?? subtitleLanguage
        country = other.country ?? country
        
        edition = other.edition ?? edition
        self.other = other.other ?? self.other
        bonus = other.bonus ?? bonus
        bonusTitle = other.bonusTitle ?? bonusTitle
        film = other.film ?? film
        filmTitle = other.filmTitle ?? filmTitle
        
        cd = other.cd ?? cd
        cdCount = other.cdCount ?? cdCount
        disc = other.disc ?? disc
        discCount = other.discCount ?? discCount
        
        date = other.date ?? date
        size = other.size ?? size
        bitRate = other.bitRate ?? bitRate
        crc32 = other.crc32 ?? crc32
        uuid = other.uuid ?? uuid
        properCount = other.properCount ?? properCount
        
        inputString = other.inputString ?? inputString
        confidence = max(confidence, other.confidence)
        processingTime += other.processingTime
    }
} 