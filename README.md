trade-matcher
=============

This is the code in R for Trade Matcher

Trade Matcher matches/reconsiles the trades executed internally and the trade file send from exhange facing systems like Ransys.

It uses the following rules to match the trade
1. Trade Match happens on AccountID and InstrumentID key
2. Trade Direction must be opposite (Buy/Sell)
3. Trade Price should be weighted average for the key and should be matched within a tolerance of 10%
4. Trade Quantity matches then its FULLY matched, else its PARTIAL matching


