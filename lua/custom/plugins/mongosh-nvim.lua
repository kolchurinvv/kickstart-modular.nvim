return {
  'donus3/mongo.nvim',
  dependencies = {
    'ibhagwan/fzf-lua',
  },
  opts = {
    ---default mongo url show on start up
    default_url = 'mongodb://0.0.0.0:27017',
    ---execute query on collection selected
    find_on_collection_selected = false,
    ---mongo binary path for mongodb < 3.6
    mongo_binary_path = nil,
    -- mongo_binary_path = '/etc/profiles/per-user/_liminor/bin/mongo',
    ---mongodb shell binary path
    mongosh_binary_path = '/etc/profiles/per-user/_liminor/bin/mongosh',
    ---number of documents in the result
    batch_size = 100,
  },
}
