{ config, pkgs, pkgs-25-11, ... }:
{
  # 在 home.nix 里允许非自由软件
  nixpkgs.config = {
    allowUnfree = true;
  };
  # ── 用户信息 ──
  home.username = "pakiknowledge";
  home.homeDirectory = "/home/pakiknowledge";

  # 与 configuration.nix 中的 system.stateVersion 保持一致
  home.stateVersion = "26.05";

  # ── 用户级包（非系统必需） ──
  home.packages = with pkgs; [
    pkgs-25-11.krita                # 26.05 的 krita 6.0.1 字体菜单炸了，用 25.11 的版本
    libreoffice   # 办公套件 这吊货编译了12分钟
    gimp # adobe?
    macchina
    vis # 啊哈哈 目前暂时不知道这货和vim比起来有啥用
    vim # 巧了吗这不是
    gcc # nvim-treesitter 编译 parser
    tree-sitter # nvim-treesitter 编译 CLI
    ty # pyton LSP and.. 🦀🦀🦀
    nixd # for .nix file LSP support
    nil # nix lsp yet another simple mode
    taplo # toml toolkit written in rust

         ];

  # ── Git ──
  programs.git = {
    enable = true;
    settings = {
      user.name = "PAKI KNOWLEDGE";
      user.email = "PAKIKNOWLEDGE@users.noreply.github.com";
      credential.helper = "!gh auth git-credential";  # 不写死 store path，gh 更新后不会炸
      core.editor = "nvim";
    };
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      export STARSHIP_CONFIG=~/.config/starship-bash.toml
      eval "$(starship init bash)"
    '';
  };

  # HM 自身需要启用才能正常工作
  programs.home-manager.enable = true;
}
