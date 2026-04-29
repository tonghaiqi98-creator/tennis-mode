import SwiftUI

/// 横屏相机壳组件：统一承载顶部参数、左右工具栏和底部模式栏，贴近云台连接手机后的拍摄界面。
struct LandscapeCameraShell<PreviewContent: View, LeftRail: View, RightRail: View, BottomOverlay: View>: View {
    let previewContent: PreviewContent
    let leftRail: LeftRail
    let rightRail: RightRail
    let bottomOverlay: BottomOverlay

    init(
        @ViewBuilder previewContent: () -> PreviewContent,
        @ViewBuilder leftRail: () -> LeftRail,
        @ViewBuilder rightRail: () -> RightRail,
        @ViewBuilder bottomOverlay: () -> BottomOverlay
    ) {
        self.previewContent = previewContent()
        self.leftRail = leftRail()
        self.rightRail = rightRail()
        self.bottomOverlay = bottomOverlay()
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black.ignoresSafeArea()

                HStack(spacing: 0) {
                    leftRail
                        .frame(width: 78)
                        .frame(maxHeight: .infinity)
                        .background(Color.black)

                    ZStack {
                        previewContent
                        CameraTopBar()
                            .padding(.horizontal, 18)
                            .padding(.top, 12)
                            .frame(maxHeight: .infinity, alignment: .top)
                        bottomOverlay
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                    .frame(width: max(proxy.size.width - 194, 420), height: proxy.size.height)
                    .clipped()

                    rightRail
                        .frame(width: 116)
                        .frame(maxHeight: .infinity)
                        .background(Color.black)
                }
            }
        }
    }
}

/// 顶部相机参数栏：包含更多、云台连接、曝光、分辨率帧率和首页状态等信息。
struct CameraTopBar: View {
    var body: some View {
        HStack(spacing: 26) {
            Image(systemName: "ellipsis")
                .font(.system(size: 24, weight: .bold))
            Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                .font(.system(size: 24, weight: .bold))
                .overlay(alignment: .bottomTrailing) {
                    Circle()
                        .fill(AppTheme.warning)
                        .frame(width: 8, height: 8)
                        .offset(x: 5, y: 5)
                }
            Text("AUTO")
                .font(.system(size: 15, weight: .black))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(.white.opacity(0.16))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            Text("1080\n60fps")
                .font(.system(size: 12, weight: .black))
                .multilineTextAlignment(.center)
                .lineSpacing(-2)
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(.white.opacity(0.78), lineWidth: 1.5)
                )
            Spacer()
            Circle()
                .fill(AppTheme.accentGreen)
                .frame(width: 11, height: 11)
            Image(systemName: "house.fill")
                .font(.system(size: 24, weight: .bold))
        }
        .foregroundStyle(.white)
        .shadow(color: .black.opacity(0.45), radius: 4, y: 2)
    }
}

/// 左侧常用工具栏：模拟真实相机里的曝光、ISO、快门和模式设置入口。
struct CameraLeftToolRail: View {
    var body: some View {
        VStack(spacing: 22) {
            CameraSideIconButton(systemImage: "scope", title: "标尺")
            CameraSideIconButton(systemImage: "camera.aperture", title: "1/100")
            CameraSideIconButton(systemImage: "slider.horizontal.3", title: "ISO 50")
            CameraSideIconButton(systemImage: "plusminus", title: "EV 0.0")
            Spacer()
            CameraSideIconButton(systemImage: "questionmark.circle.fill", title: "帮助")
        }
        .padding(.vertical, 18)
    }
}

/// 右侧工具栏：用于放置录像键、结束键、模式状态和素材入口。
struct CameraRightRail<MainAction: View>: View {
    let mainAction: MainAction
    var statusText: String = "网球模式"

    init(statusText: String = "网球模式", @ViewBuilder mainAction: () -> MainAction) {
        self.statusText = statusText
        self.mainAction = mainAction()
    }

    var body: some View {
        VStack(spacing: 18) {
            CameraSideIconButton(systemImage: "wand.and.stars", title: "高光")
            CameraSideIconButton(systemImage: "person.2.fill", title: "主体")
            CameraSideIconButton(systemImage: "hand.raised.fill", title: "跟随")
            Spacer()
            mainAction
            Text(statusText)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white.opacity(0.82))
            CameraSideIconButton(systemImage: "photo.on.rectangle", title: "素材")
        }
        .padding(.vertical, 16)
    }
}

/// 相机侧边小按钮，采用图标加短文本，避免占用预览画面。
struct CameraSideIconButton: View {
    let systemImage: String
    let title: String

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .bold))
            Text(title)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(.white.opacity(0.88))
        .frame(width: 58)
        .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
    }
}

/// 底部模式栏：把网球模式作为相机模式之一，位置和参考图中的模式切换一致。
struct CameraModeStrip: View {
    var selectedMode = "网球模式"

    private let modes = ["全景拍照", "拍照", "录像", "网球模式", "移动延时"]

    var body: some View {
        HStack(spacing: 34) {
            ForEach(modes, id: \.self) { mode in
                Text(mode)
                    .font(.system(size: mode == selectedMode ? 20 : 16, weight: mode == selectedMode ? .black : .bold))
                    .foregroundStyle(mode == selectedMode ? .white : .white.opacity(0.56))
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.55), .black.opacity(0.86)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

/// 圆形相机主操作按钮，可作为开始录制、结束拍摄或确认取景按钮。
struct CameraRoundActionButton: View {
    let title: String
    let systemImage: String?
    var fill: Color = AppTheme.warning
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                ZStack {
                    Circle()
                        .stroke(.white, lineWidth: 5)
                        .frame(width: 74, height: 74)
                    Circle()
                        .fill(fill)
                        .frame(width: 58, height: 58)
                    if let systemImage {
                        Image(systemName: systemImage)
                            .font(.system(size: 24, weight: .black))
                            .foregroundStyle(fill == AppTheme.accent ? .black : .white)
                    }
                }
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(.plain)
    }
}

/// 画面中央提示气泡，承载架机、识别和跟随状态提示。
struct CameraInstructionBanner: View {
    let title: String
    let detail: String
    var tint: Color = AppTheme.accent

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 26, weight: .black))
                .foregroundStyle(.white)
            Text(detail)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white.opacity(0.86))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .background(.black.opacity(0.42))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(tint.opacity(0.42), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
