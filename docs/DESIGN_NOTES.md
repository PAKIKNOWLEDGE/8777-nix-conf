# DESIGN_NOTES — docs/ 静态文档站

## 方向（2026-08-12 首版）

把 `docs/` 三份 Markdown（索引 / 新机器接入指南 / dotfiles 参考手册）做成
静态站：`index.html` + `new-pc-guide.html` + `dotfiles-guide.html` + 共享
`style.css` / `script.js`。纯文件协议可打开，无外部资源依赖。

### 设计 token

- SUBJECT：`~/nix/nixos` 运维手册 — 双机（pain / thinkpadx250）NixOS +
  dotfiles 同步系统；job：新机器照着做 / 随时查命令
- COLOR：
  - `--paper #F4F6F8` 阴天色页面底
  - `--surface #FFFFFF` 卡片
  - `--ink #1B2733` 近黑蓝正文
  - `--slate #55677A` 次级文字
  - `--nix #5277C3` NixOS 蓝主强调；`--nix-deep #3B5AA6` 文本级强调
  - `--code #1D2733` 代码块近黑蓝底
  - `--alert #B4432C` 仅"必须/教训"语义（红砖色，克制使用）
- TYPE：中英文分治（四版定稿）：
  - 中文/正文/标题 = `Sarasa Gothic SC`（--sans / --display，仅字重字号分层）
  - 代码、命令、路径、机器名、拉丁标签 = 等宽 `JetBrainsMonoNL Nerd Font`
    （--mono，NL = 无连字；CJK 字符在等宽栈内 fallback 回 Sarasa）。
    历史：首版宋体 → 二版全更纱 → 三版一度禁等宽（用户纠正）→ 四版
    "该等宽的地方等宽"，目录树注释列对齐随之恢复
- LAYOUT：索引 = 双层结构图 + 舰队条 + 入口卡；指南页 = 吸顶 TOC + 单栏
  46rem 阅读列；表格 hairline + 圆角容器
- SIGNATURE：命令块方向标签（↓ 下发 / ↑ 回写 / ＋ 占位 / 构建 / 配置 /
  检查 / 生成 / 拉取）——sync 系统的方向语义即信息
- RISK：命令方向标签 + 双层结构图作为记忆点；刻意避开暗底+荧光绿、
  米白+赭石、broadsheet 三个默认簇。二版起全站 Sarasa 统一字族，层级
  靠字重/字号拉开（无衬线字族，不再有 serif/sans 对比）

### 反默认检查（self-simulation）

通用 SaaS 落地页会得到：白底+黑体+单一强调色+hero 大标题。
对比：本设计以"双层结构图 + 舰队芯片 + 命令方向标签"为核心，标题宋体，
全部来自内容本身的真实语义（层、机器、同步方向），不是套模板。

### 验证记录

- 环境无 headless 浏览器，无法截图；采用代码级核对：
  - 三个 HTML 标签配对校验通过（node 脚本）
  - md 关键内容全部转写抽查通过
  - 对比度：正文/slate 文字 ≥ 4.5:1；wordmark 与 sync 箭头初始用
    `--nix` 小字号仅 4.4:1 → 改为 `--nix-deep`（6.5:1）
  - 字体（二版）：`fc-list` 确认 sarasa-gothic 1.0.37 已装；`fc-match`
    验证 `Sarasa Gothic SC` / `Sarasa Mono SC`（Regular+Bold）均能解析
  - 字体（三版）：应要求去掉等宽，`Sarasa Mono SC` 不再使用，代码/表格
    全部改走 `Sarasa Gothic SC`；小标签 letter-spacing 相应收紧
    （0.12–0.16em 按等宽设计，CJK 标签改 0.04em）
  - 字体（四版）：用户纠正"不是全禁等宽，该等宽的要等宽"——恢复 --mono，
    英文等宽改用已装的 `JetBrainsMonoNL Nerd Font`（nerd-fonts 3.4.0，
    fc-match 验证 Regular/Bold 可解析）；等宽用于命令块/行内代码/路径/
    机器名/拉丁标签，中文标签保持更纱；目录树注释列对齐恢复
  - 375px：表格/代码横向滚动容器；顶栏压缩后不溢出；触控目标 ≥44px
  - 动效全部包在 `prefers-reduced-motion` 守卫内

### 待做 / 可改进

- 若后续要发布到网上，可把相对链接换成绝对路径并加 favicon
- `script.js` 的复制按钮在 file:// 协议下走 execCommand 兜底，已验证
- 内容若更新，需同步改对应 HTML（目前是手写转写，非生成式）
