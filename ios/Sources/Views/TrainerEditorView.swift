import SwiftUI

struct TrainerEditorView: View {
    @ObservedObject private var store = TrainerContentStore.shared
    @State private var draft = TrainerQuestionDraft()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ny fråga")) {
                    TextField("Frågetext", text: $draft.stem, axis: .vertical)
                    Picker("Åldersgrupp", selection: $draft.ageBand) {
                        ForEach(AgeBand.allCases) { b in Text(b.rawValue).tag(b) }
                    }
                    TextField("Taggar (komma-separerat)", text: Binding(
                        get: { draft.skillTags.joined(separator: ", ") },
                        set: { draft.skillTags = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
                    ))
                    Picker("Domän", selection: $draft.domain) {
                        Text("Anfall").tag("attack")
                        Text("Försvar").tag("defence")
                        Text("Omställning").tag("transition")
                    }
                    ForEach(draft.choices.indices, id: \\.self) { idx in
                        TextField("Svar \(idx+1)", text: Binding(
                            get: { idx < draft.choices.count ? draft.choices[idx] : "" },
                            set: {
                                if idx < draft.choices.count { draft.choices[idx] = $0 } else { draft.choices.append($0) }
                            }
                        ))
                    }
                    Picker("Rätt svar", selection: Binding(
                        get: { draft.correctIndex ?? 0 },
                        set: { draft.correctIndex = $0 }
                    )) {
                        ForEach(0..<(max(draft.choices.count, 3)), id: \\.self) { i in Text("Svar #\(i+1)").tag(i) }
                    }
                    Button("Lägg till val") { draft.choices.append("") }
                    Button("Spara utkast") { saveDraft() }
                        .buttonStyle(.borderedProminent)
                }

                if !store.drafts.isEmpty {
                    Section(header: Text("Mina utkast")) {
                        ForEach(store.drafts) { d in
                            VStack(alignment: .leading) {
                                Text(d.stem).font(.headline)
                                Text("Ålder: \(d.ageBand.rawValue)  Domän: \(d.domain)")
                                    .font(.caption)
                            }
                        }.onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Tränare")
        }
    }

    private func saveDraft() {
        store.add(draft)
        draft = TrainerQuestionDraft()
    }

    private func delete(at offsets: IndexSet) {
        for i in offsets { store.remove(store.drafts[i]) }
    }
}

