#!/usr/bin/python

import signal
import time

from subprocess import check_output, CalledProcessError


def cmd(cmd, shell=False):
    try:
        return check_output(cmd, shell=shell, encoding="utf-8").strip()
    except:
        return None


signal_raised = False

def handle_usr_signal(signum, frame):
    """ Reprints on user signal """
    signal_raised = True
    print_status(disregard_signal=False)

def volume():
    card_idx = cmd(
        r"cat /proc/asound/cards | grep -E '\[PCH\s+\]' | awk '{print $1}'", shell=True
    )

    if not card_idx:
        return "mute"
    else:
        vol_amt = cmd(
            f"amixer -c {card_idx} get Master | " r"grep -Po '\d?\d?\d%'", shell=True
        )
        vol_on = cmd(
            f"amixer -c {card_idx} get Master | " r"grep -Po '\[(off|on)\]'", shell=True
        )
        return f"vol {vol_amt}" if vol_on == "[on]" else "mute"


def playerctl():
    try:
        playerctl_status = cmd(["playerctl", "status"])
    except CalledProcessError:
        playerctl_status = "Stopped"

    if playerctl_status == "Playing":
        artist = cmd(["playerctl", "metadata", "artist"])
        title = cmd(["playerctl", "metadata", "title"])
        return f"[{artist}]: {title}"

    return playerctl_status


def date():
    return cmd(["date", "+%A  %Y-%m-%d %l:%M:%S %p"])


def battery():
    now = cmd(["cat", "/sys/class/power_supply/BAT0/charge_now"])
    full = cmd(["cat", "/sys/class/power_supply/BAT0/charge_full"])
    return f"{100 * int(now) / int(full):0.1f}%"


def print_status(disregard_signal=True):
    global signal_raised
    if not signal_raised or disregard_signal:
        items = [playerctl(), volume(), battery(), date()]
        items = [item for item in items if item is not None]
        print(" · ".join(items) + " ", flush=True)

    signal_raised = False


def main():
    signal.signal(signal.SIGUSR1, handle_usr_signal)
    while True:
        print_status()
        time.sleep(1)


if __name__ == "__main__":
    main()
