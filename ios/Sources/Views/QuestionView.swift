import SwiftUI

struct QuestionView: View {
    let question: QuestionItem
    var onAnswer: (Int?) -> Void

    @State private var selectedIndex: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fråga").font(.headline)
            Text(question.stem).font(.title3)

            if let choices = question.choices {
                ForEach(choices.indices, id: \\.self) { idx in
                    Button(action: { selectedIndex = idx }) {
                        HStack {
                            Image(systemName: selectedIndex == idx ? "largecircle.fill.circle" : "circle")
                            Text(choices[idx])
                            Spacer()
                        }
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Spacer()
                Button("Fortsätt") { onAnswer(selectedIndex) }
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

