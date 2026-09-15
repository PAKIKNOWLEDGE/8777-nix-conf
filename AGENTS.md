# AGENTS.md — 仓库工作约定

给所有进入本仓库的 coding agent（以及人类协作者）的操作规程。
详细文档在 `docs/`，本文只写"动手前必须知道的事"。

## 这个仓库是什么

三台机器的 NixOS flake 配置 + dotfiles 同步系统。远程：
`github.com/PAKIKNOWLEDGE/8777-nix-conf`。

```
flake.nix              入口，注册 3 个 nixosConfiguration + 1 个 homeConfiguration
configuration.nix      公共系统层（不要在这里写单机差异）
home.nix               Home Manager 用户层（大体积 GUI 包在这，加速系统构建）
hosts/<Machine>/       单机层: default.nix(差异) + hardware.nix(机器专属, 每机生成)
dotfiles/              第二套配置体系 —— 见"双轨制"一节，动它之前必读
docs/                  运维手册（new-pc-guide / dotfiles-guide / DESIGN_NOTES）
```

## 硬规则

1. **这是活系统，不是玩具仓库。** pain / ThinkPadX250 / T430 三台真机跑着这里的
   配置。任何改动默认只编辑文件；`nixos-rebuild` / `home-manager switch` /
   `sync.sh deploy` 这类**落到机器的动作由人类执行**，agent 不代跑。
2. **验证用无副作用命令**：`nix flake check`、`nix eval .#nixosConfigurations.<机>.config.networking.hostName`、
   `bash -n dotfiles/sync.sh`、`sync.sh diff`（只读干跑）。
   测试脚本行为用 `/tmp` 下的仓库副本 + 伪造 `HOME` 沙箱，测完销毁。
   沙箱/受限环境下跑 nix 命令需重定向缓存目录
   （`XDG_CACHE_HOME=/tmp/nixcache XDG_STATE_HOME=/tmp/nixstate`），
   否则 `~/.cache/nix/fetcher-cache-*.sqlite` 只读报错导致 flake 拉取失败。
3. **`hardware.nix` 不跨机复制。** 每台机器的在自己 `hosts/<Machine>/` 里生成，
   内容互不兼容。
4. **中文注释是本仓库风格**，解释"为什么"而非"是什么"。已有大段 rationale
   注释（nix-ld、EDID 注入、镜像选型）是历史决策记录，不要删，不要翻译成英文。
   代码标识符、命令、路径保持英文。
5. **commit 信息**：现有历史是简短中英混排（"added X"、"优化 fish 的代理开关逻辑"）。
   涉及行为变化的改动要写详细 body：现象 → 根因 → 修复 → 验证记录，供复核。
6. **不要新增 `.claude/`、`.mimocode/`、`.qoder/` 这类工具私有目录的入库文件**——
   agent 记忆/规则统一写进本文件（AGENTS.md 是跨工具事实标准，Qoder/Claude/Codex 等都读它）。
7. `nixpkgs-25-11` 这个 pin 是为 krita 字体菜单 bug 留的 workaround，别顺手"清理"。

## 双轨制：NixOS/HM 层 vs dotfiles/sync.sh 层

配置分布在两个互不知晓的系统里，这是本仓库最大的架构债（已知问题，暂不收敛）：

- `home.nix`（声明式）管：git、bash、用户级大包。
- `dotfiles/sync.sh`（命令式 rsync）管：`~/.config` 下约 25 个应用。

规则：
- 一个应用**只归一层**。新配置先进 sync.sh 体系（`dotfiles/common/<app>/`），
  除非它是 `programs.*` 模块已有的（git、ssh 等）。
- `common/` 是基线，`dotfiles/hosts/<machine>/` 整体覆盖同名应用。回写归属同理：
  host 层存在则归 host，否则归 common。
- **永远不要往 `~/.config` 直接写托管应用的配置再指望 git diff 能看懂**——
  用 `sync.sh sync` 回写，它会按归属规则落位。
- sync.sh 的差异判据是内容比较（rsync `-c`），预览（dry-run）与真实部署同一判据、
  同一 EXCLUDE。修改输出逻辑时保持这两处共用，历史上曾漂移过。
- `EXCLUDE` 数组（脚本顶部）是唯一一份排除清单，deploy/sync/diff 三处共用，
  别在任何一处内联复制。

## 已知问题清单（可修，修前报告）

- ~~`dotfiles/common/btop/btop.log` 与 `dotfiles/common/fish/fish_variables`
  仍被 git 跟踪~~ 已处理（2026-09-15）：两者 `git rm --cached` 取消跟踪 + 写进
  `.gitignore`，磁盘文件保留。`deploy` 的 staging 组装阶段本就带 `EXCLUDE`
  （含 `*.log`），所以它们不进 staging，`--delete` 不会波及本机已有的同名文件。
- `configuration.nix` 的陈旧注释已处理（2026-09-15）：onlyoffice 那段历史注释补了
  "现状核对"（krita 仍在且 pin 在 25.11、onlyoffice 已移除），硬件配置"仓库里不跟踪"
  的错误说法改成实际做法（按 hosts/<机器>/hardware.nix 入库、三台各一份）。
  `imports = [ ]` 仍在——它是上方 imports 教学注释的落点，删这行属行为/风格判断，未动。
- `home.nix` 的 `programs.bash.initExtra` 配了 starship，但用户 shell 是 fish——死配置。
- T430 是常开网关（hostname `Gater`），但防火墙在公共层全局关闭。
- `docs/PLUGINS.md` 来源不明（DSH 插件清单），与仓库主题关系弱。

## 环境事实

- 本机 hostname `K1llingMyL0v3` = ThinkPadX250（`sync.sh` 的 HOST_ALIASES 有映射）。
- 网络在中国大陆，一切 nix/uv/cargo 拉取优先国内镜像（清单见 README"Mirrors"节
  与 `setup-mirrors.sh`）。
- 当前用户 `pakiknowledge`，uid 与 flake 中用户名硬编码一致——改用户名是破坏性变更。

## 新机器接入

三步必须同步做（详见 `docs/new-pc-guide.md`）：
1. `hosts/<Name>/default.nix` + `hardware.nix`
2. `flake.nix` 注册 `nixosConfigurations.<Name>`（注意大小写：现有目录用
   `ThinkPadX250`/`T430` 大写，dotfiles 层用小写 `thinkpadx250`/`t430`，
   sync.sh 靠 HOST_ALIASES 桥接，新增机器时两层都要登记）
3. `dotfiles/hosts/<小写名>/`（`sync.sh init-host <小写名>`）
