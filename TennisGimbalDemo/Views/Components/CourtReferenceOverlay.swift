import SwiftUI

/// 网球场标尺覆盖层：用底线、发球线、单双打边线和推荐取景框辅助无人值守架机。
struct CourtReferenceOverlay: View {
    var showRecommendedFrame = true
    var frameScale: CGFloat = 1

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let court = CGRect(
                x: size.width * 0.12,
                y: size.height * 0.18,
                width: size.width * 0.76,
                height: size.height * 0.62
            )
            let inner = court.insetBy(dx: court.width * 0.11, dy: 0)
            let serviceTop = court.minY + court.height * 0.34
            let serviceBottom = court.minY + court.height * 0.66
            let netY = court.midY

            ZStack {
                Path { path in
                    // 双打边线与底线
                    path.addRect(court)
                    // 单打边线
                    path.move(to: CGPoint(x: inner.minX, y: court.minY))
                    path.addLine(to: CGPoint(x: inner.minX, y: court.maxY))
                    path.move(to: CGPoint(x: inner.maxX, y: court.minY))
                    path.addLine(to: CGPoint(x: inner.maxX, y: court.maxY))
                    // 发球线
                    path.move(to: CGPoint(x: inner.minX, y: serviceTop))
                    path.addLine(to: CGPoint(x: inner.maxX, y: serviceTop))
                    path.move(to: CGPoint(x: inner.minX, y: serviceBottom))
                    path.addLine(to: CGPoint(x: inner.maxX, y: serviceBottom))
                    // 中线
                    path.move(to: CGPoint(x: court.midX, y: serviceTop))
                    path.addLine(to: CGPoint(x: court.midX, y: serviceBottom))
                    // 球网
                    path.move(to: CGPoint(x: court.minX, y: netY))
                    path.addLine(to: CGPoint(x: court.maxX, y: netY))
                }
                .stroke(.white.opacity(0.74), style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))

                Path { path in
                    // 推荐取景范围：比球场线略大，提醒用户保留发球和横向跑动空间。
                    let recommended = court
                        .insetBy(dx: -court.width * 0.06 * frameScale, dy: -court.height * 0.12 * frameScale)
                    path.addRoundedRect(in: recommended, cornerSize: CGSize(width: 16, height: 16))
                }
                .stroke(AppTheme.accent, style: StrokeStyle(lineWidth: 2.4, dash: showRecommendedFrame ? [9, 7] : []))
                .opacity(showRecommendedFrame ? 1 : 0)

                Text("球网")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(.black.opacity(0.45))
                    .clipShape(Capsule())
                    .position(x: court.midX, y: netY - 14)

                Text("底线")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.78))
                    .position(x: court.midX, y: court.maxY + 18)

                Text("发球线")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.78))
                    .position(x: inner.maxX + 34, y: serviceBottom)
            }
        }
        .allowsHitTesting(false)
    }
}

/// 模拟相机画面背景：使用场地、光斑和轻微暗角营造运动拍摄预览感。
struct CameraPreviewBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.18, blue: 0.13),
                    Color(red: 0.05, green: 0.10, blue: 0.12),
                    Color(red: 0.02, green: 0.025, blue: 0.035)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.08), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack {
                Spacer()
                Rectangle()
                    .fill(.black.opacity(0.22))
                    .frame(height: 80)
            }
        }
    }
}

/// 拍摄页中的运动模拟层，用移动圆点表达球员横向跑动和云台轻量跟随。
struct MovingPlayerOverlay: View {
    let seconds: Int
    let isRecording: Bool

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let progress = isRecording ? abs(sin(Double(seconds) * 0.65)) : 0.5
            let x = width * (0.24 + 0.52 * progress)
            let y = height * (0.58 + 0.06 * cos(Double(seconds) * 0.5))

            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.25))
                    .frame(width: 52, height: 52)
                    .position(x: x, y: y)

                Image(systemName: "figure.tennis")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppTheme.accent)
                    .position(x: x, y: y)
            }
        }
        .allowsHitTesting(false)
    }
}
