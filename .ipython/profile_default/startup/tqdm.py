from IPython import get_ipython
import tqdm

def tqdm_clear(*args, **kwargs):
    tqdm._instances.clear()

get_ipython().events.register('post_execute', tqdm_clear)
