#!/bin/sh
# Enregistre de vraies réponses des trois API dans test/fixtures/, pour les
# tests d'apprentissage. Lit les clés dans env.json sans les afficher et les
# envoie en en-tête, jamais dans l'URL.
#
# Usage : sh tool/fetch_fixtures.sh
set -eu

cd "$(dirname "$0")/.."
out=test/fixtures
mkdir -p "$out"

read_key() {
  sed -n "s/.*\"$1\": *\"\([^\"]*\)\".*/\1/p" env.json
}
twelve_data_key=$(read_key TWELVE_DATA_API_KEY)
coingecko_key=$(read_key COINGECKO_API_KEY)

# Dates fixes : les fixtures restent identiques d'un enregistrement à l'autre.
from_day=2026-09-21
to_day=2026-10-02

# Twelve Data : deux semaines de cours quotidiens d'Apple (1 crédit), puis
# une erreur volontaire pour connaître sa forme (1 crédit).
curl -sS -o "$out/twelve_data_time_series_aapl.json" \
  -H "Authorization: apikey $twelve_data_key" \
  "https://api.twelvedata.com/time_series?symbol=AAPL&interval=1day&start_date=$from_day&end_date=$to_day&order=asc"

curl -sS -o "$out/twelve_data_error_unknown_symbol.json" \
  -H "Authorization: apikey $twelve_data_key" \
  "https://api.twelvedata.com/time_series?symbol=PECULE_UNKNOWN&interval=1day"

# Twelve Data : période sans aucune cotation, pour connaître la réponse quand
# il n'y a rien de nouveau à télécharger (1 crédit).
curl -sS -o "$out/twelve_data_no_data.json" \
  -H "Authorization: apikey $twelve_data_key" \
  "https://api.twelvedata.com/time_series?symbol=AAPL&interval=1day&start_date=2030-01-07&order=asc"

# CoinGecko : on demande interval=daily pour vérifier qu'il est accepté sur le
# plan Demo avec une période de moins de 90 jours.
from_unix=$(date -j -u -f '%Y-%m-%d %H:%M:%S' "$from_day 00:00:00" +%s)
to_unix=$(date -j -u -f '%Y-%m-%d %H:%M:%S' "2026-10-03 00:00:00" +%s)

curl -sS -o "$out/coingecko_market_chart_range_bitcoin.json" \
  -H "x-cg-demo-api-key: $coingecko_key" \
  "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart/range?vs_currency=usd&from=$from_unix&to=$to_unix&interval=daily"

# Les deux réponses suivantes changent à chaque appel (cours du moment,
# derniers taux) : on ne les enregistre qu'une fois, pour que les tests
# gardent les mêmes valeurs. Supprimer le fichier pour le réenregistrer.

# Cours actuel et variation sur un an de plusieurs cryptos en un seul appel,
# pour l'Explorer.
if [ ! -f "$out/coingecko_markets.json" ]; then
  curl -sS -o "$out/coingecko_markets.json" \
    -H "x-cg-demo-api-key: $coingecko_key" \
    "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=bitcoin,ethereum&price_change_percentage=1y"
fi

# Frankfurter : taux EUR/USD sur les mêmes deux semaines, sans clé.
curl -sS -o "$out/frankfurter_rates_eur_usd.json" \
  "https://api.frankfurter.dev/v2/rates?from=$from_day&to=$to_day&base=EUR&quotes=USD"

# Frankfurter : date de début seule, pour vérifier qu'on reçoit tout jusqu'au
# dernier taux publié.
if [ ! -f "$out/frankfurter_rates_open_ended.json" ]; then
  curl -sS -o "$out/frankfurter_rates_open_ended.json" \
    "https://api.frankfurter.dev/v2/rates?from=2026-09-28&base=EUR&quotes=USD"
fi

echo "Fixtures enregistrées dans $out"
