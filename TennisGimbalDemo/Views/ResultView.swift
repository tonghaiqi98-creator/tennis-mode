import SwiftUI

/// 结果页：横屏结果台，展示重点片段、保留/删除选择和节省空间提示。
struct ResultView: View {
    @ObservedObject var viewModel: TennisDemoViewModel

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            HStack(spacing: 18) {
                summaryPanel
                    .frame(width: 300)

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("本场重点片段")
                                .font(.system(size: 28, weight: .black))
                            Text("勾选保留高清片段，取消勾选则拍摄结束后删除高清文件。")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                        Spacer()
                        Button(action: viewModel.restartDemo) {
                            Label("返回相机", systemImage: "camera.fill")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(AppTheme.elevated)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach($viewModel.clips) { $clip in
                                ResultClipRow(clip: $clip)
                            }
                        }
                    }

                    HStack(spacing: 12) {
                        PrimaryActionButton(
                            title: "生成集锦",
                            systemImage: "wand.and.stars",
                            action: viewModel.generateHighlightMovie
                        )
                        .frame(width: 220)

                        if let message = viewModel.generatedMessage {
                            Label(message, systemImage: "film.stack.fill")
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(AppTheme.elevated)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                    }
                }
            }
            .padding(18)
        }
    }

    /// 左侧总结面板，突出“非整场高清保存”的存储价值。
    private var summaryPanel: some View {
        VStack(alignment: .leading, spacing: 18) {
            StatusPill(title: "网球模式回放", systemImage: "figure.tennis")

            Text("本场已节省存储空间")
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(.white)

            Text(viewModel.savedStorageText)
                .font(.system(size: 46, weight: .black))
                .foregroundStyle(AppTheme.accent)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(TennisDemoMockData.storagePolicies) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: item.status == "高清保存" ? "checkmark.seal.fill" : "clock.arrow.circlepath")
                            .foregroundStyle(item.status == "高清保存" ? AppTheme.accent : .white.opacity(0.66))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(item.title) · \(item.status)")
                                .font(.system(size: 13, weight: .black))
                            Text(item.detail)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(18)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

/// 重点片段卡片：展示类型、时间点、时长、推荐理由，并允许用户选择保留或删除。
private struct ResultClipRow: View {
    @Binding var clip: TennisHighlightClip

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(AppTheme.accent.opacity(0.16))
                    .frame(width: 52, height: 52)
                Image(systemName: clip.type.symbolName)
                    .font(.system(size: 23, weight: .black))
                    .foregroundStyle(AppTheme.accent)
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(clip.type.rawValue)
                        .font(.system(size: 17, weight: .black))
                    Text("\(clip.timePoint) · \(clip.duration) · \(clip.storageStrategy)")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(AppTheme.accent)
                }
                Text(clip.reason)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(2)
            }

            Spacer()

            Text(clip.shouldKeep ? "保留高清" : "删除高清")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(clip.shouldKeep ? AppTheme.accentGreen : AppTheme.warning)

            Toggle("", isOn: $clip.shouldKeep)
                .labelsHidden()
                .tint(AppTheme.accent)
        }
        .padding(14)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(clip.shouldKeep ? AppTheme.accent.opacity(0.24) : AppTheme.warning.opacity(0.28), lineWidth: 1)
        )
    }
}
