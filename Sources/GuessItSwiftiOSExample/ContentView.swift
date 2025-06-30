import SwiftUI
import GuessItSwift

struct ContentView: View {
    @State private var filename = "The.Dark.Knight.2008.1080p.BluRay.x264-GROUP.mkv"
    @State private var result: MatchResult?
    @State private var errorMessage: String?
    
    let sampleFilenames = [
        "The.Dark.Knight.2008.1080p.BluRay.x264-GROUP.mkv",
        "Game.of.Thrones.S01E01.Winter.Is.Coming.720p.HDTV.x264-CTU.mkv",
        "Breaking.Bad.S02E05.Breakage.720p.mkv",
        "Avengers.Endgame.2019.2160p.UHD.BluRay.x265-GROUP.mkv",
        "The.Matrix.1999.1080p.BluRay.x264-GROUP.mkv"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Input Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("输入文件名:")
                        .font(.headline)
                    
                    TextField("文件名", text: $filename)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("解析") {
                        parseFilename()
                    }
                    .buttonStyle(CompatibleBorderedButtonStyle())
                    .disabled(filename.isEmpty)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Sample Files
                VStack(alignment: .leading, spacing: 10) {
                    Text("示例文件:")
                        .font(.headline)
                    
                    ScrollView {
                        VStack(spacing: 5) {
                            ForEach(sampleFilenames, id: \.self) { sample in
                                Button(action: {
                                    filename = sample
                                    parseFilename()
                                }) {
                                    HStack {
                                        Text(sample)
                                            .font(.caption)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(5)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Results Section
                if let error = errorMessage {
                    VStack {
                        Text("错误:")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text(error)
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                } else if let result = result {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("解析结果:")
                                .font(.headline)
                            
                            ResultRow(label: "标题", value: result.title)
                            ResultRow(label: "年份", value: result.year?.description)
                            ResultRow(label: "季", value: result.season?.description)
                            ResultRow(label: "集", value: result.episode?.description)
                            ResultRow(label: "视频编码", value: result.videoCodec)
                            ResultRow(label: "容器", value: result.container)
                            ResultRow(label: "类型", value: result.type?.rawValue)
                            ResultRow(label: "置信度", value: String(format: "%.2f", result.confidence))
                            
                            if result.isMovie {
                                HStack {
                                    if #available(iOS 14.0, macOS 11.0, *) {
                                        Label("电影", systemImage: "film")
                                            .foregroundColor(.blue)
                                    } else {
                                        Text("🎬 电影")
                                            .foregroundColor(.blue)
                                    }
                                }
                            } else if result.isEpisode {
                                HStack {
                                    if #available(iOS 14.0, macOS 11.0, *) {
                                        Label("电视剧", systemImage: "tv")
                                            .foregroundColor(.green)
                                    } else {
                                        Text("📺 电视剧")
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .modifier(NavigationTitleModifier())
        }
        .onAppear {
            parseFilename()
        }
    }
    
    private func parseFilename() {
        errorMessage = nil
        result = nil
        
        let parseResult = guessit(filename)
        
        switch parseResult {
        case .success(let matchResult):
            result = matchResult
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}

struct ResultRow: View {
    let label: String
    let value: String?
    
    var body: some View {
        HStack {
            Text("\(label):")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)
            
            Text(value ?? "N/A")
                .font(.caption)
                .foregroundColor(value != nil ? .primary : .secondary)
            
            Spacer()
        }
    }
}

// 兼容的导航标题修饰符
struct NavigationTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 14.0, *) {
            content.navigationTitle("GuessItSwift Demo")
        } else {
            content.navigationBarTitle("GuessItSwift Demo", displayMode: .inline)
        }
        #else
        if #available(macOS 11.0, *) {
            content.navigationTitle("GuessItSwift Demo")
        } else {
            content
        }
        #endif
    }
}

// 兼容的按钮样式
struct CompatibleBorderedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 