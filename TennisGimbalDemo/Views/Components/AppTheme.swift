import SwiftUI

/// 全局视觉常量：集中管理深色背景、高亮色和常用圆角，方便后续贴近真实 App 视觉规范。
enum AppTheme {
    static let background = Color(red: 0.03, green: 0.035, blue: 0.045)
    static let surface = Color(red: 0.08, green: 0.085, blue: 0.10)
    static let elevated = Color(red: 0.12, green: 0.125, blue: 0.14)
    static let accent = Color(red: 1.0, green: 0.82, blue: 0.12)
    static let accentGreen = Color(red: 0.24, green: 0.86, blue: 0.48)
    static let warning = Color(red: 1.0, green: 0.39, blue: 0.30)
    static let secondaryText = Color.white.opacity(0.68)
    static let line = Color.white.opacity(0.16)
}
