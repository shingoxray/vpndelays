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

    /// 使用端点自定义阈值计算等级
    func level(greenMax: Double = 50, redMin: Double = 200) -> StatusLevel {
        if !isOnline { return .red }
        if let lat = latency, lat < greenMax, packetLoss == 0 { return .green }
        if let lat = latency, lat < redMin { return .orange }
        return .red
    }
}
