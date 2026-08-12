# 文档索引

这套配置分两层，注意别搞混两套 `hosts/`：

```
仓库根
├── hosts/<Host>/            NixOS 系统层: 每台机器的硬件/服务差异 (代号习惯大写)
├── dotfiles/hosts/<host>/   dotfiles 配置层: 每台机器的应用配置差异 (代号习惯小写)
├── configuration.nix        NixOS 公共配置
├── home.nix                 home-manager 用户级配置
├── flake.nix                入口: 双主机 + HM
└── dotfiles/sync.sh         配置层同步入口
```

| 文档 | 用途 |
|---|---|
| [new-pc-guide.md](new-pc-guide.md) | **新机器接入**：NixOS + dotfiles 端到端流程，照着做就行 |
| [dotfiles-guide.md](dotfiles-guide.md) | **dotfiles 同步系统参考**：分层规则、sync.sh 全部命令、安全机制、排障 |

快速对照：

- **系统层**（哪台机器装什么软件/服务）→ `hosts/<Host>/`（NixOS，走 flake 构建）
- **配置层**（哪台机器的 dotfile 不同）→ `dotfiles/hosts/<host>/`（rsync，走 `sync.sh`）
- 两层都要求：**新机器必留占位符**（NixOS 侧建目录，dotfiles 侧跑 `sync.sh init-host`）
