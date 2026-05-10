import Foundation

struct TunnelStatus: Identifiable, Equatable {
    let id = UUID()
    let tunnelId: UUID
    var isOnline: Bool
    var latency: Double?
    var packetLoss: Double
    var lastChecked: Date?
}
