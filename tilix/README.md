# Tilix Configuration

Tilix uses dconf (not files). To restore settings:

```bash
dconf load /com/gexperts/Tilix/ < ~/dotfiles/tilix/tilix.dconf
```

To backup current settings:

```bash
dconf dump /com/gexperts/Tilix/ > ~/dotfiles/tilix/tilix.dconf
```

Note: This is NOT managed by stow. Manual load/dump required.
