/// One schema change. Add a new [Migration] for every change to the database.
/// Never edit a migration that has shipped; write a new one instead.
class Migration {
  const Migration(this.version, this.statements);

  final int version;
  final List<String> statements;
}

const migrations = <Migration>[
  Migration(1, [
    '''
    CREATE TABLE users (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      name          TEXT    NOT NULL,
      email         TEXT    NOT NULL UNIQUE,
      password_hash TEXT    NOT NULL,
      salt          TEXT    NOT NULL,
      created_at    TEXT    NOT NULL
    )
    ''',
  ]),

  // Workflow tables: inventory, stock log, orders, AI requests and recipes,
  // platform listings, insights, platform analytics, and dashboard prefs.
  // Money is stored as whole rupiah (INTEGER). Timestamps are ISO-8601 TEXT.
  Migration(2, [
    '''
    CREATE TABLE inventory_items (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id         INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      name            TEXT    NOT NULL,
      category        TEXT    NOT NULL,
      unit            TEXT    NOT NULL DEFAULT 'pcs',
      stock           INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
      price_idr       INTEGER NOT NULL DEFAULT 0,
      sell_price_idr  INTEGER,
      icon_key        TEXT    NOT NULL DEFAULT 'inventory',
      source          TEXT    NOT NULL DEFAULT 'manual'
                      CHECK (source IN ('manual', 'ai_photo', 'recipe')),
      created_at      TEXT    NOT NULL,
      updated_at      TEXT    NOT NULL
    )
    ''',
    'CREATE INDEX idx_items_user_category ON inventory_items(user_id, category)',
    '''
    CREATE TABLE stock_movements (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      item_id       INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
      delta         INTEGER NOT NULL,
      balance_after INTEGER NOT NULL,
      reason        TEXT    NOT NULL,
      note          TEXT,
      created_at    TEXT    NOT NULL
    )
    ''',
    'CREATE INDEX idx_movements_item ON stock_movements(item_id, created_at)',
    '''
    CREATE TABLE orders (
      id            INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id       INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      platform      TEXT    NOT NULL,
      external_ref  TEXT,
      item_id       INTEGER REFERENCES inventory_items(id) ON DELETE SET NULL,
      item_name     TEXT    NOT NULL,
      total_idr     INTEGER NOT NULL,
      status        TEXT    NOT NULL DEFAULT 'dikemas'
                    CHECK (status IN ('dikemas', 'dikirim', 'selesai', 'batal')),
      ordered_at    TEXT    NOT NULL,
      updated_at    TEXT    NOT NULL,
      UNIQUE (platform, external_ref)
    )
    ''',
    'CREATE INDEX idx_orders_user_time ON orders(user_id, ordered_at)',
    '''
    CREATE TABLE ai_requests (
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      kind         TEXT    NOT NULL CHECK (kind IN ('photo_item', 'mix_match', 'insight')),
      input_json   TEXT    NOT NULL,
      output_json  TEXT,
      status       TEXT    NOT NULL DEFAULT 'pending'
                   CHECK (status IN ('pending', 'done', 'failed')),
      error        TEXT,
      created_at   TEXT    NOT NULL,
      completed_at TEXT
    )
    ''',
    '''
    CREATE TABLE recipes (
      id              INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id         INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      request_id      INTEGER REFERENCES ai_requests(id) ON DELETE SET NULL,
      name            TEXT    NOT NULL,
      hpp_idr         INTEGER NOT NULL,
      sell_price_idr  INTEGER NOT NULL,
      difficulty      TEXT    NOT NULL,
      icon_key        TEXT    NOT NULL DEFAULT 'cake',
      status          TEXT    NOT NULL DEFAULT 'idea'
                      CHECK (status IN ('idea', 'saved', 'produced')),
      created_at      TEXT    NOT NULL
    )
    ''',
    '''
    CREATE TABLE recipe_ingredients (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      recipe_id   INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
      position    INTEGER NOT NULL,
      description TEXT    NOT NULL,
      item_id     INTEGER REFERENCES inventory_items(id) ON DELETE SET NULL
    )
    ''',
    '''
    CREATE TABLE recipe_steps (
      id          INTEGER PRIMARY KEY AUTOINCREMENT,
      recipe_id   INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
      position    INTEGER NOT NULL,
      description TEXT    NOT NULL
    )
    ''',
    '''
    CREATE TABLE recipe_sources (
      recipe_id INTEGER NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
      item_id   INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
      PRIMARY KEY (recipe_id, item_id)
    )
    ''',
    '''
    CREATE TABLE product_listings (
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      item_id      INTEGER NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
      platform     TEXT    NOT NULL CHECK (platform IN ('tokopedia', 'shopee', 'tiktok')),
      status       TEXT    NOT NULL DEFAULT 'draft'
                   CHECK (status IN ('draft', 'publishing', 'live', 'failed')),
      external_id  TEXT,
      error        TEXT,
      published_at TEXT,
      updated_at   TEXT    NOT NULL,
      UNIQUE (item_id, platform)
    )
    ''',
    '''
    CREATE TABLE insights (
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      category     TEXT    NOT NULL,
      tone         TEXT    NOT NULL CHECK (tone IN ('alert', 'info', 'success')),
      title        TEXT    NOT NULL,
      body         TEXT    NOT NULL,
      action_label TEXT    NOT NULL,
      source       TEXT    NOT NULL DEFAULT 'rule' CHECK (source IN ('rule', 'ai')),
      created_at   TEXT    NOT NULL,
      read_at      TEXT,
      dismissed_at TEXT
    )
    ''',
    'CREATE INDEX idx_insights_user_time ON insights(user_id, created_at)',
    '''
    CREATE TABLE platform_daily_stats (
      user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      platform    TEXT    NOT NULL,
      day         TEXT    NOT NULL,
      visits      INTEGER NOT NULL DEFAULT 0,
      orders      INTEGER NOT NULL DEFAULT 0,
      revenue_idr INTEGER NOT NULL DEFAULT 0,
      ad_spend_idr INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (user_id, platform, day)
    )
    ''',
    '''
    CREATE TABLE platform_keyword_stats (
      user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      platform    TEXT    NOT NULL,
      day         TEXT    NOT NULL,
      keyword     TEXT    NOT NULL,
      clicks      INTEGER NOT NULL DEFAULT 0,
      spend_idr   INTEGER NOT NULL DEFAULT 0,
      revenue_idr INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (user_id, platform, day, keyword)
    )
    ''',
    '''
    CREATE TABLE platform_settings (
      user_id       INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      platform      TEXT    NOT NULL,
      auto_reply    INTEGER NOT NULL DEFAULT 0,
      voucher_on    INTEGER NOT NULL DEFAULT 0,
      ad_budget_idr INTEGER NOT NULL DEFAULT 0,
      updated_at    TEXT    NOT NULL,
      PRIMARY KEY (user_id, platform)
    )
    ''',
    '''
    CREATE TABLE dashboard_prefs (
      user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
      section TEXT    NOT NULL,
      visible INTEGER NOT NULL DEFAULT 1,
      PRIMARY KEY (user_id, section)
    )
    ''',
  ]),
];

/// The version the app opens the database at.
final int currentSchemaVersion = migrations.last.version;
