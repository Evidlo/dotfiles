c = get_config()

c.TerminalIPythonApp.display_banner = True
c.InteractiveShellApp.log_level = 20
c.InteractiveShellApp.exec_lines = [
    'import numpy as np',
    'from matplotlib import pyplot as plt',
    '%load_ext autoreload',
    '%autoreload 2',
    # 'np.set_printoptions(linewidth=9999, precision=2, suppress=True)',
    '%matplotlib',
    'np.seterr(all=\'print\')',
]
c.InteractiveShell.autoindent = True
c.InteractiveShell.confirm_exit = False
c.InteractiveShell.deep_reload = True
c.TerminalInteractiveShell.editing_mode = 'vi'
import os
editor =  os.environ.get('EDITOR')
if editor:
    c.InteractiveShell.editor = editor
