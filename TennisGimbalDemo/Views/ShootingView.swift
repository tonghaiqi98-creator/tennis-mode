import SwiftUI

/// 拍摄页：横屏相机画面为主，右侧保留大录制键，画面内叠加自动跟随和高光保存状态。
struct ShootingView: View {
    @ObservedObject var viewModel: TennisDemoViewModel

    var body: some View {
        LandscapeCameraShell {
            ZStack {
                CameraPreviewBackground()
                CourtReferenceOverlay(showRecommendedFrame: false)
                    .opacity(0.45)
                MovingPlayerOverlay(seconds: viewModel.recordingSeconds, isRecording: viewModel.isRecording)

                VStack {
                    HStack(spacing: 10) {
                        StatusPill(
                            title: viewModel.isRecording ? viewModel.formattedRecordingTime() : "待录制",
                            systemImage: viewModel.isRecording ? "record.circle.fill" : "record.circle",
                            tint: viewModel.isRecording ? AppTheme.warning : AppTheme.accent
                        )
                        StatusPill(title: "\(viewModel.batteryLevel)%", systemImage: "battery.75", tint: AppTheme.accentGreen)
                        StatusPill(title: viewModel.storageUsedText, systemImage: "internaldrive", tint: .cyan)
                        StatusPill(title: viewModel.followStatus, systemImage: "dot.scope", tint: AppTheme.accentGreen)
                        Spacer()
                    }
                    .padding(.top, 62)
                    .padding(.horizontal, 18)

                    Spacer()

                    HStack(alignment: .bottom, spacing: 12) {
                        storagePolicyPanel
                            .frame(width: 420)
                        Spacer()
                        if let toast = viewModel.savedToastText {
                            SavedClipToast(text: toast)
                                .frame(width: 300)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 78)
                }
                .animation(.spring(response: 0.32, dampingFraction: 0.86), value: viewModel.savedToastText)
            }
        } leftRail: {
            CameraLeftToolRail()
        } rightRail: {
            CameraRightRail(statusText: viewModel.isRecording ? "录制中" : "网球模式") {
                if viewModel.isRecording {
                    CameraRoundActionButton(
                        title: "结束",
                        systemImage: "stop.fill",
                        fill: AppTheme.warning,
                        action: viewModel.finishRecording
                    )
                } else {
                    CameraRoundActionButton(
                        title: "录制",
                        systemImage: nil,
                        fill: AppTheme.warning,
                        action: viewModel.startRecording
                    )
                }
            }
        } bottomOverlay: {
            CameraModeStrip(selectedMode: "网球模式")
        }
    }

    /// 素材保存策略面板，明确表达不默认整场高清保存的产品策略。
    private var storagePolicyPanel: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text(viewModel.autoSaveState)
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.white)
                Spacer()
                Text("非重点降级")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(AppTheme.accent)
            }

            ForEach(TennisDemoMockData.storagePolicies) { item in
                HStack(spacing: 8) {
                    Text(item.title)
                        .font(.system(size: 12, weight: .black))
                        .frame(width: 58, alignment: .leading)
                    Text(item.detail)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.66))
                        .lineLimit(1)
                    Spacer()
                    Text(item.status)
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(item.status == "高清保存" ? AppTheme.accent : .white.opacity(0.82))
                }
            }
        }
        .padding(13)
        .background(.black.opacity(0.56))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.white.opacity(0.14), lineWidth: 1)
        )
    }
}

/// 自动保存提示条，模拟重点片段出现时的浮层反馈。
private struct SavedClipToast: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(AppTheme.accent)
            Text(text)
                .font(.system(size: 15, weight: .black))
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(14)
        .background(.black.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(AppTheme.accent.opacity(0.45), lineWidth: 1)
        )
    }
}
