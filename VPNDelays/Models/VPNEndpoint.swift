import Foundation

struct Tunnel: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var host: String
}

struct VPNEndpoint: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var tunnels: [Tunnel]
    /// 延迟 < 此值 → 绿色（默认 50ms）
    var greenMaxLatency: Double = 50
    /// 延迟 >= 此值 → 红色（默认 200ms）
    var redMinLatency: Double = 200
}
