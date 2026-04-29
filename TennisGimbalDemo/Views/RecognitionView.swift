import SwiftUI

/// 识别准备页：保持相机预览不退出，在画面上模拟球场线识别和拍摄区域锁定。
struct RecognitionView: View {
    @ObservedObject var viewModel: TennisDemoViewModel

    var body: some View {
        LandscapeCameraShell {
            ZStack {
                CameraPreviewBackground()
                    .brightness(viewModel.isRecognitionFailed ? -0.12 : -0.04)
                CourtReferenceOverlay(showRecommendedFrame: true)
                    .opacity(0.74)

                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.18), lineWidth: 9)
                            .frame(width: 116, height: 116)
                        Circle()
                            .trim(from: 0, to: viewModel.recognitionProgress)
                            .stroke(
                                viewModel.isRecognitionFailed ? AppTheme.warning : AppTheme.accent,
                                style: StrokeStyle(lineWidth: 9, lineCap: .round)
                            )
                            .frame(width: 116, height: 116)
                            .rotationEffect(.degrees(-90))
                        Image(systemName: viewModel.isRecognitionFailed ? "exclamationmark.triangle.fill" : "viewfinder")
                            .font(.system(size: 36, weight: .black))
                            .foregroundStyle(viewModel.isRecognitionFailed ? AppTheme.warning : AppTheme.accent)
                    }

                    CameraInstructionBanner(
                        title: viewModel.recognitionStatus,
                        detail: viewModel.isRecognitionFailed ? "可以使用右侧按钮手动调整取景框继续拍摄" : "请保持云台稳定，系统正在锁定拍摄区域",
                        tint: viewModel.isRecognitionFailed ? AppTheme.warning : AppTheme.accent
                    )

                    if !viewModel.isRecognitionFailed {
                        Button(action: viewModel.simulateRecognitionFailure) {
                            Label("模拟识别失败", systemImage: "exclamationmark.triangle")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(.black.opacity(0.52))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        } leftRail: {
            CameraLeftToolRail()
        } rightRail: {
            CameraRightRail(statusText: viewModel.isRecognitionFailed ? "需调整" : "识别中") {
                if viewModel.isRecognitionFailed {
                    CameraRoundActionButton(
                        title: "手动框选",
                        systemImage: "crop",
                        fill: AppTheme.accent,
                        action: viewModel.openManualAdjustment
                    )
                } else {
                    ProgressView()
                        .tint(AppTheme.accent)
                        .scaleEffect(1.3)
                }
            }
        } bottomOverlay: {
            CameraModeStrip(selectedMode: "网球模式")
        }
    }
}
