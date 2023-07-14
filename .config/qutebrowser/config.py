config.load_autoconfig()

c.url.searchengines = {
    'DEFAULT': 'https://google.com/search?q={}',
    '!wiki': 'http://wikipedia.org/wiki/Special:Search/{}',
    '!etym': 'https://www.etymonline.com/search?q={}'
}
c.url.default_page = 'https://google.com/'
c.url.start_pages = ['https://google.com']
c.completion.use_best_match = True
c.completion.web_history.max_items = 10000
c.content.blocking.whitelist = ['www.rapidvideo.com']
c.content.geolocation = False
c.content.notifications.enabled = False
c.input.insert_mode.leave_on_load = False
# c.colors.tabs.selected.even.bg = 'orange'
# c.colors.tabs.selected.odd.bg = 'orange'

config.bind('<Ctrl-H>', 'rl-unix-filename-rubout', mode='command')
config.bind(';m', 'hint links spawn -d mpv {hint-url}')
config.bind(';o', 'hint links spawn -d xdg-open {hint-url}')
config.bind(';j', 'config-cycle content.javascript.enabled;;reload -f')

