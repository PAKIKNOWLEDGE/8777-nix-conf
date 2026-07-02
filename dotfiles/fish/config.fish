#环境变量/nix
set PATH $PATH /home/pakiknowledge/.local/bin
set -gx PATH "$HOME/.nix-profile/bin" $PATH

if status is-interactive
    # ===== 代理开关（每次打开终端时询问） =====
    if isatty stdin
        read -P '🔌 启用代理 (端口 7897)？ [y/N]: ' -l use_proxy
        switch $use_proxy
            case y Y yes YES
                set -gx http_proxy "http://127.0.0.1:7897"
                set -gx https_proxy "http://127.0.0.1:7897"
                set -gx all_proxy "socks5://127.0.0.1:7897"
                echo "✅ 代理已启用 (http://127.0.0.1:7897)"
            case '*'
                set -e http_proxy
                set -e https_proxy
                set -e all_proxy
                echo "❌ 未启用代理"
        end
    end
end

# 关闭欢迎语
set fish_greeting ""
# 优先加载本地 bin
set -p PATH ~/.local/bin ~/.cargo/bin ~/.npm-global/bin

# starship 提示符
starship init fish | source
# zoxide 智能跳转
zoxide init fish --cmd cd | source

# 别名
alias ds='reasonix code'
alias luckerr='reasonix code'
alias power='upower -i $(upower -e | grep 'BAT') | grep percentage' # 双电池用
alias rebuild='sudo nixos-rebuild switch'
alias avim='nvim' # 肌肉记忆没救了
alias homebuild='home-manager switch'
alias ship='nix-shell -p updog --run "updog -d $(pwd)"'

# yazi 退出后自动 cd 到浏览目录
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# astrovim replace LazyVim
function lvim
    NVIM_APPNAME=nvim-lazy nvim $argv
end

# bat 代替 cat
function cat
    command bat $argv
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

# 启动时显示系统信息（xfce4-terminal 内的 session 用 hyfetch 区别对待）
set -l ppid (ps -p $fish_pid -o ppid= 2>/dev/null | string trim)
set -l pname (ps -p $ppid -o comm= 2>/dev/null | string trim)
if test "$pname" = ".xfce4-terminal"; or test "$pname" = "alacritty"
hyfetch 2>/dev/null
else
    fastfetch
end
