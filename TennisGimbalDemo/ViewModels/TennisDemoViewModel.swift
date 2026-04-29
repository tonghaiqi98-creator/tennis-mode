import Foundation

/// 网球模式 Demo 的状态机，集中处理页面跳转、识别模拟、录制计时和片段保存逻辑。
@MainActor
final class TennisDemoViewModel: ObservableObject {
    /// 当前页面阶段，根视图会根据它切换不同页面。
    @Published var stage: TennisDemoStage = .home

    /// 拍摄前识别状态，用于展示“识别球场线/锁定区域”的过程。
    @Published var recognitionStatus = "准备识别球场线"
    @Published var recognitionProgress = 0.0
    @Published var isRecognitionFailed = false

    /// 拍摄页状态：录制、计时、电量、存储和云台跟随提示都由这里驱动。
    @Published var isRecording = false
    @Published var recordingSeconds = 0
    @Published var batteryLevel = 92
    @Published var storageUsedText = "0.0 GB"
    @Published var followStatus = "云台待命"
    @Published var autoSaveState = "重点片段识别已开启"
    @Published var savedToastText: String?

    /// 结果页片段列表，支持用户勾选保留或删除。
    @Published var clips: [TennisHighlightClip] = []
    @Published var savedStorageText = "0.0 GB"
    @Published var generatedMessage: String?

    private var recognitionTask: Task<Void, Never>?
    private var recordingTimer: Timer?
    private var nextClipIndex = 0

    /// 首页进入网球模式设置。
    func enterSetupGuide() {
        stage = .setupGuide
    }

    /// 用户确认取景覆盖完整半场/全场后，开始模拟识别流程。
    func confirmCourtCoverage() {
        stage = .recognition
        startRecognition()
    }

    /// 模拟球场线识别：先识别场地，再锁定拍摄区域，成功后进入拍摄页。
    func startRecognition() {
        recognitionTask?.cancel()
        isRecognitionFailed = false
        recognitionProgress = 0
        recognitionStatus = "正在识别球场线"

        recognitionTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .milliseconds(650))
            guard !Task.isCancelled else { return }
            recognitionProgress = 0.38
            recognitionStatus = "正在识别底线、发球线和边线"

            try? await Task.sleep(for: .milliseconds(850))
            guard !Task.isCancelled else { return }
            recognitionProgress = 0.72
            recognitionStatus = "正在锁定拍摄区域"

            try? await Task.sleep(for: .milliseconds(900))
            guard !Task.isCancelled else { return }
            recognitionProgress = 1
            recognitionStatus = "拍摄区域已锁定"

            try? await Task.sleep(for: .milliseconds(420))
            guard !Task.isCancelled else { return }
            enterShooting()
        }
    }

    /// Demo 中用于展示兜底链路：识别失败后允许手动调整取景框。
    func simulateRecognitionFailure() {
        recognitionTask?.cancel()
        isRecognitionFailed = true
        recognitionProgress = 0.34
        recognitionStatus = "场地线不完整，请手动调整取景框"
    }

    /// 进入手动调整页，用户可以扩大或收窄参考框后继续拍摄。
    func openManualAdjustment() {
        stage = .manualAdjustment
    }

    /// 手动框选确认后进入拍摄页，表示兜底方案也能走完整拍摄流程。
    func confirmManualFrame() {
        enterShooting()
    }

    /// 准备拍摄页数据，默认不直接录制，让用户明确点击“开始录制”。
    func enterShooting() {
        resetRecordingState()
        stage = .shooting
    }

    /// 开始录制并启动计时器；计时器会定期生成 Mock 重点片段。
    func startRecording() {
        guard !isRecording else { return }
        isRecording = true
        followStatus = "云台正在自动跟随"
        autoSaveState = "正在识别重点回合"
        recordingTimer?.invalidate()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.handleRecordingTick()
            }
        }
    }

    /// 每秒刷新拍摄状态，并在指定时间点模拟重点片段自动保存。
    private func handleRecordingTick() {
        recordingSeconds += 1
        batteryLevel = max(68, 92 - recordingSeconds / 4)
        storageUsedText = String(format: "%.1f GB", Double(recordingSeconds) * 0.035)

        if recordingSeconds.isMultiple(of: 4) {
            followStatus = "人物接近边缘，云台轻量修正中"
        } else {
            followStatus = "云台正在自动跟随"
        }

        let triggerSeconds = [5, 11, 17]
        if triggerSeconds.contains(recordingSeconds) {
            saveNextHighlightClip()
        }
    }

    /// 追加下一个重点片段，并短暂弹出“已自动保存高清片段”的提示。
    private func saveNextHighlightClip() {
        guard nextClipIndex < TennisDemoMockData.highlightClips.count else { return }
        let clip = TennisDemoMockData.highlightClips[nextClipIndex]
        clips.append(clip)
        nextClipIndex += 1
        autoSaveState = "\(clip.type.rawValue) · 高清保存"
        savedToastText = "已自动保存高清片段"

        Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            await MainActor.run {
                guard self?.savedToastText == "已自动保存高清片段" else { return }
                self?.savedToastText = nil
            }
        }
    }

    /// 结束拍摄并进入结果页；若用户很快结束，也补齐演示片段以保证结果页可体验。
    func finishRecording() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false

        while clips.count < TennisDemoMockData.highlightClips.count {
            clips.append(TennisDemoMockData.highlightClips[clips.count])
        }

        let rawSize = max(Double(recordingSeconds), 24) * 0.11
        let retainedSize = Double(clips.filter(\.shouldKeep).count) * 0.22
        savedStorageText = String(format: "%.1f GB", max(rawSize - retainedSize, 1.8))
        stage = .result
    }

    /// 生成集锦按钮的演示反馈；真实版本会进入剪辑或导出流程。
    func generateHighlightMovie() {
        let keepCount = clips.filter(\.shouldKeep).count
        generatedMessage = "已选择 \(keepCount) 个高清片段生成网球集锦"
    }

    /// 返回首页并清空本场演示状态。
    func restartDemo() {
        recognitionTask?.cancel()
        recordingTimer?.invalidate()
        resetRecordingState()
        stage = .home
    }

    /// 将秒数格式化成录制页常见的 mm:ss。
    func formattedRecordingTime() -> String {
        let minutes = recordingSeconds / 60
        let seconds = recordingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// 清理拍摄相关状态，避免多次体验时残留上一次数据。
    private func resetRecordingState() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false
        recordingSeconds = 0
        batteryLevel = 92
        storageUsedText = "0.0 GB"
        followStatus = "云台待命"
        autoSaveState = "重点片段识别已开启"
        savedToastText = nil
        generatedMessage = nil
        clips = []
        nextClipIndex = 0
    }
}
