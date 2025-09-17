import Foundation

enum ContentValidationIssue: Identifiable {
    case missingSource(id: String)
    case emptyObjectives(entity: String)

    var id: String {
        switch self {
        case .missingSource(let id): return "missingSource:\(id)"
        case .emptyObjectives(let entity): return "emptyObjectives:\(entity)"
        }
    }
}

final class ContentValidator {
    func validate(drills: [DrillDefinition], questions: [QuestionItem]) -> [ContentValidationIssue] {
        var issues: [ContentValidationIssue] = []
        let service = ResearchService.shared
        for d in drills {
            if let ids = d.sources {
                for sid in ids { if service.resolve(ids: [sid]).isEmpty { issues.append(.missingSource(id: sid)) } }
            }
            if let obj = d.objectives, obj.isEmpty { issues.append(.emptyObjectives(entity: d.id)) }
        }
        for q in questions {
            if let ids = q.sources {
                for sid in ids { if service.resolve(ids: [sid]).isEmpty { issues.append(.missingSource(id: sid)) } }
            }
            if let obj = q.objectives, obj.isEmpty { issues.append(.emptyObjectives(entity: q.id)) }
        }
        return issues
    }
}

