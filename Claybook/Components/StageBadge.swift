import SwiftUI

struct StageBadge: View {
    let stage: StageType

    var stageColor: Color {
        switch stage {
        case .made: .theme.stageMade
        case .drying: .theme.stageDrying
        case .bisqueKiln: .theme.stageBisque
        case .glazed: .theme.stageGlazed
        case .glazeKiln: .theme.stageGlazeKiln
        case .finished: .theme.stageFinished
        }
    }

    var body: some View {
        Text(stage.shortName)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(stageColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(stageColor.opacity(0.12))
            .clipShape(Capsule())
            .accessibilityLabel("Stage: \(stage.displayName)")
    }
}

#Preview {
    HStack {
        ForEach(StageType.allCases) { stage in
            StageBadge(stage: stage)
        }
    }
    .padding()
}
