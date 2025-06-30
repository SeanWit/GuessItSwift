import Foundation

/// Configuration for parsing rules
public struct RuleConfiguration: Codable {
    
    // MARK: - Basic Configuration
    public var commonWords: [String]
    public var separators: [String]
    public var groupMarkers: GroupMarkers
    
    // MARK: - Property Configurations
    public var videoCodecs: VideoCodecConfiguration
    public var audioCodecs: AudioCodecConfiguration
    public var sources: SourceConfiguration
    public var languages: LanguageConfiguration
    public var countries: CountryConfiguration
    public var editions: EditionConfiguration
    public var containers: ContainerConfiguration
    public var screenSizes: ScreenSizeConfiguration
    public var episodes: EpisodeConfiguration
    
    public init() {
        self.commonWords = Self.defaultCommonWords
        self.separators = Self.defaultSeparators
        self.groupMarkers = GroupMarkers()
        self.videoCodecs = VideoCodecConfiguration()
        self.audioCodecs = AudioCodecConfiguration()
        self.sources = SourceConfiguration()
        self.languages = LanguageConfiguration()
        self.countries = CountryConfiguration()
        self.editions = EditionConfiguration()
        self.containers = ContainerConfiguration()
        self.screenSizes = ScreenSizeConfiguration()
        self.episodes = EpisodeConfiguration()
    }
    
    /// Default configuration
    public static let `default` = RuleConfiguration()
    
    // MARK: - Default Values
    
    private static let defaultCommonWords = [
        "ca", "cat", "de", "he", "it", "no", "por", "rum", "se", "st", "sub"
    ]
    
    private static let defaultSeparators = [
        ".", "_", "-", "+", "(", ")", "[", "]", "{", "}", " ", "/", "\\"
    ]
}

// MARK: - Group Markers Configuration
public struct GroupMarkers: Codable {
    public var starting: [String]
    public var ending: [String]
    
    public init() {
        self.starting = ["(", "[", "{"]
        self.ending = [")", "]", "}"]
    }
}

// MARK: - Video Codec Configuration
public struct VideoCodecConfiguration: Codable {
    public var codecs: [String: [String]]
    
    public init() {
        self.codecs = [
            "H.264": ["H.264", "H264", "x264", "AVC"],
            "H.265": ["H.265", "H265", "x265", "HEVC"],
            "XviD": ["XviD"],
            "DivX": ["DivX"],
            "VP9": ["VP9"],
            "AV1": ["AV1"],
            "MPEG-2": ["MPEG-2", "MPEG2"]
        ]
    }
}

// MARK: - Audio Codec Configuration
public struct AudioCodecConfiguration: Codable {
    public var codecs: [String: [String]]
    public var channels: [String: [String]]
    public var profiles: [String: [String]]
    
    public init() {
        self.codecs = [
            "AAC": ["AAC"],
            "AC3": ["AC3", "AC-3", "Dolby Digital"],
            "DTS": ["DTS"],
            "DTS-HD": ["DTS-HD", "DTS-MA"],
            "TrueHD": ["TrueHD", "True-HD"],
            "Atmos": ["Atmos"],
            "FLAC": ["FLAC"],
            "MP3": ["MP3"],
            "Opus": ["Opus"],
            "Vorbis": ["Vorbis"],
            "PCM": ["PCM"],
            "LPCM": ["LPCM"]
        ]
        
        self.channels = [
            "1.0": ["1.0", "1ch", "mono"],
            "2.0": ["2.0", "2ch", "stereo"],
            "5.1": ["5.1", "5ch", "6ch"],
            "7.1": ["7.1", "7ch", "8ch"]
        ]
        
        self.profiles = [
            "High": ["High", "Hi"],
            "Main": ["Main"],
            "Baseline": ["Baseline"],
            "Extended": ["Extended", "Ext"],
            "High Efficiency": ["HE"],
            "Low Complexity": ["LC"]
        ]
    }
}

// MARK: - Source Configuration
public struct SourceConfiguration: Codable {
    public var sources: [String: [String]]
    
    public init() {
        self.sources = [
            "Blu-ray": ["BluRay", "Blu-Ray", "BDRip", "BRRip"],
            "DVD": ["DVD", "DVDRip"],
            "HDTV": ["HDTV"],
            "WEB-DL": ["WEB-DL", "WEBDL"],
            "WEBRip": ["WEBRip", "WEB-Rip"],
            "CAM": ["CAM"],
            "TS": ["TS", "TELESYNC"],
            "TC": ["TC", "TELECINE"],
            "VHS": ["VHS"],
            "HD-DVD": ["HD-DVD", "HDDVD"]
        ]
    }
}

// MARK: - Language Configuration
public struct LanguageConfiguration: Codable {
    public var languages: [String: [String]]
    public var subtitlePrefixes: [String]
    public var subtitleSuffixes: [String]
    
    public init() {
        self.languages = [
            "English": ["english", "en", "eng"],
            "French": ["french", "fr", "fra", "français"],
            "Spanish": ["spanish", "es", "spa", "español"],
            "German": ["german", "de", "deu", "deutsch"],
            "Italian": ["italian", "it", "ita", "italiano"],
            "Japanese": ["japanese", "ja", "jpn", "jp"],
            "Korean": ["korean", "ko", "kor"],
            "Chinese": ["chinese", "zh", "zho", "cn"],
            "Russian": ["russian", "ru", "rus"],
            "Portuguese": ["portuguese", "pt", "por"],
            "Dutch": ["dutch", "nl", "nld"],
            "Swedish": ["swedish", "sv", "swe"],
            "Norwegian": ["norwegian", "no", "nor"],
            "Danish": ["danish", "da", "dan"],
            "Finnish": ["finnish", "fi", "fin"]
        ]
        
        self.subtitlePrefixes = ["sub", "subs", "subtitle", "subtitles"]
        self.subtitleSuffixes = ["subbed", "subs"]
    }
}

// MARK: - Country Configuration
public struct CountryConfiguration: Codable {
    public var countries: [String: [String]]
    
    public init() {
        self.countries = [
            "US": ["US", "USA", "American"],
            "UK": ["UK", "GB", "British"],
            "FR": ["FR", "France", "French"],
            "DE": ["DE", "Germany", "German"],
            "IT": ["IT", "Italy", "Italian"],
            "ES": ["ES", "Spain", "Spanish"],
            "JP": ["JP", "Japan", "Japanese"],
            "KR": ["KR", "Korea", "Korean"],
            "CN": ["CN", "China", "Chinese"],
            "RU": ["RU", "Russia", "Russian"],
            "CA": ["CA", "Canada", "Canadian"],
            "AU": ["AU", "Australia", "Australian"]
        ]
    }
}

// MARK: - Edition Configuration
public struct EditionConfiguration: Codable {
    public var editions: [String: [String]]
    
    public init() {
        self.editions = [
            "Director's Cut": ["Director's Cut", "Directors Cut", "DC"],
            "Extended": ["Extended", "Extended Cut"],
            "Unrated": ["Unrated"],
            "Theatrical": ["Theatrical", "Theatrical Cut"],
            "IMAX": ["IMAX"],
            "Remastered": ["Remastered"],
            "Criterion": ["Criterion"],
            "Special": ["Special", "Special Edition"],
            "Collector": ["Collector", "Collector's Edition"],
            "Limited": ["Limited", "Limited Edition"],
            "Ultimate": ["Ultimate", "Ultimate Edition"],
            "Deluxe": ["Deluxe", "Deluxe Edition"]
        ]
    }
}

// MARK: - Container Configuration
public struct ContainerConfiguration: Codable {
    public var videoContainers: [String]
    public var audioContainers: [String]
    public var subtitleContainers: [String]
    
    public init() {
        self.videoContainers = [
            "mkv", "mp4", "avi", "mov", "wmv", "flv", "webm", "m4v",
            "3gp", "ts", "m2ts", "vob", "iso", "divx", "ogm", "ogv"
        ]
        
        self.audioContainers = [
            "mp3", "flac", "aac", "ogg", "wav", "wma", "m4a"
        ]
        
        self.subtitleContainers = [
            "srt", "ass", "ssa", "sub", "idx", "vtt"
        ]
    }
}

// MARK: - Screen Size Configuration
public struct ScreenSizeConfiguration: Codable {
    public var resolutions: [String: [String]]
    
    public init() {
        self.resolutions = [
            "480p": ["480p", "480i"],
            "720p": ["720p", "720i", "HD"],
            "1080p": ["1080p", "1080i", "Full HD", "FHD"],
            "1440p": ["1440p", "2K"],
            "2160p": ["2160p", "4K", "UHD", "Ultra HD"],
            "4320p": ["4320p", "8K"]
        ]
    }
}

// MARK: - Episode Configuration
public struct EpisodeConfiguration: Codable {
    public var seasonWords: [String]
    public var episodeWords: [String]
    public var seasonMarkers: [String]
    public var episodeMarkers: [String]
    public var rangeSeparators: [String]
    public var discreteSeparators: [String]
    public var ofWords: [String]
    public var allWords: [String]
    public var maxSeasonRange: Int
    public var maxEpisodeRange: Int
    
    public init() {
        self.seasonWords = ["season", "saison", "seizoen", "seasons", "saisons", "temporada", "temporadas", "stagione"]
        self.episodeWords = ["episode", "episodes", "eps", "ep", "episodio", "episodios", "capitulo", "capitulos"]
        self.seasonMarkers = ["s"]
        self.episodeMarkers = ["e", "ep", "x"]
        self.rangeSeparators = ["-", "~", "to", "a"]
        self.discreteSeparators = ["+", "&", "and", "et"]
        self.ofWords = ["of", "sur"]
        self.allWords = ["all"]
        self.maxSeasonRange = 100
        self.maxEpisodeRange = 100
    }
}

// MARK: - Configuration Loading
extension RuleConfiguration {
    
    /// Loads configuration from a JSON file
    public static func load(from url: URL) throws -> RuleConfiguration {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(RuleConfiguration.self, from: data)
    }
    
    /// Loads configuration from JSON data
    public static func load(from data: Data) throws -> RuleConfiguration {
        let decoder = JSONDecoder()
        return try decoder.decode(RuleConfiguration.self, from: data)
    }
    
    /// Saves configuration to a JSON file
    public func save(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(self)
        try data.write(to: url)
    }
    
    /// Merges this configuration with another, with the other taking precedence
    public func merged(with other: RuleConfiguration) -> RuleConfiguration {
        var merged = self
        
        // Merge arrays by combining and removing duplicates
        merged.commonWords = Array(Set(self.commonWords + other.commonWords)).sorted()
        merged.separators = Array(Set(self.separators + other.separators)).sorted()
        
        // Merge dictionaries by combining values
        merged.videoCodecs.codecs = self.videoCodecs.codecs.merging(other.videoCodecs.codecs) { _, new in new }
        merged.audioCodecs.codecs = self.audioCodecs.codecs.merging(other.audioCodecs.codecs) { _, new in new }
        merged.sources.sources = self.sources.sources.merging(other.sources.sources) { _, new in new }
        merged.languages.languages = self.languages.languages.merging(other.languages.languages) { _, new in new }
        merged.countries.countries = self.countries.countries.merging(other.countries.countries) { _, new in new }
        merged.editions.editions = self.editions.editions.merging(other.editions.editions) { _, new in new }
        merged.screenSizes.resolutions = self.screenSizes.resolutions.merging(other.screenSizes.resolutions) { _, new in new }
        
        return merged
    }
} 