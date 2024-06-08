require "minitest/autorun"
require_relative "MiGnucash"
require 'date'


class TransactionTest < Minitest::Test
    def test_initialize_equity
        t = Transaction.new(Date.parse('2010-02-18'),"#SCO",-450,45)
        assert_equal(t.to_s,"18/02/2010;#SCO;45;10;-450")
    end

    def test_initialize_dividendos
        t = Transaction.new(Date.strptime("05/08/2020","%d/%m/%Y"),"#SCO",974.22)
        assert_equal(t.to_s,"05/08/2020;#SCO;;;974,22")
    end

    def test_tr_type
        t = Transaction.new(Date.parse('2010-02-18'),"#SCO",-450,45)
        assert_equal(t.type,:equity)

        t = Transaction.new(Date.strptime("05/08/2020","%d/%m/%Y"),"#SCO",974.22)
        assert_equal(t.type,:dividendos)
    end
end
