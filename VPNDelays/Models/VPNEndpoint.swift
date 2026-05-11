import Foundation

struct Tunnel: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var host: String
}

struct VPNEndpoint: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var tunnels: [Tunnel]
    /// 延迟 < 此值 → 绿色（默认 50ms）
    var greenMaxLatency: Double = 50
    /// 延迟 >= 此值 → 红色（默认 150ms）
    var redMinLatency: Double = 150
}

// MARK: - Codable（兼容旧数据，新字段用 decodeIfPresent）

extension VPNEndpoint: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, tunnels, greenMaxLatency, redMinLatency
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(UUID.self, forKey: .id)
        self.name = try c.decode(String.self, forKey: .name)
        self.tunnels = try c.decode([Tunnel].self, forKey: .tunnels)
        self.greenMaxLatency = try c.decodeIfPresent(Double.self, forKey: .greenMaxLatency) ?? 50
        self.redMinLatency = try c.decodeIfPresent(Double.self, forKey: .redMinLatency) ?? 150
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(tunnels, forKey: .tunnels)
        try c.encode(greenMaxLatency, forKey: .greenMaxLatency)
        try c.encode(redMinLatency, forKey: .redMinLatency)
    }
}
