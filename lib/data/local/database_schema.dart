const databaseVersion = 1;

const schemaStatements = [
  '''
  CREATE TABLE user_profile (
    id INTEGER PRIMARY KEY,
    level TEXT NOT NULL,
    quiz_mistakes TEXT NOT NULL,
    onboarding_done INTEGER NOT NULL,
    created_at INTEGER NOT NULL
  )''',
  '''
  CREATE TABLE preference (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
  )''',
  '''
  CREATE TABLE lesson_progress (
    lesson_id TEXT PRIMARY KEY,
    seen_at INTEGER NOT NULL
  )''',
  '''
  CREATE TABLE favorite (
    asset_id TEXT PRIMARY KEY,
    added_at INTEGER NOT NULL
  )''',
  '''
  CREATE TABLE paper_transaction (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    asset_id TEXT NOT NULL,
    executed_on TEXT NOT NULL,
    amount_eur REAL NOT NULL,
    unit_price REAL NOT NULL,
    price_currency TEXT NOT NULL,
    eur_usd_rate REAL NOT NULL,
    quantity REAL NOT NULL,
    created_at INTEGER NOT NULL
  )''',
  '''
  CREATE TABLE saved_simulation (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    asset_id TEXT NOT NULL,
    periodic_amount_eur REAL NOT NULL,
    frequency TEXT NOT NULL,
    start_date TEXT NOT NULL,
    created_at INTEGER NOT NULL
  )''',

  '''
  CREATE TABLE price_bar (
    asset_id TEXT NOT NULL,
    day TEXT NOT NULL,
    open REAL,
    high REAL,
    low REAL,
    close REAL NOT NULL,
    volume REAL NOT NULL,
    market_cap REAL,
    PRIMARY KEY (asset_id, day)
  )''',
  '''
  CREATE TABLE fx_rate (
    day TEXT NOT NULL,
    base TEXT NOT NULL,
    quote TEXT NOT NULL,
    rate REAL NOT NULL,
    PRIMARY KEY (day, base, quote)
  )''',
  '''
  CREATE TABLE sync_state (
    resource_key TEXT PRIMARY KEY,
    last_data_day TEXT NOT NULL,
    last_fetched_at INTEGER NOT NULL
  )''',
];

const cacheTables = ['price_bar', 'fx_rate', 'sync_state'];
