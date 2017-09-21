module Bitfinex
  module V2::TradingClient

    # Provides a way to access charting candle info
    #
    # @param symbol [string] The symbol you want information about.
    # @param timeframe [string] Available values: '1m', '5m', '15m',
    #        '30m', '1h', '3h', '6h', '12h', '1D', '7D', '14D', '1M'
    # @param section [string] Available values: "last", "hist"
    # @param params :limit [int32] Number of candles requested
    # @param params :start [int32] Filter start (ms)
    # @param params :end   [int32] Filter end (ms)
    # @param params :sort  [int32] if = 1 it sorts
    #        results returned with old > new
    #
    # @return [Array]
    #
    # @example:
    #   client.candles('tBTCUSD')
    def candles(symbol = 'tBTCUSD', timeframe = '1m', section = "last", params = {})
      check_params(params, %i{limit start end sort})
      get("candles/trade:#{timeframe}:#{symbol}/#{section}", params).body
    end

    # The Order Books channel allow you to keep track
    # of the state of the Bitfinex order book.
    # It is provided on a price aggregated basis,
    # with customizable precision.
    #
    #
    # @param symbol [string] The symbol you want
    #     information about. You can find the list of
    #     valid symbols by calling the /symbols
    #     endpoint.
    # @param precision [string] Level of price
    #     aggregation (P0, P1, P2, P3, R0)
    # @param params :len [int32] Number of price
    #     points ("25", "100")
    #
    # @return [Hash] :bids [Array], :asks [Array]
    #
    # @example:
    #   client.orderbook("btcusd")
    def books(symbol="btcusd", precision="P0", params = {})
      check_params(params, %i{len})
      get("book/#{symbol}/#{precision}", params: params).body
    end

    # Trades endpoint includes all the pertinent details
    # of the trade, such as price, size and time.
    #
    # @param symbol [string] the name of the symbol
    # @param params :limit [int32] Number of records
    # @param params :start [int32] Millisecond start time
    # @param params :end   [int32] Millisecond end time
    # @param params :sort  [int32] if = 1 it sorts
    #     results returned with old > new
    #
    # @return [Array]
    #
    # @example:
    #   client.trades("tETHUSD")
    def trades(symbol="tBTCUSD", params={})
      check_params(params, %i{limit start end sort})
      get("trades/#{symbol}", params).body
    end

    # Get active orders
    #
    # example:
    # client.orders
    def orders
      authenticated_post("auth/r/orders").body
    end

    # Get Trades generated by an Order
    #
    # @param order_id [int32] Id of the order
    # @param symbol [string] symbol used for the order
    #
    # @return [Array]
    #
    # @example:
    #   client.order_trades 10010, "tBTCUSD"
    #
    def order_trades(order_id, symbol="tBTCUSD")
      authenticated_post("auth/r/order/#{symbol}:#{order_id}/trades").body
    end


    # Get active positions
    #
    # return [Array]
    #
    # @example:
    #    client.active_positions
    def active_positions
      authenticated_post("auth/positions").body
    end


    # This channel sends a trade message whenever a trade occurs at Bitfinex.
    # It includes all the pertinent details of the trade, such as price, size and time.
    #
    # @param symbol [string]
    # @param block [Block] The code to be executed when a new ticker is sent by the server
    #
    # Documentation:
    #   https://docs.bitfinex.com/v2/reference#ws-public-trades
    #
    # @example:
    #   client.listen_trades("tBTCUSD") do |trade|
    #     puts "traded #{trade[2][2]} BTC for #{trade[2][3]} USD"
    #   end
    def listen_trades(symbol="tBTCUSD", &block)
      raise BlockMissingError unless block_given?
      register_channel symbol: symbol, channel: "trades", &block
    end

    # The Order Books channel allow you to keep track of the state of the Bitfinex order book.
    # It is provided on a price aggregated basis, with customizable precision.
    # After receiving the response, you will receive a snapshot of the book,
    # followed by updates upon any changes to the book.
    #
    # @param symbol [string]
    # @param precision [string] Level of price aggregation (P0, P1, P2, P3, R0).
    #       (default P0) R0 is raw books - These are the most granular books.
    # @param frequency [string] Frequency of updates (F0, F1, F2, F3).
    #       F0=realtime / F1=2sec / F2=5sec / F3=10sec (default F0)
    # @param length [int] Number of price points ("25", "100") [default="25"]
    #
    # Documentation:
    #   https://docs.bitfinex.com/v2/reference#ws-public-order-books
    #   https://docs.bitfinex.com/v2/reference#ws-public-raw-order-books
    #
    # @example:
    #   client.listen_book("tBTCUSD") do |trade|
    #     puts "traded #{trade[2][2]} BTC for #{trade[2][3]} USD"
    #   end
    def listen_book(symbol="tBTCUSD", frequency="F0", length=25, precision="P0", &block)
      raise BlockMissingError unless block_given?
      register_channel symbol: symbol, channel: "book", prec: precision, freq: frequency, len: length, &block
    end

  end
end