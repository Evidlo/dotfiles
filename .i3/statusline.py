#!/bin/env python
# Evan Widloski - 2023-01-17
# Python version of an earlier bash script
import time
from datetime import datetime
import socket
from operator import attrgetter
import json
import subprocess
import re

# thanks to https://stackoverflow.com/questions/166506/finding-local-ip-addresses-using-pythons-stdlib
def get_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(0)
    try:
        # try to connect to reserved external address
        s.connect(('10.254.254.254', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

# thanks to https://stackoverflow.com/a/6556951/7465444
def get_default_interface():
    """Read the default gateway directly from /proc.

    Returns:
        (str or None)
    """
    with open("/proc/net/route") as fh:
        for line in fh:
            fields = line.strip().split()
            if fields[1] != '00000000' or not int(fields[3], 16) & 2:
                # If not default route or not RTF_GATEWAY, skip it
                continue

            return fields[0]

def get_network_rate(interface):
    """Get network down/up rate from /proc/net/dev

    Args:
        interface (str): interface to count bytes from

    Returns:
        down (int): avg KB down per sec since last call
        up (int): avg KB up per sec since last call

    """
    time_last = time.time()
    down_last = 0
    up_last = 0
    while True:
        for line in open('/proc/net/dev', 'r').read().splitlines():
            if interface in line:
                break
        else:
            raise ValueError("Could not find interface in /proc/net/dev")
        params = line.split()
        assert len(params) == 17, "Error parsing /proc/net/dev"
        down_now, up_now = int(params[2]), int(params[10])
        elapsed_time = time.time() - time_last
        down, up = down_now - down_last, up_now - up_last
        down_last, up_last = down_now, up_now
        yield down / elapsed_time, up / elapsed_time

def get_cpu_temp():
    """Read CPU temp from disk

    Returns:
        cpu_temp (float): CPU temp in celcius
    """

    f = open('/sys/class/hwmon/hwmon0/device/temp', 'r')

    while True:
        f.seek(0)
        yield int(f.read().strip()) / 1000

def get_batt():
    """Read battery info from acpi

    Returns:
        state (str): one of ('charging', 'discharging', 'unknown', 'full)
        percent (int or None): battery charge level
        time (str or None): battery charge/discharge time remaining
    """
    result = subprocess.check_output('acpi').decode('utf8').splitlines()[0]
    percent_match = re.search('[0-9]{2}', result)
    percent = None if percent_match is None else int(percent_match.group())
    time_match = re.search('[0-9]{2}:[0-9]{2}:[0-9]{2}', result)
    time = None if time_match is None else time_match.group()

    if 'Discharging' in result and percent is not None and time is not None:
        return 'discharging', percent, time
    elif 'Charging' in result and percent is not None and time is not None:
        return 'charging', percent, time
    elif 'Full' in result or 'Not charging' in result:
        return 'full', None, None
    else:
        return 'unknown', None, None

class Timer:
    def __init__(self, callback, period):
        # callback generator
        self.callback = callback()
        # time between calls
        self.period = period
        self.call_time = time.time()

    # reset absolute time call_time
    def reset(self):
        self.call_time = time.time() + self.period

    # seconds left until callback should be executed
    @property
    def time_left(self):
        return self.call_time - time.time()

    def sleep_and_run(self):
        """Sleep until callback needs to be run, then execute it"""
        sleep_start = time.time()
        if self.time_left > 0:
            time.sleep(self.time_left)
        self.reset()
        next(self.callback)

    def __lt__(self, other):
        return self.call_time < other.call_time

    def __repr__(self):
        return f'Timer({self.callback.gi_code.co_name} in {self.time_left:.1f}s)'



# ----- Run on a 1s interval -----
def every_1s():
    global data, interface
    rate_generator = get_network_rate(interface)
    temp_generator = get_cpu_temp()

    while True:
        # network transfer speed
        down, up = next(rate_generator)
        data['rate_down'] = f'{down:.0f}KB'
        data['rate_up'] = f'{up:.0f}KB'

        # datetime
        curr_time = datetime.now().strftime('%H:%M')
        data['datetime'] = curr_time

        # cpu temp
        temp = next(temp_generator)
        data['cpu_temp'] = f'{temp:.0f} °C'

        emit_data()
        yield

# ----- Run on a 30s interval -----
def every_30s():
    while True:
        # ip address
        data['address'] = get_ip()

        # battery
        b_state, b_percent, b_time = get_batt()
        if b_state == 'charging':
            data['batt_level'] = b_time
            data['batt_color'] = '#ff00cc'
        elif b_state == 'discharging':
            data['batt_level'] = b_time
            if b_percent in range(75, 101):
                data['batt_color'] = '#b6ff00'
            elif b_percent in range(50, 75):
                data['batt_color'] = '#d1d100'
            elif b_percent in range(25, 50):
                data['batt_color'] = '#e89300'
            else:
                data['batt_color'] = '#f23400'
        elif b_state == 'full':
            data['batt_level'] = '100%'
            data['batt_color'] = '#b6ff00'
        else:
            data['batt_level'] = 'Unknown'
            data['batt_color'] = '#ff00cc'

        yield

# ----- Run on a 300s interval -----
def every_300s():
    global interface
    while True:
        interface = get_default_interface()
        yield

def emit_data():
    j = [
        {'color': '#ffff00', 'full_text': data['address']},
        {'color': '#ffff00', 'full_text': data['mins_used']},
        {'color': '#4284D3', 'full_text': data['rate_down']},
        {'color': '#ff9200', 'full_text': data['rate_up']},
        {'color': '#ffffff', 'full_text': data['datetime']},
        {'color': data['batt_color'], 'full_text': data['batt_level']},
        {'color': '#ffffff', 'full_text': data['cpu_temp']},
    ]
    print(json.dumps(j, ensure_ascii=False), end=',\n', flush=True)

if __name__ == '__main__':
    # global json dict to emit to i3bar
    data = {
        'address': '', 'mins_used': '', 'rate_down': '', 'rate_up': '', 'datetime': '',
        'batt_color': '', 'batt_level': '', 'cpu_temp': ''
    }
    interface = get_default_interface()

    print(json.dumps({"version": 1}))
    print('[')
    print('[],')
    timers = [Timer(every_1s, 1), Timer(every_30s, 30), Timer(every_300s, 300)]
    while True:
        try:
            next_timer = min(timers, key=attrgetter('call_time'))
            next_timer.sleep_and_run()
        except Exception as e:
            with open('/tmp/test.log', 'w') as f:
                import traceback
                traceback.print_exc(file=f)
                from datetime import datetime
                f.write(f'Error at time {datetime.now()}')
                f.write('\n')
                f.write(str(e))
        except KeyboardInterrupt:
            pass
