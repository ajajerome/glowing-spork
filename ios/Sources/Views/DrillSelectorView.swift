import SwiftUI

struct DrillSelectorView: View {
    @ObservedObject private var avatarStore = AvatarStore.shared
    @State private var drills: [DrillDefinition] = []
    var onSelect: (DrillDefinition) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Välj övning").font(.title2).bold()
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(drills) { drill in
                        Button(action: { onSelect(drill) }) {
                            HStack(alignment: .top, spacing: 12) {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
                                    .frame(width: 64, height: 64)
                                    .overlay(Image(systemName: icon(for: drill)).font(.title))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(drill.title).font(.headline)
                                    Text(drill.description).font(.caption).foregroundColor(.secondary)
                                    HStack(spacing: 8) {
                                        Label("\(drill.timeLimitSeconds)s", systemImage: "timer")
                                        Label("\(drill.conesCount)", systemImage: "cone")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    if let sources = ResearchService.shared.resolve(ids: drill.sources), !sources.isEmpty {
                                        Text("Källa: \(sources.first!.org)").font(.caption2).foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)).shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .onAppear {
            let band = avatarStore.avatar?.derivedAgeBand() ?? avatarStore.avatar?.ageBand
            drills = DrillService.shared.drills(for: band)
        }
    }

    private func icon(for drill: DrillDefinition) -> String {
        switch drill.domain {
        case "attack": return "arrowtriangle.forward.fill"
        case "defence": return "shield.fill"
        default: return "sportscourt"
        }
    }
}

