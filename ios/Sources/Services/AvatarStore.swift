import Foundation
import Combine

final class AvatarStore: ObservableObject {
    static let shared = AvatarStore()
    private let userDefaultsKey = "avatar.v1"
    @Published var avatar: Avatar? = nil

    private init() {
        self.avatar = load()
    }

    func save(_ avatar: Avatar) {
        do {
            let data = try JSONEncoder().encode(avatar)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            self.avatar = avatar
        } catch {
            print("AvatarStore save error: \(error)")
        }
    }

    private func load() -> Avatar? {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return nil }
        do {
            return try JSONDecoder().decode(Avatar.self, from: data)
        } catch {
            print("AvatarStore load error: \(error)")
            return nil
        }
    }
}

