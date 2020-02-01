from IPython import get_ipython

def tqdm_clear(*args, **kwargs):
    from tqdm import tqdm
    getattr(tqdm, '_instances', {}).clear()

get_ipython().events.register('post_execute', tqdm_clear)
