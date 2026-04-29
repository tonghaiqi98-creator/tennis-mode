import Foundation

/// 网球模式 Demo 的页面阶段，用一个枚举集中管理完整体验流程。
enum TennisDemoStage {
    case home
    case setupGuide
    case recognition
    case manualAdjustment
    case shooting
    case result
}

/// 自动识别出的重点片段类型，对应 PRD 中的多拍、长跑动、精彩得分。
enum HighlightClipType: String, CaseIterable {
    case rally = "多拍回合"
    case longRun = "长跑动回合"
    case winner = "精彩得分"

    /// 每类片段在界面中使用的 SF Symbol，帮助结果页快速扫读。
    var symbolName: String {
        switch self {
        case .rally:
            return "repeat"
        case .longRun:
            return "figure.tennis"
        case .winner:
            return "sparkles"
        }
    }
}

/// 拍摄后展示的重点片段模型；`shouldKeep` 用于结果页勾选保留或删除。
struct TennisHighlightClip: Identifiable {
    let id = UUID()
    let type: HighlightClipType
    let timePoint: String
    let duration: String
    let reason: String
    let storageStrategy: String
    var shouldKeep: Bool = true
}

/// 素材保存策略说明模型，用于把“高清保存/低清缓存/自动丢弃”的产品规则可视化。
struct StoragePolicyItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let status: String
}

/// Demo 使用的 Mock 数据；真实产品中这里会来自 AI 识别和素材管理服务。
enum TennisDemoMockData {
    static let storagePolicies: [StoragePolicyItem] = [
        StoragePolicyItem(
            title: "重点片段",
            detail: "多拍、长跑动、精彩得分等高价值内容",
            status: "高清保存"
        ),
        StoragePolicyItem(
            title: "普通片段",
            detail: "等待用户复核，不默认占用大量空间",
            status: "低清缓存"
        ),
        StoragePolicyItem(
            title: "无效片段",
            detail: "长时间空场、架机调整、无明显运动内容",
            status: "短期缓存"
        )
    ]

    static let highlightClips: [TennisHighlightClip] = [
        TennisHighlightClip(
            type: .rally,
            timePoint: "00:12",
            duration: "18 秒",
            reason: "连续 8 次以上击球，回合完整且人物始终在主要运动区域内。",
            storageStrategy: "高清保存"
        ),
        TennisHighlightClip(
            type: .longRun,
            timePoint: "00:31",
            duration: "14 秒",
            reason: "球员从底线横向移动到边线附近，云台进行了轻量跟随修正。",
            storageStrategy: "高清保存"
        ),
        TennisHighlightClip(
            type: .winner,
            timePoint: "00:48",
            duration: "9 秒",
            reason: "识别到明显加速挥拍和得分庆祝动作，适合作为集锦素材。",
            storageStrategy: "高清保存"
        )
    ]
}
