# ref-notes — 借鉴 hakula139/nixos-config 的待落地项

来源：朋友（大厂程序员）的公开仓库 https://github.com/hakula139/nixos-config
本地克隆：X250/T430 各自 `~/文档/nixos-config/`
结论速览：值得抄的是结构纪律，不是平台抽象。按性价比排序如下，
动手时机自定，均为"看着修复"候选项。

## 1. GitHub Actions CI（白嫖，最先做）

本仓库是公开库，GitHub Actions 对 public repo 免费无限跑。
加一个 `.github/workflows/ci.yml`，每次 push 自动：

- `nix flake check`（结构/参数校验）
- `statix`（nix lint）
- `bash -n dotfiles/sync.sh`（脚本语法）

收益：坏配置在 push 时标红，不用等 nixos-rebuild 到一半才炸。
参考他仓库 `.github/workflows/ci.yml` 改写即可。

## 2. 机器事实集中化（data/ 户口本思想）

现状病根——同一台机器的事实登记在三处：

- `flake.nix`：`T430` / `ThinkPadX250`（大写目录名）
- `dotfiles/hosts/`：`t430` / `thinkpadx250`（小写）
- `dotfiles/sync.sh`：`HOST_ALIASES` 数组做 hostname↔别名桥接

HOST_ALIASES 重复声明事故（commit a2845a5）就是"一个事实抄多份"的病。

解法：新建 `data/hosts.nix` 作为唯一清单（机器名、大小写别名、hostname、
IP、角色），flake 注册与 sync.sh 都从它派生/读取。
第四台机（捡垃圾装机）接入时只改一处。

## 3. nh 外壳（nix-health）

他的 `nixsw`/`nixgc` 别名体系：

- `nh os switch .` — 比裸 nixos-rebuild 输出干净
- `nh clean all --keep-since 3d` — 按时间保留 GC，
  不搞"今天装明天蒸发"（rustc 被 GC 误伤属同类问题）

X250 与 T430 都适用；装进 systemPackages + fish alias 即可。

## 4. 模块化拆分（_profiles 双层结构）

他的结构：`hosts/_profiles/platform/`（硬件形态）+ `role/`（系统角色），
host 目录只剩"注册 + 差异"。

我方对应改法：

```
profiles/
  role/gateway.nix     # 无头基线 + logind ignore + 常驻服务
  role/desktop.nix     # XFCE/i3 + GUI 大件（firefox 保留在 T430，见安全条目）
```

T430 先只吃 desktop 里用不上的部分剥离（kate/录屏下线，
kate 是 KDE 依赖链入口，gnupg 即被其拖入）。
裸 TTY 跑 gateway 没验证过之前，XFCE 保留当救生艇。
注意：桌面层（xfce/i3/matugen）他没经验可抄，此领域本仓库自养。

## 明确不抄（记录理由，防下次心动）

- **agenix**：单人三台机过重。但理念留档——secrets 加密进 git、
  agent clone 也读不到，与"agent 不得碰基模/auth"的立场同构。
- **builders.nix 五平台抽象**：无 macOS/WSL/容器需求，抄了是负资产。
- **nushell 规范**：本人不用 nushell；他文档里十几条陷阱清单恰好
  证明迁移成本真实存在，观望即可。
- **systemd unit hardening 层**：等 T430 常驻服务多起来再回头看。

## 关联

- MindCache note: `t430-slimming-plan-pending`（瘦身/止血/桥接）
- MindCache idea: `nixos-config 朋友仓库观察`（设备构成等背景）
