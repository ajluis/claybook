import SwiftUI

struct StageTimeline: View {
    let stageLogs: [StageLog]
    let currentStage: StageType
    var onStageTapped: ((StageLog) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(StageType.allCases) { stage in
                let log = stageLogs.first { $0.stage == stage }
                StageTimelineRow(
                    stage: stage,
                    stageLog: log,
                    isCompleted: log != nil,
                    isCurrent: stage == currentStage,
                    isLast: stage == .finished
                )
                .onTapGesture {
                    if let log { onStageTapped?(log) }
                }
            }
        }
    }
}

struct StageTimelineRow: View {
    let stage: StageType
    let stageLog: StageLog?
    let isCompleted: Bool
    let isCurrent: Bool
    let isLast: Bool

    var dotColor: Color {
        if isCompleted {
            switch stage {
            case .made: return .theme.stageMade
            case .drying: return .theme.stageDrying
            case .bisqueKiln: return .theme.stageBisque
            case .glazed: return .theme.stageGlazed
            case .glazeKiln: return .theme.stageGlazeKiln
            case .finished: return .theme.stageFinished
            }
        }
        return Color.theme.textTertiary.opacity(0.3)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline dot + line
            VStack(spacing: 0) {
                Circle()
                    .fill(isCompleted ? dotColor : Color.clear)
                    .stroke(dotColor, lineWidth: 2)
                    .frame(width: isCurrent ? 14 : 10, height: isCurrent ? 14 : 10)

                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? dotColor.opacity(0.3) : Color.theme.textTertiary.opacity(0.15))
                        .frame(width: 2)
                        .frame(minHeight: 40)
                }
            }
            .frame(width: 20)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(stage.displayName)
                    .font(isCurrent ? .subheadline.weight(.semibold) : .subheadline)
                    .foregroundStyle(isCompleted ? Color.theme.textPrimary : Color.theme.textTertiary)

                if let log = stageLog {
                    Text(log.date.mediumDisplay)
                        .font(.caption)
                        .foregroundStyle(Color.theme.textSecondary)

                    if let notes = log.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(Color.theme.textSecondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding(.bottom, isLast ? 0 : 8)

            Spacer()
        }
    }
}
