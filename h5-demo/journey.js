// 用户旅程地图数据：来自 PRD 和“用户旅程地图.md”，用于渲染 H5 可视化。
const stages = [
  {
    title: "到达球场",
    short: "想记录训练/对打",
    goal: "在无人协助的情况下，把今天的训练或对打完整记录下来。",
    action: "寻找场边、底线后方或侧后方可架设云台的位置。",
    thought: "我想拍到完整回合，但没人帮我盯画面。",
    pain: "不确定这个机位能不能覆盖横向跑动和发球动作。",
    touchpoint: "模式入口、机位建议",
    opportunity: "用一句话明确推荐高度、位置和横屏方向。",
    emotion: 3
  },
  {
    title: "架设设备",
    short: "快速选模式，别让朋友等",
    goal: "快速进入可拍状态，减少调试时间和社交压力。",
    action: "打开云台连接手机，在拍摄页尽快切到网球模式，避免反复挑模式和调参数。",
    thought: "朋友在等我，场地费也在烧，最好别让我挑太久。",
    pain: "调试和模式选择耗时长，会造成朋友等待的尴尬，也浪费昂贵场地时间。",
    touchpoint: "拍摄页模式栏、默认参数、快速确认入口、云台连接状态",
    opportunity: "网球模式应尽量一键进入，默认开启横屏、广构图、自动识别和重点保存，减少用户在参数中反复选择。",
    emotion: 2
  },
  {
    title: "场地标尺取景",
    short: "快速取景，也拍得好看",
    goal: "场上没有自己时，也能确认画面覆盖正确，同时让人物比例更好看。",
    action: "根据参考框对齐球网、底线、单双打边线和发球线，并把设备架在腰部偏高一点。",
    thought: "我不在画面里，只能靠球场结构判断；机位如果偏高一点，腿会显得更长。",
    pain: "不能用人物作为构图参照；架太低容易显矮、画面像监控，架太高又可能压缩发球和挥拍空间。",
    touchpoint: "网球场参考框、画面覆盖确认按钮、机位高度建议",
    opportunity: "用球网和底线作为核心标尺；高度建议从“腰到胸口”细化为“腰部偏高到下胸口”，兼顾覆盖范围和人物比例。",
    emotion: 4
  },
  {
    title: "开拍确认",
    short: "一眼确认范围",
    goal: "范围够了就立刻开拍，减少朋友等待和场地费浪费。",
    action: "查看实时拍摄范围和参考框，确认覆盖完整半场/全场后点击录制。",
    thought: "我一眼就能看出拍摄范围够不够，别再让我等一个识别过程。",
    pain: "如果额外出现“识别锁定”等等待，会显得像伪场景，反而增加调试时间和焦虑。",
    touchpoint: "实时预览、取景参考框、开始录制按钮",
    opportunity: "把算法准备后台化，不把“识别锁定”做成主路径；只有画面明显不可用时再提示手动调整。",
    emotion: 5
  },
  {
    title: "无人值守拍摄",
    short: "进入场内打球",
    goal: "专心打球，不再回来看手机。",
    action: "点击录制后进入场内训练或对打。",
    thought: "希望我跑动和发球时不要出画。",
    pain: "网球横向移动大，强追踪容易甩动，固定机位又容易出画。",
    touchpoint: "云台自动跟随状态、录制时间、电量、存储",
    opportunity: "采用轻量跟随修正，人物接近边缘时再微调构图。",
    emotion: 5
  },
  {
    title: "重点片段保存",
    short: "自动保存高价值回合",
    goal: "不用赛后翻几十分钟素材。",
    action: "系统识别多拍回合、长跑动回合、精彩得分并高清保存。",
    thought: "有价值的片段最好自动留下。",
    pain: "整场高清保存占空间，普通片段筛选成本高。",
    touchpoint: "已自动保存高清片段提示、保存策略面板",
    opportunity: "重点高清保存，普通低清缓存，无效短期缓存。",
    emotion: 5
  },
  {
    title: "结果复盘",
    short: "选择保留/删除",
    goal: "快速知道本场哪些片段值得保留。",
    action: "查看重点片段列表，按类型、时间点、时长和理由筛选。",
    thought: "我只想保留真正有用的内容。",
    pain: "片段没有推荐理由时，用户仍然要逐个点开判断。",
    touchpoint: "结果页片段卡片、推荐理由、节省空间提示",
    opportunity: "让每个片段解释为什么被保存，降低决策成本。",
    emotion: 5
  },
  {
    title: "生成集锦",
    short: "产出可分享内容",
    goal: "把保留片段快速生成可分享视频。",
    action: "点击生成集锦，进入剪辑草稿或导出流程。",
    thought: "这场球能不能马上发出去？",
    pain: "手动剪辑门槛高，容易放弃分享。",
    touchpoint: "生成集锦按钮",
    opportunity: "用已选高清片段自动串联成短视频草稿。",
    emotion: 5
  }
];

const rows = [
  ["用户行为", "action"],
  ["用户想法", "thought"],
  ["核心痛点", "pain"],
  ["产品触点", "touchpoint"],
  ["设计机会", "opportunity"]
];

let activeIndex = 0;

const track = document.querySelector("#journeyTrack");
const detail = document.querySelector("#detailCard");
const swimlane = document.querySelector("#swimlane");
const emotionLine = document.querySelector("#emotionLine");
const emotionPoints = document.querySelector("#emotionPoints");

renderTrack();
renderDetail();
renderSwimlane();
renderEmotionChart();

function renderTrack() {
  track.innerHTML = stages.map((stage, index) => `
    <button class="stage-node ${index === activeIndex ? "active" : ""}" type="button" data-index="${index}">
      <span class="stage-dot">${index + 1}</span>
      <span class="stage-copy">
        <strong>${stage.title}</strong>
        <span>${stage.short}</span>
      </span>
    </button>
  `).join("");

  track.querySelectorAll(".stage-node").forEach((node) => {
    node.addEventListener("click", () => {
      activeIndex = Number(node.dataset.index);
      renderTrack();
      renderDetail();
    });
  });
}

function renderDetail() {
  const stage = stages[activeIndex];
  detail.innerHTML = `
    <div class="detail-header">
      <div>
        <h3>${stage.title}</h3>
        <p class="goal">${stage.goal}</p>
      </div>
      <span class="detail-index">阶段 ${activeIndex + 1}</span>
    </div>
    <div class="detail-grid">
      ${detailItem("用户行为", stage.action)}
      ${detailItem("用户想法/情绪", stage.thought)}
      ${detailItem("核心痛点", stage.pain)}
      ${detailItem("产品触点", stage.touchpoint)}
      ${detailItem("设计机会", stage.opportunity)}
      ${detailItem("满意度", `${stage.emotion} / 5`)}
    </div>
  `;
}

function detailItem(title, content) {
  return `
    <div class="detail-item">
      <b>${title}</b>
      <p>${content}</p>
    </div>
  `;
}

function renderSwimlane() {
  const header = `<div class="lane-cell header">阶段</div>${stages.map((stage) => `
    <div class="lane-cell header">${stage.title}</div>
  `).join("")}`;

  const body = rows.map(([label, key]) => `
    <div class="lane-cell label">${label}</div>
    ${stages.map((stage) => `<div class="lane-cell">${stage[key]}</div>`).join("")}
  `).join("");

  swimlane.innerHTML = `<div class="swimlane-grid">${header}${body}</div>`;
}

function renderEmotionChart() {
  const left = 54;
  const right = 720;
  const top = 38;
  const bottom = 206;
  const step = (right - left) / (stages.length - 1);
  const points = stages.map((stage, index) => {
    const x = left + step * index;
    const y = bottom - ((stage.emotion - 1) / 4) * (bottom - top);
    return { x, y, stage };
  });

  emotionLine.setAttribute("points", points.map((point) => `${point.x},${point.y}`).join(" "));
  emotionPoints.innerHTML = points.map((point) => `
    <circle class="point" cx="${point.x}" cy="${point.y}" r="8"></circle>
    <text class="point-label" x="${point.x}" y="${point.y - 16}" text-anchor="middle">${point.stage.emotion}</text>
  `).join("");
}
