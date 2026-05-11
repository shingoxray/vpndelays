import SwiftUI

struct TunnelRowView: View {
    let tunnel: Tunnel
    let status: TunnelStatus?
    /// 延迟 < 此值 → 绿色
    let greenMaxLatency: Double
    /// 延迟 >= 此值 → 红色
    let redMinLatency: Double

    init(tunnel: Tunnel, status: TunnelStatus?,
         greenMaxLatency: Double = 50,
         redMinLatency: Double = 200) {
        self.tunnel = tunnel
        self.status = status
        self.greenMaxLatency = greenMaxLatency
        self.redMinLatency = redMinLatency
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)

            Text(tunnel.name)
                .font(.system(size: 11))
                .lineLimit(1)

            Text(tunnel.host)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer()

            if let status = status, status.isOnline {
                HStack(spacing: 4) {
                    Text(String(format: "%.0f ms", status.latency ?? 0))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(latencyColor)
                    Text(String(format: "%.0f%%", status.packetLoss))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(packetLossColor)
                        .frame(width: 32, alignment: .trailing)
                }
            } else if let _ = status {
                Text("超时")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .frame(width: 32, alignment: .trailing)
            } else {
                Text("--")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 32, alignment: .trailing)
            }
        }
        .padding(.horizontal, 12)
        .padding(.leading, 28)
        .padding(.vertical, 3)
    }

    private var statusColor: Color {
        guard let status = status else { return .gray.opacity(0.4) }
        switch status.level(greenMax: greenMaxLatency, redMin: redMinLatency) {
        case .green:  return .green
        case .orange: return .orange
        case .red:    return .red
        }
    }

    private var latencyColor: Color {
        guard let s = status, let l = s.latency else { return .secondary }
        if l < greenMaxLatency { return .green }
        if l < redMinLatency { return .orange }
        return .red
    }

    private var packetLossColor: Color {
        guard let s = status else { return .secondary }
        if s.packetLoss == 0 { return .green }
        if s.packetLoss < 10 { return .orange }
        return .red
    }
}
