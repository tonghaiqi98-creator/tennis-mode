import SwiftUI

/// 手动调整页：识别失败时仍停留在横屏相机界面，允许用户调整推荐框大小。
struct ManualAdjustmentView: View {
    @ObservedObject var viewModel: TennisDemoViewModel
    @State private var frameScale: CGFloat = 1

    var body: some View {
        LandscapeCameraShell {
            ZStack {
                CameraPreviewBackground()
                CourtReferenceOverlay(showRecommendedFrame: true, frameScale: frameScale)

                VStack(spacing: 16) {
                    CameraInstructionBanner(
                        title: "手动调整取景框",
                        detail: "让球网、底线和主要跑动区域尽量贴合黄色参考框",
                        tint: AppTheme.warning
                    )

                    VStack(spacing: 8) {
                        Slider(value: $frameScale, in: 0.75...1.35)
                            .tint(AppTheme.accent)
                        HStack {
                            Text("收窄")
                            Spacer()
                            Text("扩大")
                        }
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.72))
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .frame(width: 320)
                    .background(.black.opacity(0.52))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        } leftRail: {
            CameraLeftToolRail()
        } rightRail: {
            CameraRightRail(statusText: "手动取景") {
                CameraRoundActionButton(
                    title: "开始拍摄",
                    systemImage: "checkmark",
                    fill: AppTheme.accent,
                    action: viewModel.confirmManualFrame
                )
            }
        } bottomOverlay: {
            CameraModeStrip(selectedMode: "网球模式")
        }
    }
}
