c.url.searchengines = {'DEFAULT': 'https://google.com/search?q={}', '!wiki': 'http://wikipedia.org/wiki/Special:Search/{}'}
c.url.default_page = 'https://google.com/'
c.url.start_pages = ['https://google.com']
c.completion.use_best_match = True
c.content.host_blocking.whitelist = ['www.rapidvideo.com']

config.bind('<Ctrl-H>', 'rl-unix-filename-rubout', mode='command')
config.bind(';m', 'hint links spawn -d mpv {hint-url}')
config.bind(';o', 'hint links spawn -d xdg-open {hint-url}')
config.bind(';j', 'config-cycle content.javascript.enabled;;reload -f')

