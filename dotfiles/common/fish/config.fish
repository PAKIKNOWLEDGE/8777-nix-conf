#环境变量/nix
set PATH $PATH /home/pakiknowledge/.local/bin
set -gx PATH "$HOME/.nix-profile/bin" $PATH
# ===== Bun 全局包目录 =====
fish_add_path "$HOME/.bun/bin"
# ===== 代理开关 =====
function proxy-on
    set -gx http_proxy "http://127.0.0.1:7897"
    set -gx https_proxy "http://127.0.0.1:7897"
    set -gx all_proxy "socks5://127.0.0.1:7897"
    echo "✅ 代理已启用 (http://127.0.0.1:7897)"
end

function proxy-off
    set -e http_proxy
    set -e https_proxy
    set -e all_proxy
    echo "❌ 代理已关闭"
end

# 关闭欢迎语
set fish_greeting ""
# 优先加载本地 bin
set -p PATH ~/.local/bin ~/.cargo/bin ~/.npm-global/bin

# starship 提示符
set -x STARSHIP_CONFIG ~/.config/starship-fish.toml
starship init fish | source
# zoxide 智能跳转
zoxide init fish --cmd cd | source

# 别名
alias power='upower -i $(upower -e | grep 'BAT') | grep percentage' # 双电池用
alias ship='nix-shell -p updog --run "updog -d $(pwd)"'
alias cl='clear'
alias tree='lt'
alias homebuild='home-manager switch --flake .'
alias today='date +%F'
# yazi 退出后自动 cd 到浏览目录
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# bat 代替 cat
function cat
    command bat $argv
end

# grep 交互时走 ripgrep（正则更快、默认递归、认 .gitignore、高亮分组）
# 只改 fish 函数层: sh -c / 子进程里的 grep 不受影响，脚本无需担心被换掉
function grep
    # -E(rg 里是 --encoding) / -R / -Z / -w(rg 里是"反向"词匹配) 语义与 grep 冲突，
    # 且 rg 本身默认就是递归搜索，这些情况退回真 grep 免得给出错误结果
    set -l rgunsafe
    for a in $argv
        string match -rq -- '^-[^-]*[ERZw]' "$a" && set rgunsafe 1
    end
    if test -n "$rgunsafe"; or not isatty 1
        command grep --color=auto $argv
    else
        command rg $argv
    end
end

# eza 代替 ls
function ls
    command eza --icons $argv
end

function lt
    command eza --icons --tree $argv
end

# 便捷缩写
abbr fa fastfetch
abbr reboot 'systemctl reboot'
abbr rebuild 'sudo nixos-rebuild switch --flake .#'

# 启动时显示系统信息（xfce4-terminal 内的 session 用 hyfetch 区别对待）
set -l ppid (ps -p $fish_pid -o ppid= 2>/dev/null | string trim)
set -l pname (ps -p $ppid -o comm= 2>/dev/null | string trim)
if test "$pname" = ".xfce4-terminal"; or test "$pname" = alacritty
    hyfetch 2>/dev/null
else
    fastfetch
end

# >>> grok installer >>>
fish_add_path $HOME/.grok/bin
# <<< grok installer <<<
