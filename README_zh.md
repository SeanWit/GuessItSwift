# GuessItSwift

**语言**: [English](README.md) | [中文](README_zh.md)

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS 13.0+](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)
[![macOS 10.15+](https://img.shields.io/badge/macOS-10.15+-blue.svg)](https://developer.apple.com/macos/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

GuessItSwift 是一个强大的 Swift 库，用于从媒体文件名中提取信息。它可以解析电影和电视剧文件名，提取标题、年份、季/集数、视频/音频编解码器、分辨率、来源等详细信息。

这个库是流行的 Python [GuessIt](https://github.com/guessit-io/guessit) 库的 Swift 重新实现，专为 iOS、macOS、tvOS 和 watchOS 应用程序设计。

## 🙏 致谢

本项目受到优秀的 **[GuessIt](https://github.com/guessit-io/guessit)** Python 库的启发和基础支持，该库由 GuessIt 团队创建。我们向原始 GuessIt 项目的所有贡献者表示衷心的感谢，感谢他们在创建如此全面和强大的媒体文件名解析解决方案方面的杰出工作。没有他们的基础，这个 Swift 实现就不可能实现。

特别感谢：
- GuessIt 团队和所有贡献者
- 开源社区的持续支持
- 所有帮助测试和改进这个 Swift 实现的人

## 功能特性

- 🎬 **电影和电视剧支持**：解析电影和剧集文件名
- 🔍 **全面检测**：从文件名中提取 30+ 种不同属性
- ⚡ **高性能**：优化的 Swift 实现，支持正则表达式缓存
- 🛡️ **类型安全**：完整的 Swift 类型安全，支持 Result 类型和错误处理
- 🔧 **可配置**：可自定义规则和配置选项
- 📱 **iOS 优化**：专为移动和桌面 Apple 平台设计
- 🧪 **充分测试**：全面的测试套件，代码覆盖率达 95%+
- 🔄 **跨平台**：支持 iOS 13.0+、macOS 10.15+、tvOS 13.0+、watchOS 6.0+

## 支持的属性

GuessItSwift 可以从文件名中检测以下信息：

### 基本信息
- 标题、备用标题、年份、媒体类型（电影/剧集）

### 剧集信息
- 季数、集数、集标题、集数统计、季数统计
- 绝对集数、集详情、部分、版本

### 技术信息
- 视频编解码器、音频编解码器、音频声道、音频/视频配置文件
- 屏幕尺寸、容器格式、MIME 类型

### 来源信息
- 来源（蓝光、DVD、HDTV 等）、发布组、网站、流媒体服务

### 语言和地区
- 语言、字幕语言、国家

### 版本和质量
- 版本（导演剪辑版、加长版等）、其他标签、花絮内容

### 附加信息
- 日期、文件大小、比特率、CRC32、UUID、Proper 计数

## 安装

### Swift Package Manager

使用 Xcode 将 GuessItSwift 添加到您的项目：

1. 文件 → 添加包依赖
2. 输入仓库 URL：`https://github.com/SeanWit/GuessItSwift`
3. 点击添加包

或者添加到您的 `Package.swift`：

```swift
dependencies: [
    .package(url: "https://github.com/SeanWit/GuessItSwift", from: "1.0.0")
]
```

## 快速开始

### 基本用法

```swift
import GuessItSwift

// 简单解析
let filename = "The.Dark.Knight.2008.1080p.BluRay.x264-GROUP.mkv"
let result = try parse(filename)

print(result.title)      // "The Dark Knight"
print(result.year)       // 2008
print(result.screenSize) // "1080p"
print(result.source)     // "Blu-ray"
print(result.videoCodec) // "H.264"
```

### 使用 Result 类型

```swift
let filename = "Game.of.Thrones.S01E01.Winter.Is.Coming.720p.HDTV.x264-CTU.mkv"

switch guessit(filename) {
case .success(let result):
    print("标题: \(result.title ?? "未知")")
    print("季数: \(result.season ?? 0), 集数: \(result.episode ?? 0)")
    print("集标题: \(result.episodeTitle ?? "未知")")
case .failure(let error):
    print("解析失败: \(error.localizedDescription)")
}
```

### 字符串扩展

```swift
let filename = "Avengers.Endgame.2019.2160p.UHD.BluRay.x265-GROUP.mkv"

// 检查是否为有效的媒体文件名
if filename.isValidMediaFilename {
    print("标题: \(filename.mediaTitle ?? "未知")")
    print("年份: \(filename.mediaYear ?? 0)")
    print("编解码器: \(filename.mediaVideoCodec ?? "未知")")
}

// 使用扩展解析
let result = try filename.parseAsMedia()
print(result.description)
```

### 批量处理

```swift
let filenames = [
    "Movie1.2020.1080p.BluRay.x264.mkv",
    "Movie2.2021.720p.WEB-DL.h265.mp4",
    "Show.S01E01.Episode.Title.HDTV.x264.avi"
]

// 处理所有文件
let results = guessBatch(filenames)

// 只获取成功的结果
let successful = filenames.guessitSuccessful()
print("成功解析了 \(successful.count) 个文件")
```

## 高级用法

### 自定义配置

```swift
// 创建自定义配置
var config = RuleConfiguration()
config.videoCodecs.codecs["AV1"] = ["AV1", "av01"]

// 使用自定义配置
let engine = GuessItEngine(configuration: config)
let result = try engine.parse(filename)
```

### 解析选项

```swift
var options = ParseOptions()
options.type = .episode  // 提示这是一个剧集
options.allowedLanguages = ["en", "fr", "es"]
options.excludes = ["website", "crc32"]  // 不检测这些

let result = try parse(filename, options: options)
```

### 分析和调试

```swift
let filename = "Complex.Movie.Title.2020.1080p.BluRay.DTS-HD.MA.7.1.x264-GROUP.mkv"

switch GuessItSwift.shared.analyze(filename) {
case .success(let analysis):
    print("摘要: \(analysis.summary)")
    print("置信度: \(analysis.confidence)")
    print("处理时间: \(analysis.processingTime)s")
    print("检测到的属性: \(analysis.detectedProperties)")
    print("高质量: \(analysis.isHighQuality)")
case .failure(let error):
    print("分析失败: \(error)")
}
```

### 自定义规则

```swift
// 创建自定义规则
struct CustomRule: RegexRule {
    let name = "CustomRule"
    let priority = RulePriority.normal
    let properties = ["customProperty"]
    
    var patterns: [RegexPattern] {
        return [
            RegexPattern(
                pattern: #"\bCUSTOM\b"#,
                property: "customProperty",
                confidence: 0.9
            )
        ]
    }
}

// 与自定义引擎一起使用
let customRules: [Rule] = [CustomRule(), YearRule(), VideoCodecRule()]
let engine = GuessItEngine(configuration: .default, customRules: customRules)
```

## 示例

### 电影示例

```swift
// 基本电影
"The.Matrix.1999.1080p.BluRay.x264-GROUP.mkv"
// → 标题: "The Matrix", 年份: 1999, 来源: "Blu-ray", 编解码器: "H.264"

// 带版本的电影
"Blade.Runner.1982.Directors.Cut.2160p.UHD.BluRay.x265-GROUP.mkv"  
// → 标题: "Blade Runner", 年份: 1982, 版本: ["Director's Cut"], 编解码器: "H.265"

// 外国电影
"Parasite.2019.Korean.1080p.BluRay.x264-GROUP.mkv"
// → 标题: "Parasite", 年份: 2019, 语言: ["Korean"]
```

### 电视剧示例

```swift
// 标准剧集
"Breaking.Bad.S05E14.Ozymandias.1080p.WEB-DL.x264-GROUP.mkv"
// → 标题: "Breaking Bad", 季数: 5, 集数: 14, 集标题: "Ozymandias"

// 多集
"Friends.S01E01-E02.The.Pilot.720p.BluRay.x264-GROUP.mkv"
// → 季数: 1, 集数: [1, 2]

// 动漫
"Attack.on.Titan.S04E16.Above.and.Below.1080p.WEB.x264-GROUP.mkv"
// → 标题: "Attack on Titan", 季数: 4, 集数: 16
```

## iOS 示例应用

项目包含一个全面的 iOS 示例应用程序，演示如何在真实的 iOS 应用中使用 GuessItSwift。

### 功能特性
- 🎬 **实时解析**：输入时实时解析文件名
- 📱 **原生 iOS 界面**：使用 SwiftUI 构建
- 📝 **示例文件名**：预加载示例供快速测试
- 🔄 **跨平台**：在 iOS 和 macOS 上运行
- 🎯 **版本兼容性**：支持 iOS 13.0+ 并优雅降级

### 运行示例

```bash
# 克隆仓库
git clone https://github.com/SeanWit/GuessItSwift.git
cd GuessItSwift

# 运行 iOS 示例（作为 macOS 桌面应用）
swift run GuessItSwiftiOSExample

# 或在 Xcode 中打开
open Package.swift
# 选择 GuessItSwiftiOSExample scheme 并运行
```

### 示例应用截图

iOS 示例应用提供：
- 文件名输入字段
- 实时解析结果
- 快速测试的示例文件名
- 带置信度分数的详细属性显示
- 电影/电视剧类型指示器（🎬/📺）

## 平台兼容性

### 支持的版本
- **iOS 13.0+** ✅
- **macOS 10.15+** ✅
- **tvOS 13.0+** ✅
- **watchOS 6.0+** ✅

### 兼容性功能
- **优雅降级**：自动适应可用的 API
- **版本检查**：为每个平台版本使用适当的 API
- **自定义组件**：为旧版本提供后备 UI 组件
- **跨平台**：单一代码库适用于所有 Apple 平台

### 兼容性策略

#### 1. 渐进增强
```swift
if #available(iOS 14.0, macOS 11.0, *) {
    // 使用现代 API
    Label("电影", systemImage: "film")
} else {
    // 旧版本的后备方案
    Text("🎬 电影")
}
```

#### 2. 自定义组件
```swift
struct CompatibleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}
```

#### 3. 条件编译
```swift
#if os(iOS)
    // iOS 特定代码
#elseif os(macOS)
    // macOS 特定代码
#endif
```

## 性能

GuessItSwift 针对性能进行了优化：

- **正则表达式缓存**：编译的正则表达式模式被缓存以供重用
- **延迟评估**：仅在需要时应用规则
- **内存高效**：使用值类型和写时复制语义
- **并发安全**：批量处理的线程安全操作

iPhone 12 Pro 上的典型性能：
- 简单文件名：~0.5ms
- 复杂文件名：~2-3ms  
- 100 个文件的批处理：~100-200ms

## 错误处理

GuessItSwift 使用 Swift 的 Result 类型进行全面的错误处理：

```swift
enum GuessItError: Error {
    case invalidInput(String)
    case parsingFailed(String)
    case configurationError(String)
    case ruleError(String, rule: String)
    case patternError(String, pattern: String)
    case processingError(String)
}
```

每个错误都提供了关于出错原因的详细信息和恢复建议。

## 测试

运行测试套件：

```bash
swift test
```

该库包含全面的测试，涵盖：
- 所有规则和组件的单元测试
- 真实文件名的集成测试
- 性能测试
- 错误条件测试
- 边缘情况处理
- 跨平台兼容性测试

## 贡献

欢迎贡献！请随时提交 Pull Request。对于重大更改，请先打开 issue 讨论您想要更改的内容。

### 开发设置

1. 克隆仓库
2. 在 Xcode 中打开 `Package.swift`
3. 进行更改
4. 运行测试以确保一切正常
5. 提交 pull request

### 代码风格
- 遵循 Swift API 设计指南
- 使用有意义的变量和函数名
- 为新功能添加全面的测试
- 更新公共 API 的文档

## 许可证

GuessItSwift 在 MIT 许可证下提供。有关更多信息，请参阅 [LICENSE](LICENSE) 文件。

## 致谢和鸣谢

### 原始项目
此 Swift 实现基于 **[GuessIt](https://github.com/guessit-io/guessit)** Python 库：
- **仓库**：https://github.com/guessit-io/guessit
- **许可证**：LGPLv3
- **作者**：GuessIt 团队和贡献者

我们深深感谢原始 GuessIt 团队：
- 创建了全面的基于规则的解析系统
- 建立了媒体文件名分析的模式和逻辑
- 提供了广泛的测试用例和示例
- 维护了一个惠及整个社区的开源项目

### Swift 实现
- **作者**：SeanWit
- **许可证**：MIT（用于此 Swift 实现）
- **语言**：Swift 5.9+
- **平台**：iOS、macOS、tvOS、watchOS

### 与原版的主要区别
在保持原始 GuessIt 的核心功能和理念的同时：
- **原生 Swift**：为 Apple 平台从头构建
- **类型安全**：利用 Swift 的强类型系统
- **Result 类型**：使用 Swift 的 Result 类型进行错误处理
- **值类型**：强调 Swift 的值语义
- **SwiftUI 就绪**：为现代 iOS 开发而设计

## 支持

- 📖 [文档](https://github.com/SeanWit/GuessItSwift)
- 🐛 [问题跟踪器](https://github.com/SeanWit/GuessItSwift/issues)
- 💬 [讨论](https://github.com/SeanWit/GuessItSwift/discussions)
- 🔗 [原始 GuessIt 项目](https://github.com/guessit-io/guessit)

## 路线图

- [ ] 添加更多流媒体服务检测
- [ ] 改进动漫文件名解析
- [ ] 添加字幕格式检测
- [ ] 增强 HDR/杜比视界检测
- [ ] 添加 watchOS 特定优化
- [ ] 批量处理性能改进

---

用 ❤️ 为 Swift 社区制作，灵感来自令人惊叹的 GuessIt 项目 