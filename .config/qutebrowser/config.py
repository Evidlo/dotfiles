c.url.searchengines = {'DEFAULT': 'https://google.com/search?q={}', '!wiki': 'http://wikipedia.org/wiki/{}'}
c.url.default_page = 'https://google.com/'
c.url.start_pages = ['https://google.com']
c.completion.use_best_match = True

config.bind('<Ctrl-H>', 'rl-unix-filename-rubout', mode='command')
config.bind(';m', 'hint links spawn -d mpv {hint-url}')
config.bind(';j', 'config-cycle content.javascript.enabled;;reload -f')

