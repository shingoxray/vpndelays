import Foundation

struct PingParser {

    /// 解析 macOS `/sbin/ping` 命令的标准输出
    static func parse(output: String, tunnelId: UUID) -> TunnelStatus {
        let nsOutput = output as NSString

        // 提取所有 "time=X.XXX ms"
        let timeRegex = try! NSRegularExpression(pattern: #"time=(\d+\.?\d*)\s*ms"#)
        let timeMatches = timeRegex.matches(in: output, range: NSRange(location: 0, length: nsOutput.length))
        let times: [Double] = timeMatches.compactMap { match in
            guard match.numberOfRanges > 1 else { return nil }
            let capture = nsOutput.substring(with: match.range(at: 1))
            return Double(capture)
        }

        // 提取 "X.X% packet loss"
        let lossRegex = try! NSRegularExpression(pattern: #"([\d.]+)%\s*packet loss"#)
        let packetLoss: Double = {
            if let match = lossRegex.firstMatch(in: output, range: NSRange(location: 0, length: nsOutput.length)),
               match.numberOfRanges > 1 {
                let capture = nsOutput.substring(with: match.range(at: 1))
                return Double(capture) ?? (times.isEmpty ? 100.0 : 0.0)
            }
            return times.isEmpty ? 100.0 : 0.0
        }()

        if times.isEmpty {
            return TunnelStatus(
                tunnelId: tunnelId,
                isOnline: false,
                latency: nil,
                packetLoss: packetLoss,
                lastChecked: Date()
            )
        }

        let avgLatency = times.reduce(0, +) / Double(times.count)

        return TunnelStatus(
            tunnelId: tunnelId,
            isOnline: true,
            latency: avgLatency,
            packetLoss: packetLoss,
            lastChecked: Date()
        )
    }
}
