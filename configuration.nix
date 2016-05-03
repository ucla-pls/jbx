# This is a nixos setup file
{ config, pkgs, ...} :
{
  environment.systemPackages = with pkgs; [
    htop
    tree
    vim
    git
    python
    python3
  ];
}
