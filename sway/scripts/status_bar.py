#!/usr/bin/python

import signal
import time

from subprocess import check_output, CalledProcessError


def cmd(cmd, shell=False):
    return check_output(cmd, shell=shell, encoding="utf-8").strip()


signal_raised = False

def handle_usr_signal(signum, frame):
    """ Reprints on user signal """
    signal_raised = True
    print_status(disregard_signal=False)


def print_status(disregard_signal=True):
    global signal_raised
    card_idx = cmd(
        r"cat /proc/asound/cards | grep -E '\[PCH\s+\]' | awk '{print $1}'", shell=True
    )

    date = cmd(["date", "+%A  %Y-%m-%d %l:%M:%S %p"])

    vol_amt = cmd(
        f"amixer -c {card_idx} get Master | " r"grep -Po '\d?\d?\d%'", shell=True
    )
    vol_on = cmd(
        f"amixer -c {card_idx} get Master | " r"grep -Po '\[(off|on)\]'", shell=True
    )
    volume = f"vol {vol_amt}" if vol_on == "[on]" else "mute"

    try:
        playerctl_status = cmd(["playerctl", "status"])
    except CalledProcessError:
        playerctl_status = "Stopped"

    if playerctl_status == "Playing":
        artist = cmd(["playerctl", "metadata", "artist"])
        title = cmd(["playerctl", "metadata", "title"])
        playerctl = f"[{artist}]: {title}"
    else:
        playerctl = playerctl_status

    if not signal_raised or disregard_signal:
        print(f"{playerctl} · {volume} · {date}", flush=True)

    signal_raised = False


def main():
    signal.signal(signal.SIGUSR1, handle_usr_signal)
    while True:
        time.sleep(1)
        print_status()


if __name__ == "__main__":
    main()
