local cli = require '@utils/cli'

-- currently only 1 command available for personal proporses
-- TODO: add proper cli abstraction for commands for each function of the library
assert(cli.str(1) == 'place')
assert(cli.str(2) == 'download')

return require '@self/download_place'
