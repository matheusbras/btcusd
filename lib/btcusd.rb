require "btcusd/version"
require "active_support/all"
require "rest-client"

module Btcusd
  class Error < StandardError; end

  class Rate
    include ActiveSupport::NumberHelper

    def initialize(date:, time:)
      @date = Date.parse(date)
      @time = time.to_i
    end

    def self.call(date:, time:)
      rate = new(date: date, time: time)

      {
        btc_usd: rate.btc_usd.value.to_s(:currency, separator: ',', unit: '', delimiter: ''),
        btc_brl_compra: rate.btc_brl_compra.to_s(:currency, separator: ',', unit: '', delimiter: ''),
        btc_brl_venda: rate.btc_brl_venda.to_s(:currency, separator: ',', unit: '', delimiter: ''),
        dolar_ptax_compra: rate.dolar_ptax.compra.to_s(:currency, separator: ',', unit: '', delimiter: ''),
        dolar_ptax_venda: rate.dolar_ptax.venda.to_s(:currency, separator: ',', unit: '', delimiter: '')
      }
    end

    def btc_usd
      @btc_usd ||= RestClient.get(
        'https://data.messari.io/api/v1/markets/binance-btc-usdt/metrics/price-usd/time-series',
        { params: { start: @date, end: @date + 1.day, interval: '1h', columns: 'close' } },
      )

      JSON.parse(@btc_usd).dig('data', 'values').map do |value|
        Data.new(*value)
      end.find do |data|
        data.hour == @time
      end
    end

    def dolar_ptax
      response = RestClient.get(
        "https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata/CotacaoDolarDia(dataCotacao=@dataCotacao)?@dataCotacao='#{@date.strftime('%m-%d-%Y')}'&$top=1&$format=json&$select=cotacaoCompra,cotacaoVenda"
      )

      value = JSON.parse(response).dig('value').first

      @dolar_ptax ||= OpenStruct.new(
        compra: value['cotacaoCompra'],
        venda: value['cotacaoVenda'],
      )
    end

    def btc_brl_compra
      btc_usd.value * dolar_ptax.compra
    end

    def btc_brl_venda
      btc_usd.value * dolar_ptax.venda
    end
  end

  class Data
    attr_reader :date, :value, :hour

    def initialize(timestamp, value)
      @timestamp = timestamp
      @date = Time.at(timestamp/1000)
      @hour = @date.hour
      @value = value
    end
  end
end
