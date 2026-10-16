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

## 较小，特定时刻才会绊人

- 用户名 `pakiknowledge` 写在 `configuration.nix` 的 `users.users`、`home.nix` 的 `home.username` / `home.homeDirectory`、`flake.nix` 的 `homeConfigurations.pakiknowledge`、`nix.settings.trusted-users`。改名会同时拆登录、home-manager 和信任用户。
- 同一台笔记本三个名字：flake 条目 `ThinkPadX250`、hostname `K1llingMyL0v3`、dotfiles 目录 `thinkpadx250`。`sync.sh init-host` 把代号转成小写，提示里却让人拿这个小写名去注册 `nixosConfigurations`，和现有大写目录习惯不一致。
- `programs.nix-ld.libraries` 只有 `tree-sitter`、`stdenv.cc.cc.lib`、`glib`、`zlib`。缺库是跑起来才失败，构建阶段发现不了。
- `home.nix` 的 `programs.bash.initExtra` 配了 starship，登录 shell 是 fish，这段不会执行。AGENTS.md 已知问题里也有这条。
