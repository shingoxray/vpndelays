import Foundation

enum StatusLevel: Int, Comparable {
    case green = 0
    case orange = 1
    case red = 2

    static func < (lhs: StatusLevel, rhs: StatusLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct TunnelStatus: Identifiable, Equatable {
    let id = UUID()
    let tunnelId: UUID
    var isOnline: Bool
    var latency: Double?
    var packetLoss: Double
    var lastChecked: Date?

    /// 隧道状态对应的等级（绿色→橙→红）
    var level: StatusLevel {
        if !isOnline { return .red }
        if let lat = latency, lat < 50, packetLoss == 0 { return .green }
        if let lat = latency, lat < 150 { return .orange }
        return .red
    }
}
