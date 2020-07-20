case "$(hostname)" in
  xibalba)
    m4 -D BAR_HEIGHT=22 -D BAR_FONT=Terminus \
      $HOME/.config/i3/config.template > $HOME/.config/i3/config
    ;;
    m4 -D ROFI_FONT="Terminus Medium 12" \
      $HOME/.config/rofi/config.rasi.template > $HOME/.config/rofi/config.rasi
    ;;
  crux)
    m4 -D BAR_HEIGHT=33 -D BAR_FONT="Terminus (TTF)" \
      $HOME/.config/i3/config.template > $HOME/.config/i3/config
    ;;
    m4 -D ROFI_FONT="Terminus (TTF) 20" \
      $HOME/.config/rofi/config.rasi.template > $HOME/.config/rofi/config.rasi
    ;;
  *)
    echo "unexpected hostname $(hostname)"
    exit 1
    ;;
esac

exec dbus-launch i3
