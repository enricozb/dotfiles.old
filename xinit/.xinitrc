case $(hostname) in
  xibalba)
    m4 -D BAR_HEIGHT=22 -D BAR_FONT=Terminus \
      $HOME/.config/i3/config.template > $HOME/.config/i3/config
    ;;
  crux)
    m4 -D BAR_HEIGHT=33 -D BAR_FONT="Terminus (TTF) \
      $HOME/.config/i3/config.template > $HOME/.config/i3/config
    ;;
  *)
    echo "unexpected hostname $(hostname)"
    exit 1 ;;
esac

exec dbus-launch i3
