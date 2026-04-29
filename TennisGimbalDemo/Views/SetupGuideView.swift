import SwiftUI

/// 拍摄前引导页：横屏相机预览中叠加网球场标尺，引导用户先完成架机位。
struct SetupGuideView: View {
    @ObservedObject var viewModel: TennisDemoViewModel

    var body: some View {
        LandscapeCameraShell {
            ZStack {
                CameraPreviewBackground()
                CourtReferenceOverlay(showRecommendedFrame: true)

                VStack(spacing: 14) {
                    CameraInstructionBanner(
                        title: "请对准网球场",
                        detail: "让球网、底线和主要跑动区域放入黄色参考框",
                        tint: AppTheme.accent
                    )

                    HStack(spacing: 10) {
                        StatusPill(title: "腰部到胸口高度", systemImage: "arrow.up.and.down")
                        StatusPill(title: "侧后方/底线后方", systemImage: "location.viewfinder")
                        StatusPill(title: "横屏广构图", systemImage: "rectangle")
                    }
                }
                .padding(.top, 28)
                .frame(maxHeight: .infinity, alignment: .center)

                Text("画面覆盖完整半场/全场后，点击右侧确认")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(AppTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .padding(.leading, 18)
                    .padding(.bottom, 72)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        } leftRail: {
            CameraLeftToolRail()
        } rightRail: {
            CameraRightRail(statusText: "架机引导") {
                CameraRoundActionButton(
                    title: "确认覆盖",
                    systemImage: "checkmark",
                    fill: AppTheme.accent,
                    action: viewModel.confirmCourtCoverage
                )
            }
        } bottomOverlay: {
            CameraModeStrip(selectedMode: "网球模式")
        }
    }
}
