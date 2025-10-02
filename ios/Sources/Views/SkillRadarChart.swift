import SwiftUI

struct SkillRadarChart: View {
    let data: [SkillRadarPoint]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Färdighetsöversikt")
                .font(.headline)
                .bold()
            
            ForEach(data, id: \.id) { skillData in
                HStack {
                    Text(skillData.displayName)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { level in
                            Circle()
                                .fill(level <= skillData.level ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                        }
                    }
                    
                    Text("Nivå \(skillData.level)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 50, alignment: .trailing)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}