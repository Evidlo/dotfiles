c.url.searchengines = {'DEFAULT': 'https://google.com/search?q={}'}
c.url.default_page = 'https://google.com/'
c.url.start_pages = ['https://google.com']
c.qt.force_software_rendering = True

config.bind('<Ctrl-H>', 'rl-unix-filename-rubout', mode='command')
config.bind(';m', 'hint links spawn -d mpv {hint-url}')

