# 健壮性待办

2026-10-16 评估后记下的缺口。这里只记录，**未授权不要改配置**。
T430 退休是运行状态，不是删除授权：flake 条目、`hosts/T430/`、`dotfiles/hosts/t430/` 都留着。

在役：ThinkPadX250（hostname `K1llingMyL0v3`）、pain。
搁置：T430（hostname `Gater`）。

已修（同日）：`dotfiles/sync.sh` 主机识别失败直接退出（退出码 1），不再退回「仅同步 common」。
`deploy` 退回会用公共配置盖掉本机 host 层，`sync` 退回会把本机 `~/.config` 写进 `common/`。

## T430（退休搁置）

重新启用之前先看完本节。不要为了“看着碍事”删配置，也不要在公共层顺手改防火墙。

### 防火墙关在公共层

`configuration.nix` 里 `networking.firewall.enable = false`，三台机器一起生效。
T430 曾经是常开网关，这台机器醒着的时候等于没有主机防火墙。

pain 和 X250 现在也是关的。重新打开如果写在 `configuration.nix`，两台在役机器的网络行为会一起变。要动的话做到 `hosts/T430/default.nix`，不要动公共层。

### 隧道不在 Nix 里

`hosts/T430/default.nix` 只把 `cloudflared` 放进 `environment.systemPackages`，没有 systemd 服务，也没有隧道参数。
同文件里的 `services.logind` 把合盖三种情况都设成 `ignore`，只保证机器不休眠，不保证隧道进程还在。

安装步骤在 [hermes-agent.md](hermes-agent.md)，仍是 `curl | bash`，依赖 python3.11 和 uv，脚本来源不稳定。重装系统之后，`nixos-rebuild` 不会把网关功能带回来。

### 网关和桌面叠在同一份公共层

ly / XFCE / i3 / PipeWire 都在 `configuration.nix`，T430 作为网关时照单全收。
[ref-notes.md](ref-notes.md) 里的 `profiles/role/gateway.nix` 是以后的拆法，T430 搁置期间不要做这轮瘦身。

## 在役机器

### X250 的 tlp 没有服务

`hosts/ThinkPadX250/default.nix` 把 `tlp` 放进 `systemPackages`。省电策略来自 `services.tlp.enable`，这条没写，装上的只是二进制。

`hosts/ThinkPadX250/hardware.nix` 的 `swapDevices` 是空的，也没有 zram。内存顶满时直接 OOM。

### 一台机器要生效三次

系统、用户包、家目录各走各的，互不触发：

| 路径 | 命令 |
|---|---|
| 系统 | `nixos-rebuild switch --flake .#<Host>` |
| 用户包 / git | `home-manager switch --flake .#pakiknowledge` |
| `~/.config` | `dotfiles/sync.sh deploy` |

漏一次，这台机器就和仓库不一致。仓库里没有 CI，`nix flake check` 靠人记得跑。要加的话见 [ref-notes.md](ref-notes.md) 第 1 节，先别加。

### 回滚窗口是 7 天

`configuration.nix` 里 `nix.gc` 每周跑，`options = "--delete-older-than 7d"`。
systemd-boot `configurationLimit = 5`。过了一周才发现的问题，旧 generation 的 store 路径可能已经清掉。

## 上游版本：由 pin 决定，不跟上游

### firefox 落后 6 个 feature release（2026-10-24 核对）

`configuration.nix` 里只有 `programs.firefox.enable = true;`，没有任何版本约束，所以浏览器版本
完全等于 `flake.lock` 主 pin 里 nixpkgs 的 firefox。核对时：

| 项 | 值 |
|---|---|
| 主 pin | `nixos-26.05` rev `4382ed2b`，`lastModified` = 2026-07-16 08:11 CST |
| pin 里的 firefox | `152.0.6` |
| 实机 | `/nix/store/id170z3x…-firefox-152.0.6`，系统代际 `26.05.20260716.4382ed2` |
| 上游同时点 | `158.0.1`（`LAST_RELEASE_DATE: 2026-10-23`），ESR `153.5.1esr` |

复现（只读）：

```bash
# pin 时间戳（仓库里没装 jq，用 nix 读；受限环境需另外重定向 XDG_CACHE_HOME/XDG_STATE_HOME）
date -d @$(nix eval --raw --impure --expr '(builtins.toString (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked.lastModified)')
nix eval --raw .#nixosConfigurations.ThinkPadX250.config.programs.firefox.package.version
curl -s https://product-details.mozilla.org/1.0/firefox_versions.json | grep -E 'LATEST_FIREFOX_VERSION|LAST_RELEASE_DATE'
```

差 6 个 feature release、约 3 个月安全更新。版本区间上落在 `CVE-2026-106016`
（File Handling 的 mitigation bypass，157.0.1 修复，NVD CVSS 3.1 9.8，CPE `firefox < 157.0.1`）
的受影响范围内，但 CISA SSVC 当时为 `exploitation: none`、`automatable: yes`，即没有在野利用证据。
2026-10-24 用 we-have-a-problem.com 自查的结论是「本机火狐无安全问题」，那一结论对应的是上面
`exploitation: none` 这一点（没有在野利用证据）。两条记录并存、互不冲突：一条是暴露风险评估，
一条是版本事实。区别在于，前者的结论会随利用态势变化（`automatable` 是 `yes`），后者不会自己变。

收法（人执行，先 build 不 switch）：`nix flake update nixpkgs` → 看 `git diff flake.lock` →
`sudo nixos-rebuild build --flake .#ThinkPadX250` → 满意再 `switch`。
krita 走 `home.nix` 里的 `pkgs-25-11.krita`，主 pin 更新不会碰它，25.11 的 lock 条目也不动；
但主 pin 从 7 月跳到 10 月会连带内核与 systemd，不只是浏览器。

### PHP2Shell：零暴露（2026-10-24 排查）

`CVE-2026-109618` / `CVE-2026-109619`，2026-10-21 发版，修 8.2.35 / 8.3.36 / 8.4.27 / 8.5.12，
均为未授权 RCE（CVSS v4.0 9.2），影响所有对外提供 web 请求的 PHP。

全仓库 `php` 的命中只有两处纯装饰引用：`dotfiles/common/starship-*.toml` 的 `$php` 提示符模块，
和 `dotfiles/common/matugen/templates/yazi-theme.toml` 的 `blade.php` / `php` 文件图标映射。
没有 `pkgs.php`，没有 PHP-FPM / mod_php / nginx+php 任何服务定义。

结论：三台机器都没有可被打的 PHP 进程，不在影响面内，**不需要动作**。
本条留着，下次同类预警可以直接复用这个结论，不用重查。

## 较小，特定时刻才会绊人

- 用户名 `pakiknowledge` 写在 `configuration.nix` 的 `users.users`、`home.nix` 的 `home.username` / `home.homeDirectory`、`flake.nix` 的 `homeConfigurations.pakiknowledge`、`nix.settings.trusted-users`。改名会同时拆登录、home-manager 和信任用户。
- 同一台笔记本三个名字：flake 条目 `ThinkPadX250`、hostname `K1llingMyL0v3`、dotfiles 目录 `thinkpadx250`。`sync.sh init-host` 把代号转成小写，提示里却让人拿这个小写名去注册 `nixosConfigurations`，和现有大写目录习惯不一致。
- `programs.nix-ld.libraries` 只有 `tree-sitter`、`stdenv.cc.cc.lib`、`glib`、`zlib`。缺库是跑起来才失败，构建阶段发现不了。
- `home.nix` 的 `programs.bash.initExtra` 配了 starship，登录 shell 是 fish，这段不会执行。AGENTS.md 已知问题里也有这条。
