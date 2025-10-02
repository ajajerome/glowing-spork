import SwiftUI

struct SkillRadarChart: View {
    let data: [SkillRadarPoint]
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 40
            
            ZStack {
                backgroundCircles(radius: radius)
                skillAxes(center: center, radius: radius)
                dataPolygon(center: center, radius: radius)
                skillLabels(center: center, radius: radius)
                skillDots(center: center, radius: radius)
            }
        }
    }
    
    private func backgroundCircles(radius: Double) -> some View {
        ForEach(1...5, id: \.self) { level in
            let size = radius * 2 * Double(level) / 5
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                .frame(width: size, height: size)
        }
    }
    
    private func skillAxes(center: CGPoint, radius: Double) -> some View {
        ForEach(data.indices, id: \.self) { index in
            let angle = Double(index) * 2 * .pi / Double(data.count) - .pi / 2
            let endPoint = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            
            Path { path in
                path.move(to: center)
                path.addLine(to: endPoint)
            }
            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        }
    }
    
    private func dataPolygon(center: CGPoint, radius: Double) -> some View {
        Path { path in
            for (index, skillData) in data.enumerated() {
                let angle = Double(index) * 2 * .pi / Double(data.count) - .pi / 2
                let distance = radius * skillData.normalizedValue
                let point = CGPoint(
                    x: center.x + cos(angle) * distance,
                    y: center.y + sin(angle) * distance
                )
                
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
        }
        .fill(LinearGradient(
            colors: [
                Color(red: 0.66, green: 0.88, blue: 0.39).opacity(0.3),
                Color(red: 0.12, green: 0.47, blue: 0.90).opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
        .stroke(LinearGradient(
            colors: [
                Color(red: 0.66, green: 0.88, blue: 0.39),
                Color(red: 0.12, green: 0.47, blue: 0.90)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ), lineWidth: 2)
    }
    
    private func skillLabels(center: CGPoint, radius: Double) -> some View {
        ForEach(data.indices, id: \.self) { index in
            let skillData = data[index]
            let angle = Double(index) * 2 * .pi / Double(data.count) - .pi / 2
            let labelDistance = radius + 25
            let labelPosition = CGPoint(
                x: center.x + cos(angle) * labelDistance,
                y: center.y + sin(angle) * labelDistance
            )
            
            Text(skillData.displayName)
                .font(.caption)
                .bold()
                .foregroundColor(.primary)
                .position(labelPosition)
        }
    }
    
    private func skillDots(center: CGPoint, radius: Double) -> some View {
        ForEach(data.indices, id: \.self) { index in
            let skillData = data[index]
            let angle = Double(index) * 2 * .pi / Double(data.count) - .pi / 2
            let distance = radius * skillData.normalizedValue
            let point = CGPoint(
                x: center.x + cos(angle) * distance,
                y: center.y + sin(angle) * distance
            )
            
            Circle()
                .fill(Color.white)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 2)
                )
                .position(point)
        }
    }
}