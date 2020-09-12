from IPython.terminal.prompts import Prompts, Token
import os
import sys

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

# custom prompt
class MyPrompt(Prompts):
     def in_prompt_tokens(self, cli=None):
         return [(Token.Prompt, '>>> ')]




if sys.version_info.major == 3:
    import sys
    c.InteractiveShellApp.exec_lines.append('np.seterr(all=\'print\')')
    c.InteractiveShell.autoindent = True
    c.InteractiveShell.confirm_exit = False
    c.InteractiveShell.deep_reload = True
    c.TerminalInteractiveShell.editing_mode = 'vi'
    c.TerminalInteractiveShell.prompt_includes_vi_mode = False
    c.TerminalInteractiveShell.history_length = 20000
    c.TerminalInteractiveShell.history_load_length = 20000
    c.TerminalInteractiveShell.prompts_class = MyPrompt
    import os
    editor =  os.environ.get('EDITOR')
    if editor:
        c.InteractiveShell.editor = editor
