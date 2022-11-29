from IPython.terminal.prompts import Prompts, Token

c = get_config()

# show python version on start
c.TerminalIPythonApp.display_banner = True
c.InteractiveShellApp.log_level = 20
c.InteractiveShellApp.exec_lines = [
    # import numpy and limit displayed precision
    'import numpy as np',
    'np.set_printoptions(precision=3, suppress=True)',
    'import ipdb',
    'from matplotlib import pyplot as plt',
    '%load_ext autoreload',
    '%autoreload 2',
    '%load_ext ipython_cells',
]
# '%matplotlib',

# cleaner prompt, hide "In[x]", "Out[x]"
class MyPrompt(Prompts):
     def in_prompt_tokens(self, cli=None):
         return [(Token.Prompt, '>>> ')]
     def out_prompt_tokens(self):
         return [(Token.Prompt, '')]
c.TerminalInteractiveShell.prompts_class = MyPrompt

c.InteractiveShellApp.exec_lines.append('np.seterr(all=\'print\')')
c.InteractiveShell.autoindent = True
c.InteractiveShell.confirm_exit = False
# set vi editin mode
c.TerminalInteractiveShell.editing_mode = 'vi'
c.TerminalInteractiveShell.prompt_includes_vi_mode = False
c.TerminalInteractiveShell.emacs_bindings_in_vi_insert_mode = False
# increase history length
c.TerminalInteractiveShell.history_length = 20000
c.TerminalInteractiveShell.history_load_length = 20000


# import os
# editor =  os.environ.get('EDITOR')
# if editor:
#     c.InteractiveShell.editor = editor

# c.TerminalInteractiveShell.highlighting_style = 'monokai'
