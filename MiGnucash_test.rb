require "minitest/autorun"
require_relative "MiGnucash"
require 'date'
require "gnucash"


class TransactionTest < Minitest::Test
    def test_initialize_equity
        t = Transaction_.new(Date.parse('2010-02-18'),-450,45)
        assert_equal(t.to_csv("MSFT"),"18/02/2010;MSFT;45;10;-450")
    end

    def test_initialize_dividendos
        t = Transaction_.new(Date.strptime("05/08/2020","%d/%m/%Y"),974.22)
        assert_equal(t.to_csv("MSFT"),"05/08/2020;MSFT;;;974,22")
    end

    def test_tr_type
        t = Transaction_.new(Date.parse('2010-02-18'),-450,45)
        assert_equal(t.type,:equity)

        t = Transaction_.new(Date.strptime("05/08/2020","%d/%m/%Y"),974.22)
        assert_equal(t.type,:dividendos)
    end

    def test_amount
        portfolio = Portfolio.new('test.gnucash')
        assert_equal(748.07,portfolio.amount("VSP500").round(2))
        assert_equal(6720.05,portfolio.amount("Apple").round(2))
        assert_equal(0,portfolio.amount("woei").round(2))
    end

    def test_csv
        portfolio = Portfolio.new('test.gnucash')
        assert_equal(591,portfolio.to_csv.length)
    end

    def test_xirr_VSP500
        portfolio = Portfolio.new('test.gnucash')
        assert_equal(27.62,(portfolio.portfolio["VSP500"].xirr(Date.strptime("11/06/2024","%d/%m/%Y")) * 100).round(2))
    end

    def test_xirr_Apple
        portfolio = Portfolio.new('test.gnucash')
        assert_equal(23.57,(portfolio.portfolio["Apple"].xirr(Date.strptime("11/06/2024","%d/%m/%Y")) * 100).round(2))
    end

    def test_profit_VSP500
        portfolio = Portfolio.new('test.gnucash')
        assert_equal(313670.59,(portfolio.portfolio["VSP500"].profit(Date.strptime("11/06/2024","%d/%m/%Y"))).round(2))
    end

    def test_profit_Apple
        portfolio = Portfolio.new('test.gnucash')
        assert_equal(1355355.74,(portfolio.portfolio["Apple"].profit(Date.strptime("11/06/2024","%d/%m/%Y"))).round(2))
    end

    def test_xirr_indexa
        portfolio = Portfolio.new("test.gnucash")
        assert_equal(-73.90,(portfolio.portfolio["indexa"].xirr(Date.strptime("11/06/2024","%d/%m/%Y")) * 100).round(2))
    end

    def test_report_txt
#        portfolio = Portfolio.new('test.gnucash')
        portfolio = Portfolio.new("/Users/santiagoalvarezrojo/Library/CloudStorage/GoogleDrive-santiago@ecliente.com/Mi\ unidad/gnucash/personal.gnucash")
#        portfolio = Portfolio.new("/Users/santiagoalvarezrojo/Library/CloudStorage/GoogleDrive-santiago@ecliente.com/Mi\ unidad/gnucash/family.gnucash")
        puts
        puts
#        puts portfolio.to_csv(Date.strptime("11/06/2024","%d/%m/%Y"))
        puts
        puts
#        puts portfolio.report_txt(Date.strptime("11/06/2024","%d/%m/%Y"))
        puts portfolio.report("| %-11s| %-17s| %-11s| %-24s| %-7s| %-12s| %-12s| %-12s| %-12s| %-12s| %-12s|",'|%10.2f€ | %7.2f %-9s|%10.2f€ | %-10s - %-10s |%6.2f%% |%11.2f€ |%11.2f€ |%11.2f€ |%11.2f€ |%11.2f€ |%11.2f€ |',Date.strptime("11/06/2024","%d/%m/%Y"))

#        portfolio = Portfolio.new("/Users/santiagoalvarezrojo/Library/CloudStorage/GoogleDrive-santiago@ecliente.com/Mi\ unidad/gnucash/family.gnucash")
#        puts portfolio.report_txt(Date.strptime("12/06/2024","%d/%m/%Y"))

#        puts
#        puts
#        puts portfolio.report_txt(Date.strptime("12/06/2024","%d/%m/%Y"))
#        puts portfolio.to_csv(Date.strptime("12/06/2024","%d/%m/%Y"))
    end
end
