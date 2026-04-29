// 拍摄页 H5 状态机：用 Mock 状态模拟架机确认、识别、录制和高光保存。
const state = {
  phase: "guide",
  seconds: 0,
  storage: 0,
  clips: [],
  timer: null,
  guideVisible: true
};

const highlightPool = [
  {
    type: "多拍回合",
    time: "00:06",
    duration: "18 秒",
    reason: "连续多拍，人物始终处于主要运动区域内。"
  },
  {
    type: "长跑动回合",
    time: "00:12",
    duration: "14 秒",
    reason: "球员横向跑动接近边线，云台轻量修正构图。"
  },
  {
    type: "精彩得分",
    time: "00:18",
    duration: "9 秒",
    reason: "识别到明显加速挥拍和回合结束动作。"
  }
];

const els = {
  mainAction: document.querySelector("#mainAction"),
  modeName: document.querySelector("#modeName"),
  guideToggle: document.querySelector("#guideToggle"),
  courtReference: document.querySelector("#courtReference"),
  instructionCard: document.querySelector("#instructionCard"),
  instructionTitle: document.querySelector("#instructionTitle"),
  instructionDetail: document.querySelector("#instructionDetail"),
  recordTime: document.querySelector("#recordTime"),
  storageText: document.querySelector("#storageText"),
  followText: document.querySelector("#followText"),
  saveState: document.querySelector("#saveState"),
  saveToast: document.querySelector("#saveToast"),
  toastReason: document.querySelector("#toastReason"),
  resultButton: document.querySelector("#resultButton"),
  resultDrawer: document.querySelector("#resultDrawer"),
  closeDrawer: document.querySelector("#closeDrawer"),
  clipList: document.querySelector("#clipList"),
  makeMovie: document.querySelector("#makeMovie")
};

els.mainAction.addEventListener("click", handleMainAction);
els.guideToggle.addEventListener("click", toggleGuide);
els.resultButton.addEventListener("click", openResultDrawer);
els.closeDrawer.addEventListener("click", closeResultDrawer);
els.makeMovie.addEventListener("click", () => {
  els.makeMovie.textContent = "集锦已生成";
});

render();

function handleMainAction() {
  if (state.phase === "guide") {
    startRecognition();
    return;
  }

  if (state.phase === "ready") {
    startRecording();
    return;
  }

  if (state.phase === "recording") {
    stopRecording();
  }
}

function startRecognition() {
  state.phase = "recognizing";
  render();

  setInstruction("正在识别球场线", "正在锁定底线、球网、发球线和推荐拍摄区域");
  els.modeName.textContent = "识别中";
  els.mainAction.disabled = true;

  setTimeout(() => {
    setInstruction("拍摄区域已锁定", "默认广构图开启，人物接近边缘时云台会轻量修正");
    state.phase = "ready";
    els.mainAction.disabled = false;
    render();
  }, 1800);
}

function startRecording() {
  state.phase = "recording";
  state.seconds = 0;
  state.storage = 0;
  state.clips = [];
  render();

  state.timer = window.setInterval(() => {
    state.seconds += 1;
    state.storage = state.seconds * 0.035;
    updateRecordingStatus();

    if ([6, 12, 18].includes(state.seconds)) {
      saveHighlight();
    }
  }, 1000);
}

function stopRecording() {
  window.clearInterval(state.timer);
  state.timer = null;
  state.phase = "ready";
  state.clips = state.clips.length ? state.clips : highlightPool.slice(0, 2);
  render();
  openResultDrawer();
}

function saveHighlight() {
  const clip = highlightPool[state.clips.length];
  if (!clip) return;

  state.clips.push(clip);
  els.saveState.textContent = `${clip.type} · 高清保存`;
  els.toastReason.textContent = clip.type;
  els.saveToast.classList.add("visible");

  window.setTimeout(() => {
    els.saveToast.classList.remove("visible");
    if (state.phase === "recording") {
      els.saveState.textContent = "正在识别重点片段";
    }
  }, 2100);
}

function updateRecordingStatus() {
  els.recordTime.textContent = formatTime(state.seconds);
  els.storageText.textContent = `存储 ${state.storage.toFixed(1)}GB`;
  els.followText.textContent = state.seconds % 4 === 0 ? "轻量修正中" : "云台自动跟随";
}

function toggleGuide() {
  state.guideVisible = !state.guideVisible;
  els.courtReference.classList.toggle("hidden", !state.guideVisible);
}

function openResultDrawer() {
  renderClips();
  els.resultDrawer.classList.add("visible");
}

function closeResultDrawer() {
  els.resultDrawer.classList.remove("visible");
}

function render() {
  els.mainAction.classList.toggle("recording", state.phase === "recording");
  els.mainAction.classList.toggle("confirm", state.phase === "guide" || state.phase === "ready");
  els.recordTime.classList.toggle("recording", state.phase === "recording");
  els.instructionCard.classList.toggle("compact", state.phase === "recording");

  if (state.phase === "guide") {
    setInstruction("网球模式", "请让球网、底线和主要跑动区域落入参考框");
    els.modeName.textContent = "确认取景";
    els.followText.textContent = "云台待命";
    els.saveState.textContent = "重点片段识别已开启";
  }

  if (state.phase === "ready") {
    els.modeName.textContent = "开始录制";
    els.followText.textContent = "云台待命";
  }

  if (state.phase === "recording") {
    setInstruction("云台自动跟随", "人物接近画面边缘时进行轻量修正，避免强追导致甩动");
    els.modeName.textContent = "结束拍摄";
    els.saveState.textContent = "正在识别重点片段";
    updateRecordingStatus();
  }
}

function renderClips() {
  const clips = state.clips.length ? state.clips : highlightPool.slice(0, 3);
  els.clipList.innerHTML = clips.map((clip, index) => `
    <article class="clip-item">
      <div class="clip-type">${clip.type}</div>
      <div>
        <strong>${clip.time} · ${clip.duration} · 高清保存</strong>
        <p>${clip.reason}</p>
      </div>
      <label>
        <input type="checkbox" checked />
        保留
      </label>
    </article>
  `).join("");

  els.makeMovie.textContent = "生成集锦";
}

function setInstruction(title, detail) {
  els.instructionTitle.textContent = title;
  els.instructionDetail.textContent = detail;
}

function formatTime(totalSeconds) {
  const minutes = String(Math.floor(totalSeconds / 60)).padStart(2, "0");
  const seconds = String(totalSeconds % 60).padStart(2, "0");
  return `${minutes}:${seconds}`;
}
