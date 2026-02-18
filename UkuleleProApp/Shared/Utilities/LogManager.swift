import Foundation
import Combine

class LogManager: ObservableObject {
    static let shared = LogManager()
    
    struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp = Date()
        let source: String
        let message: String
        let level: LogLevel
    }
    
    enum LogLevel {
        case info, warning, error, debug
        
        var color: String {
            switch self {
            case .info: return "white"
            case .warning: return "orange"
            case .error: return "red"
            case .debug: return "gray"
            }
        }
    }
    
    @Published var logs: [LogEntry] = []
    
    private init() {}
    
    func log(_ message: String, source: String = "App", level: LogLevel = .info) {
        let entry = LogEntry(source: source, message: message, level: level)
        
        DispatchQueue.main.async {
            self.logs.append(entry)
            // Keep buffer manageable
            if self.logs.count > 100 {
                self.logs.removeFirst()
            }
        }
        
        // Also print to Xcode console
        print("[\(source)] \(message)")
    }
    
    func clear() {
        logs.removeAll()
    }
}
