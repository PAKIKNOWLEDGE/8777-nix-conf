# dotfiles 同步系统参考手册

`dotfiles/` 是仓库里的一个"配置仓库"，用 `dotfiles/sync.sh` 在仓库和每台机器的 `~/.config/` 之间同步。

新机器流程看 [new-pc-guide.md](new-pc-guide.md)，这里是命令、规则和机制的完整参考。

## 设计思想

- **分层**：`common/` 是所有机器共用的基线，`hosts/<host>/` 是单台机器的覆盖层。
- **一个应用只归一层**：host 层里出现的应用**整体替换** common 里同名应用。
- **每台机器都有占位符**：`hosts/<host>/.gitkeep`，无论有没有专属配置。
- **命令式同步**：不是 home-manager 那种声明式。改配置 → `sync` 回写仓库 → commit；仓库 → `deploy` 下发。

## 目录结构

```
dotfiles/
├── sync.sh                  # 唯一入口
├── common/                  # 所有主机共用
│   ├── nvim/
│   ├── fish/
│   ├── i3/
│   └── …
└── hosts/
    ├── pain/                # pain: 占位符 + i3status-rust/ (无电池)
    │   ├── .gitkeep
    │   └── i3status-rust/
    └── thinkpadx250/        # 笔记本: 占位符 + i3status-rust/ (双电池 BAT0/BAT1)
        ├── .gitkeep
        └── i3status-rust/
```

> `.gitkeep` 只是让 git 追踪空目录的占位符，脚本会忽略它，不会当成应用同步。

## 分层规则

| 情况 | 放哪 |
|---|---|
| 所有机器配置一样 | `common/<app>/` |
| 只有某台机器不同 | `dotfiles/hosts/<那个host>/<app>/` |
| host 与 common 同名应用 | host 层**整体覆盖** common |

判断口诀：**这台机器跟别人一样 → common；不一样 → 它自己的 hosts 目录。**

### 回写归属规则

`sync.sh sync`（本地 → 仓库）时：
- 某应用在**当前主机的 host 层**存在 → 回写到 host 层
- 否则 → 回写到 common 层

即：host 层存在，host 层说了算。

## sync.sh 命令参考

| 命令 | 作用 | 说明 |
|---|---|---|
| `sync.sh deploy` | 仓库 → 本地 | 分层合并后预览，确认后部署 |
| `sync.sh deploy --yes` | 跳过确认 | 脚本/CI 用 |
| `sync.sh deploy --host X` | 指定主机 | hostname 识别失败时用 |
| `sync.sh sync` | 本地 → 仓库 | 回写本机改动，按归属规则落位 |
| `sync.sh diff` | 只预览差异 | 不写任何文件 |
| `sync.sh list` | 列出托管应用 | 标 ✅/⚠ 本地是否有 |
| `sync.sh init-host <代号>` | 新机器占位符 | 建 `hosts/<代号>/.gitkeep` |
| `sync.sh fish-links` | fish 便利链接 | `.fishrc` / `.fish_history` |
| `sync.sh help` | 帮助 | |

兼容旧写法：`--deploy`/`--sync`/`--list` 等同 `deploy`/`sync`/`list`。

### 例子

```bash
# 本机部署（先看 diff 再确认）
dotfiles/sync.sh deploy

# 直接部署不啰嗦
dotfiles/sync.sh deploy --yes

# 给新机器建占位符
dotfiles/sync.sh init-host minipc

# 把本机改动存回仓库
dotfiles/sync.sh sync && git add . && git commit

# 只看看仓库和本地差什么
dotfiles/sync.sh diff

# 部署到别的机器（模拟）
dotfiles/sync.sh deploy --host thinkpadx250
```

## 主机识别

识别顺序：

1. `--host X` 显式指定
2. `hostname` → 查 `HOST_ALIASES` 映射
3. `hosts/<hostname>` 直接命中
4. 大小写不敏感兜底
5. 都没有 → 提示"仅同步 common"，不报错

`HOST_ALIASES` 在脚本顶部：

```bash
# hostname 与目录名不一致时登记: "机器hostname:目录名"
HOST_ALIASES=(
  "K1llingMyL0v3:thinkpadx250"
)
```

## 安全机制

1. **`--delete` 只作用于托管应用**：部署时对每个应用目录独立 `--delete`，绝不碰 `~/.config` 里未托管的配置。
2. **备份**：被覆盖/删除的旧文件自动挪到 `~/.config/.dotfiles-backup/<时间戳>/`，不污染应用目录。
3. **回写不用 `--delete`**：`sync.sh sync` 不会从仓库删文件，安全。
4. **deploy 前强制预览**：先 dry-run 展示差异，除非 `--yes`。

## 排除清单（EXCLUDE）

脚本顶部只有一份：

```
.git, .gitkeep, *.bak, *.log, lazy-lock.json, generated.lua,
completions/, conf.d/, functions/, __pycache__/
```

这些是"生成的不该入库"的内容（nvim 的 lock、fish 自动生成的目录等）。
要加排除项：只改脚本顶部一处，所有同步自动生效。

## 场景

### 新加一台机器

```bash
sync.sh init-host <代号>     # 占位符（必须）
sync.sh deploy               # 部署公共配置
# 有专属配置 → 放 hosts/<代号>/ 下再 deploy
```

### 把某个应用从 common 拆成按机器分

1. 把 `common/<app>/` 移到目标机器的 `hosts/<host>/<app>/`
2. 其他机器想要各自版本 → 各自建 `hosts/<host>/<app>/`
3. 谁都不该共享 → 删掉 common 里那份

### 新机器装状态栏（i3status-rust 实例）

- 包在 `configuration.nix` 公共 `systemPackages`，NixOS 构建就有
- 配置按机器分：`hosts/pain/i3status-rust/`（无电池）vs `hosts/thinkpadx250/i3status-rust/`（双电池）
- 新机器照此建自己的 `hosts/<代号>/i3status-rust/`

## 排障

| 现象 | 处理 |
|---|---|
| deploy 提示"已是最新"但本地不对 | `sync.sh diff` 看差异；确认归属层放对 |
| 识别不到主机 | `--host X` 指定；或 `HOST_ALIASES` 加映射 |
| 覆盖后想后悔 | `~/.config/.dotfiles-backup/` 找时间戳备份 |
| 备份占满磁盘 | 删旧备份目录即可，不影响任何配置 |
| 一个应用出现在两个 host 层 | 归属规则让 host 层赢；把多余的挪走 |

## 注意事项

- 这套是**命令式**同步，仓库是源。`sync` 回写后记得 commit，否则换机器拿不到。
- `deploy` 的预览是"相对当前主机的"，`--host X` 部署别台机器时先想清楚。
- 别让两台机器同时 `sync` 同一个 common 应用——冲突由你手动解决。
