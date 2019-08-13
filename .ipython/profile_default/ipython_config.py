c = get_config()

c.TerminalIPythonApp.display_banner = True
c.InteractiveShellApp.log_level = 20
c.InteractiveShellApp.exec_lines = [
    'import numpy as np',
    'import ipdb',
    'from matplotlib import pyplot as plt',
    '%load_ext autoreload',
    '%load_ext ipython_cells',
    '%autoreload 2',
    'np.set_printoptions(precision=3, suppress=True)',
    '%matplotlib',
]
import sys
if sys.version_info.major == 3:
    c.InteractiveShellApp.exec_lines.append('np.seterr(all=\'print\')')
c.InteractiveShell.autoindent = True
c.InteractiveShell.confirm_exit = False
c.InteractiveShell.deep_reload = True
c.TerminalInteractiveShell.editing_mode = 'vi'
c.TerminalInteractiveShell.prompt_includes_vi_mode = False
import os
editor =  os.environ.get('EDITOR')
if editor:
    c.InteractiveShell.editor = editor
