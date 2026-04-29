import SwiftUI

/// 首页入口：改为横屏相机模式选择界面，让网球模式像真实相机模式一样进入。
struct HomeView: View {
    @ObservedObject var viewModel: TennisDemoViewModel

    var body: some View {
        LandscapeCameraShell {
            ZStack {
                CameraPreviewBackground()
                CourtReferenceOverlay(showRecommendedFrame: false)
                    .opacity(0.22)

                VStack(spacing: 12) {
                    StatusPill(title: "云台已连接", systemImage: "dot.radiowaves.left.and.right", tint: AppTheme.accentGreen)
                    Text("网球模式")
                        .font(.system(size: 44, weight: .black))
                        .foregroundStyle(.white)
                    Text("横屏取景 · 场地标尺 · 自动跟随 · 高光片段保存")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white.opacity(0.82))
                    Text("进入后先根据球场线架机，再开始无人值守拍摄。")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.64))
                }
                .padding(24)
                .background(.black.opacity(0.36))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        } leftRail: {
            CameraLeftToolRail()
        } rightRail: {
            CameraRightRail(statusText: "网球模式") {
                CameraRoundActionButton(
                    title: "进入",
                    systemImage: "figure.tennis",
                    fill: AppTheme.accent,
                    action: viewModel.enterSetupGuide
                )
            }
        } bottomOverlay: {
            CameraModeStrip(selectedMode: "网球模式")
        }
    }
}
