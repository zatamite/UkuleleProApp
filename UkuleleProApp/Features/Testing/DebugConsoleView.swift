import SwiftUI

struct DebugConsoleView: View {
    @ObservedObject var logger = LogManager.shared
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header / Toggle
            HStack {
                Text("DEBUG CONSOLE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isExpanded {
                    Button(action: { logger.clear() }) {
                        Image(systemName: "trash")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .padding(.trailing, 10)
                }
                
                Button(action: { withAnimation { isExpanded.toggle() } }) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .foregroundColor(.white)
                }
            }
            .padding(8)
            .background(Color.black.opacity(0.8))
            
            // Log List
            if isExpanded {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(logger.logs) { log in
                                HStack(alignment: .top) {
                                    Text(dateFormatter.string(from: log.timestamp))
                                        .font(.system(size: 8, design: .monospaced))
                                        .foregroundColor(.gray)
                                    
                                    Text("[\(log.source)]")
                                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                                        .foregroundColor(.yellow)
                                        .frame(width: 60, alignment: .leading)
                                    
                                    Text(log.message)
                                        .font(.system(size: 9, design: .monospaced))
                                        .foregroundColor(colorForLevel(log.level))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .id(log.id)
                            }
                        }
                        .padding(8)
                    }
                    .frame(height: 200)
                    .background(Color.black.opacity(0.9))
                    .onChange(of: logger.logs.count) { _, _ in
                        if let last = logger.logs.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        .cornerRadius(8)
        .padding(.horizontal)
    }
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.S"
        return f
    }()
    
    private func colorForLevel(_ level: LogManager.LogLevel) -> Color {
        switch level {
        case .info: return .white
        case .warning: return .orange
        case .error: return .red
        case .debug: return .gray
        }
    }
}
