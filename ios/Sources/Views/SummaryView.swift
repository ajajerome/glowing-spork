import SwiftUI

struct SummaryView: View {
    let session: DrillSessionTelemetry
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Sammanfattning").font(.title2).bold()
            HStack {
                Label("Poäng: \(session.score)", systemImage: "star.fill")
                Label("Koner: \(session.conesCollected)", systemImage: "cone")
            }
            .font(.headline)
            .padding(.top, 8)

            HStack(spacing: 16) {
                Label("Scanningar: \(session.scansCount)", systemImage: "eye")
                Label("Rörelser: \(session.touchesMovedCount)", systemImage: "hand.draw")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)

            if let dur = session.durationSec {
                Text("Tid: \(Int(dur))s").font(.caption)
            }

            Spacer()
            Button("Stäng") { onClose() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

