import SwiftUI

/// 根视图：根据 ViewModel 中的阶段状态，切换完整的网球模式演示流程。
struct RootTennisDemoView: View {
    @StateObject private var viewModel = TennisDemoViewModel()

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            switch viewModel.stage {
            case .home:
                HomeView(viewModel: viewModel)
            case .setupGuide:
                SetupGuideView(viewModel: viewModel)
            case .recognition:
                RecognitionView(viewModel: viewModel)
            case .manualAdjustment:
                ManualAdjustmentView(viewModel: viewModel)
            case .shooting:
                ShootingView(viewModel: viewModel)
            case .result:
                ResultView(viewModel: viewModel)
            }
        }
    }
}

/// 传统预览声明，避免命令行沙箱环境里 Swift 宏插件不可用的问题。
struct RootTennisDemoView_Previews: PreviewProvider {
    static var previews: some View {
        RootTennisDemoView()
    }
}
