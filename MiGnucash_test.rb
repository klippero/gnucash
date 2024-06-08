require "minitest/autorun"
require_relative "MiGnucash"
require 'date'
require "gnucash"
require("bundler/setup")
require "xirr"


class TransactionTest < Minitest::Test
    def test_initialize_equity
        t = Transaction_.new(Date.parse('2010-02-18'),"VSP500",-450,45)
        assert_equal(t.to_csv,"18/02/2010;VSP500;45;10;-450")
    end

    def test_initialize_dividendos
        t = Transaction_.new(Date.strptime("05/08/2020","%d/%m/%Y"),"VSP500",974.22)
        assert_equal(t.to_csv,"05/08/2020;VSP500;;;974,22")
    end

    def test_tr_type
        t = Transaction_.new(Date.parse('2010-02-18'),"VSP500",-450,45)
        assert_equal(t.type,:equity)

        t = Transaction_.new(Date.strptime("05/08/2020","%d/%m/%Y"),"VSP500",974.22)
        assert_equal(t.type,:dividendos)
    end

    def test_total
        portfolio = Portfolio.new(
            {
                :file => 'test.gnucash',
                :investments =>
                {
                    "VSP500" => {
                        :vl => 58.13
                    }
                }
            }
        )
        assert_equal(748.07,portfolio.amount("VSP500").round(2))
        assert_equal(0,portfolio.amount("woei").round(2))
    end

    def test_csv
        portfolio = Portfolio.new(
            {
                :file => 'test.gnucash',
                :investments =>
                {
                    "VSP500" => {
                        :vl => 58.13
                    }
                }
            }
        )
        assert_equal(309,portfolio.to_csv.length)
    end
end
