import SwiftUI

struct RecommendationsView: View {
    @ObservedObject private var avatarStore = AvatarStore.shared
    @ObservedObject private var progressStore = ProgressStore.shared
    @State private var recommendations: [DrillRecommendation] = []
    @State private var isLoading = true
    
    var onDrillSelected: (DrillDefinition, DifficultyAdaptation?) -> Void
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Genererar AI-rekommendationer...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if recommendations.isEmpty {
                    emptyState
                } else {
                    recommendationsList
                }
            }
            .navigationTitle("AI Rekommendationer")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Uppdatera") {
                        generateRecommendations()
                    }
                }
            }
        }
        .onAppear {
            generateRecommendations()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("Inga rekommendationer än")
                .font(.title2)
                .bold()
            
            Text("Genomför några träningspass så kan AI:n ge dig personliga rekommendationer!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var recommendationsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(recommendations) { recommendation in
                    RecommendationCard(
                        recommendation: recommendation,
                        onSelect: {
                            onDrillSelected(recommendation.drill, recommendation.adaptedSettings)
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    private func generateRecommendations() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let avatar = avatarStore.avatar else {
                DispatchQueue.main.async {
                    self.recommendations = []
                    self.isLoading = false
                }
                return
            }
            
            let newRecommendations = AIRecommendationEngine.shared.recommendDrills(
                for: avatar,
                progressHistory: progressStore.sessions
            )
            
            DispatchQueue.main.async {
                self.recommendations = newRecommendations
                self.isLoading = false
            }
        }
    }
}

struct RecommendationCard: View {
    let recommendation: DrillRecommendation
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.drill.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(recommendation.priority.description)
                        .font(.caption)
                        .foregroundColor(priorityColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(priorityColor.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Button(action: onSelect) {
                    Text("Välj")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }
            }
            
            Text(recommendation.drill.description)
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                Label("\(recommendation.drill.timeLimitSeconds)s", systemImage: "timer")
                Label("\(recommendation.drill.conesCount) koner", systemImage: "cone")
                Label(recommendation.drill.domain.capitalized, systemImage: "target")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            if let adaptation = recommendation.adaptedSettings {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI-anpassning:")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.accentColor)
                    
                    Text(adaptation.reason)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                    
                    if adaptation.timeAdjustment != 1.0 || adaptation.coneAdjustment != 0 {
                        HStack(spacing: 12) {
                            if adaptation.timeAdjustment != 1.0 {
                                let newTime = Int(Double(recommendation.drill.timeLimitSeconds) * adaptation.timeAdjustment)
                                Text("Tid: \(newTime)s")
                                    .font(.caption2)
                                    .foregroundColor(.accentColor)
                            }
                            
                            if adaptation.coneAdjustment != 0 {
                                let newCones = max(1, recommendation.drill.conesCount + adaptation.coneAdjustment)
                                Text("Koner: \(newCones)")
                                    .font(.caption2)
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            Divider()
            
            Text("💡 \(recommendation.reason)")
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var priorityColor: Color {
        switch recommendation.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

#Preview {
    RecommendationsView { _, _ in }
}