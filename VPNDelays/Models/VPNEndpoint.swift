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
}
