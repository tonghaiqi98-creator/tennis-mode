import SwiftUI

/// Demo 应用入口：负责挂载根视图，并统一使用深色外观贴近影石运动拍摄界面。
@main
struct TennisGimbalDemoApp: App {
    var body: some Scene {
        WindowGroup {
            RootTennisDemoView()
                .preferredColorScheme(.dark)
        }
    }
}
