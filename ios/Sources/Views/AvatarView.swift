import SwiftUI

struct AvatarView: View {
    @ObservedObject private var store = AvatarStore.shared

    @State private var name: String = ""
    @State private var ageBand: AgeBand = .nineToEleven
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -10, to: Date()) ?? Date()
    @State private var jerseyNumber: Int = 10
    @State private var favoritePosition: FavoritePosition = .midfielder
    @State private var jerseyColor: Color = Color(red: 0.12, green: 0.47, blue: 0.90)
    @State private var skinTone: Color = Color(red: 0.94, green: 0.80, blue: 0.63)
    @State private var hairStyle: HairStyle = .short

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Min Avatar").font(.title).bold()

                avatarPreview

                Group {
                    Text("Namn").font(.headline)
                    TextField("Ange namn", text: $name)
                        .textFieldStyle(.roundedBorder)
                }

                Group {
                    Text("Åldersgrupp").font(.headline)
                    DatePicker("Födelsedatum", selection: $birthDate, displayedComponents: .date)
                    Picker("Åldersgrupp", selection: $ageBand) {
                        ForEach(AgeBand.allCases) { band in
                            Text(band.rawValue).tag(band)
                        }
                    }.pickerStyle(.segmented)
                    .onChange(of: birthDate) { _, newVal in
                        let years = Calendar.current.dateComponents([.year], from: newVal, to: Date()).year ?? 0
                        ageBand = AgeBand.from(ageYears: years)
                    }
                }

                Group {
                    Text("Position").font(.headline)
                    Picker("Position", selection: $favoritePosition) {
                        ForEach(FavoritePosition.allCases) { p in
                            Text(p.rawValue.capitalized).tag(p)
                        }
                    }.pickerStyle(.segmented)
                }

                Group {
                    Text("Tröjfärg").font(.headline)
                    ColorPicker("Tröjfärg", selection: $jerseyColor)
                    Stepper(value: $jerseyNumber, in: 1...99) {
                        Text("Tröjnummer: \(jerseyNumber)")
                    }
                }

                Group {
                    Text("Hudton").font(.headline)
                    ColorPicker("Hudton", selection: $skinTone)
                }

                Group {
                    Text("Frisyr").font(.headline)
                    Picker("Frisyr", selection: $hairStyle) {
                        ForEach(HairStyle.allCases) { h in
                            Text(h.rawValue.capitalized).tag(h)
                        }
                    }
                }

                Button(action: save) {
                    Text("Spara Avatar").bold()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .onAppear(perform: hydrate)
        }
    }

    private var avatarPreview: some View {
        ZStack {
            Circle()
                .fill(skinTone)
                .frame(width: 120, height: 120)
            Circle()
                .stroke(Color.black.opacity(0.2), lineWidth: 2)
                .frame(width: 120, height: 120)
            RoundedRectangle(cornerRadius: 10)
                .fill(jerseyColor)
                .frame(width: 140, height: 60)
                .offset(y: 60)
            Text(String(name.prefix(1)).uppercased())
                .font(.largeTitle).bold()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func hydrate() {
        guard let a = store.avatar else { return }
        name = a.name
        birthDate = a.birthDate ?? birthDate
        jerseyNumber = a.jerseyNumber
        ageBand = a.ageBand
        favoritePosition = a.favoritePosition
        jerseyColor = Color(hex: a.jerseyColorHex) ?? jerseyColor
        skinTone = Color(hex: a.skinToneHex) ?? skinTone
        hairStyle = a.hairStyle
    }

    private func save() {
        let avatar = Avatar(
            name: name.isEmpty ? "Spelare" : name,
            birthDate: birthDate,
            jerseyNumber: jerseyNumber,
            ageBand: ageBand,
            favoritePosition: favoritePosition,
            jerseyColorHex: jerseyColor.toHexRGB() ?? "#1F77D4",
            skinToneHex: skinTone.toHexRGB() ?? "#F0CCA1",
            hairStyle: hairStyle
        )
        store.save(avatar)
    }
}

private extension Color {
    init?(hex: String) {
        var hexString = hex
        if hexString.hasPrefix("#") { hexString.removeFirst() }
        guard hexString.count == 6, let intVal = Int(hexString, radix: 16) else { return nil }
        let r = Double((intVal >> 16) & 0xFF) / 255.0
        let g = Double((intVal >> 8) & 0xFF) / 255.0
        let b = Double(intVal & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    func toHexRGB() -> String? {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        let ri = Int(round(r * 255))
        let gi = Int(round(g * 255))
        let bi = Int(round(b * 255))
        return String(format: "#%02X%02X%02X", ri, gi, bi)
    }
}

