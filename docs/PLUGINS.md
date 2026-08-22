# DSH Web Profile 插件清单（PLUGIN INVENTORY）

> 来源：`C:\Users\pachu77\.dsh\profiles\web\package.json`（bundles）+ `~/.dsh/cordis.patch.yml`（home 层）+ `profiles/web/cordis.patch.yml`（profile 层）
> 快照时间：2026-08-15。本清单不过滤禁用项，全部列出。

## 一、Bundles（`dsh.profile.bundles`，按加载顺序）

| # | 包名 | 版本/来源 | 用途 | 备注 |
|---|---|---|---|---|
| 1 | `@deepseek-ai/dsh-base` | 内置（dsh 安装） | 核心运行时：llm / session / sandbox+approval / tools / agent-loop / goal / subagent / web_search / compaction 等 60+ 行 | 必需 |
| 2 | `@deepseek-ai/dsh-web-app` | 内置（dsh 安装） | Web 界面层：webserver / 前端 / api 网关 / UI 组件 / 会话投影 / 目录选择 | 必需 |
| 3 | `@dsh-external/dsh-client-ui-skin-maid-atelier` | `link:C:/Users/pachu77/dsh-plugins/dsh-deep-whale/maid-atelier` | maid-atelier 皮肤 | home 层已停用 |
| 4 | `@linxin666/dsh-skins` | `0.1.10` | 皮肤中心框架（dsh-skin managed 段管理皮肤互斥） | 启用 |
| 5 | `@linxin666/dsh-client-ui-web-ui-settings` | `0.1.10` | Web 设置面板增强 | 启用 |
| 6 | `@pakiknowledge/dsh-client-ui-skin-claude` | `^0.1.0` | claude 皮肤（npm 版，自带 patch 注入行） | 启用（当前激活皮肤） |
| 7 | `dshmarket` | `^1.2.4` | 插件市场：web 内一键安装/升级插件 | 启用 |
| 8 | `deepseek-harness-wallet` | `github:feibi-mochi/deepseek-harness-wallet` | 用量/钱包（余额、成本） | 启用 |
| 9 | `meow-memory` | `^0.1.0` | 跨会话项目记忆（PROJECT.md 注入 + memory_remember + 自动反思） | 启用 |
| 10 | `dsh-auto-classifier` | `^0.1.2`（npm） | auto（自主模式）权限分类器（我们自己发布） | 启用 |

## 二、Home 层禁用/注入行（`~/.dsh/cordis.patch.yml`）

- `ui-skin-maid-atelier`：disabled（2026-08-14 停用；删除该行可恢复）
- dsh-skin managed 段（自动生成，勿手改）：
  - disabled：`ui-skin-blue-fantasy` / `ui-skin-dragon-heir` / `ui-skin-miku` / `ui-skin-minecraft` / `ui-skin-ths` / `ui-skin-trading` / `ui-skin-whale-song` / `ui-skin-xp`
  - insert（disabled）：`ui-skin-qq98` → `@linxin666/dsh-client-ui-skin-qq98`

## 三、Profile 层（`profiles/web/cordis.patch.yml`）

- 空 `[]`（无自定义行；注意注释：dsh-premise-guard 已整体停用，勿加回）

## 四、皮肤状态小结

实际激活皮肤：**claude**（bundle `@pakiknowledge/dsh-client-ui-skin-claude`）。其余皮肤行全部 disabled。
