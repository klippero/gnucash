require("bundler/setup")
require "xirr"
require "active_support/all" # for `in_groups_of`

class Transaction_
    def initialize(date,amount,*shares)
        @date = date
        @amount = amount
        if shares.length == 1
            @shares = shares[0]
            @price = - @amount / @shares
        end
    end

    def to_xirrTransaction
        return Xirr::Transaction.new(@amount,date: @date)
    end

    def to_csv(investment)
        if @shares
            sh = "#{@shares.to_s.gsub(".",",")};#{@price.to_s.gsub(".",",")}"
        else
            sh = ";"
        end
        return "#{@date.strftime("%d/%m/%Y")};#{investment};#{sh};#{@amount.to_s.gsub(".",",")}"
    end

    def type
        @shares && @shares.abs > 0 ? :equity : :dividendos
    end

    def equity?
        return self.type == :equity
    end

    def shares
        return @shares
    end

    def amount
        return @amount
    end

    def date
        return @date
    end
end


class Investment
    include Xirr # bring `Xirr` module in scope

    Price = {
        "Apple" =>
        {
            Date.strptime("11/06/2024","%d/%m/%Y") => 202.73,
        },
        "VSP500" =>
        {
            Date.strptime("11/06/2024","%d/%m/%Y") => 428.08,
        },
        "Amundi S&P 500 AS&P" =>
        {
            Date.strptime("11/06/2024","%d/%m/%Y") => 428.08,
            Date.strptime("12/06/2024","%d/%m/%Y") => 430.06,
        },
        "Amundi MSCI World" =>
        {
            Date.strptime("12/06/2024","%d/%m/%Y") => 316.31,
        },
        "Amundi S&P 500 ASP" =>
        {
            Date.strptime("11/06/2024","%d/%m/%Y") => 428.08,
            Date.strptime("12/06/2024","%d/%m/%Y") => 430.06,
        },
        "AS&P" =>
        {
            Date.strptime("11/06/2024","%d/%m/%Y") => 428.08,
            Date.strptime("12/06/2024","%d/%m/%Y") => 430.06,
        },
        "dbM" =>
        {
            Date.strptime("12/06/2024","%d/%m/%Y") => 12.08,
        },
        "IUSA" =>
        {
            Date.strptime("12/06/2024","%d/%m/%Y") => 54.421694,
        },
        "SCO" =>
        {
            Date.strptime("12/06/2024","%d/%m/%Y") => 460.1877076,
        },
    }

    def initialize(name,id)
       @name = name
       @id = id
       @transactions = []
    end

    def << ( transaction )
        @transactions << transaction
    end

    def to_csv(date=Date.today)
        result = ""
        @transactions.each do |transaction|
            if transaction.date <= date
                result += transaction.to_csv(@name) + "\n"
            end
        end
        return result
    end

    def xirr(date=Date.today)
        cf = Cashflow.new
        @transactions.each do |transaction|
            if transaction.date <= date
                cf << transaction.to_xirrTransaction
            end
        end
        cf << Transaction.new(amount(date) * price(date),date:date)

        if price(date) == 0 && amount(date).round(4) > 0
            return 0
        else
            return cf.xirr.to_f
        end
    end

    def price(date=Date.today)
        if Price.has_key?(@name) && Price[@name].has_key?(date)
            return Price[@name][date]
        else
            return 0
        end
    end

    def value(date=Date.today)
        return amount(date) * price(date)
    end

    def amount(date=Date.today)
        result = 0
        @transactions.each do |transaction|
            if transaction.date <= date && transaction.equity?
                result += transaction.shares
            end
        end
        return result
    end

    def profit(date=Date.today)
        result = aportaciones_netas(date)
        result += amount(date) * price(date)
        return result
    end

    def aportaciones_netas(date=Date.today)
        result = 0
        @transactions.each do |transaction|
            if transaction.date <= date
                result += transaction.amount
            end
        end
        return result
    end

    def profit_equity(date=Date.today)
        result = 0
        @transactions.each do |transaction|
            if transaction.date <= date && transaction.equity?
                result += transaction.amount
            end
        end
        result += amount(date) * price(date)
        return result
    end

    def profit_dividendos(date=Date.today)
        result = 0
        @transactions.each do |transaction|
            if transaction.date <= date && !transaction.equity?
                result += transaction.amount
            end
        end
        return result
    end

    def report_txt(date=Date.today)
        periodo = self.period
        first = periodo[0].strftime('%d/%m/%Y')
        if amount(date).round(2) > 0
            last = " "
        else
            last = periodo[1].strftime('%d/%m/%Y')
        end
        values = [ value(date), amount(date), @name, price(date), (xirr(date) * 100), profit(date), first, last,profit_equity(date), profit_dividendos(date) ]
        return '|%10.2f€ | %7.2f %-18s|%7.2f€ |%6.2f^ |%11.2f€ | %-10s - %-10s |%11.2f€ |%11.2f€ |' % values
    end

    def transactions
        return @transactions
    end

    def id
        return @id
    end

    def period
        first = Date.today
        last = Date.strptime("01/01/1900","%d/%m/%Y")
        @transactions.each do |transaction|
            if transaction.date < first
                first = transaction.date
            end
            if transaction.date > last
                last = transaction.date
            end
        end
        return [first,last]
    end
end


class Portfolio
    def initialize(filename)
        @portfolio = {}

        # equity
        book = Gnucash.open(filename)
        book.accounts.each do |account|
            if ["MUTUAL","STOCK"].include?(account.type)
                @portfolio[account.name] = Investment.new(account.name,account.description)
                account.transactions.each do |tx|
                    shares = amount = 0
                    tx.splits.each do |split|
                        if split[:account].full_name.include?(account.name)
                            shares = split[:value].to_f
                        else
                            amount = split[:value].to_f
                        end
                    end
                    @portfolio[account.name] << Transaction_.new(tx.date,amount,shares)
                end
            end
        end

        # dividendos
        book.accounts.each do |account|
            if ["EXPENSE","INCOME"].include?(account.type)
                account.transactions.each do |tx|
                    investment = contains(tx.description,@portfolio.keys)
                    if investment != ""
                        @portfolio[investment] << Transaction_.new(tx.date,-1 * tx.value.to_f)
                    end
                end
            end
        end
    end

    def report_txt(date=Date.today)
        result = "| %-11s| %-26s| %-8s| %-7s| %-12s| %-24s| %-12s| %-12s|\n" % ["Valor","Participaciones","Precio","Rent%","Profit","Periodo","+equipy","+dividendos"]
        @portfolio.each do |investment_str,investment|
            result << investment.report_txt(date) << "\n"
        end

        values = [ value(date), (xirr(date) * 100), profit(date) ]
        result << '|%10.2f€ |                           |         |%6.2f^ |%11.2f€ |' % values
        return result
    end

    def amount(investment)
        if @portfolio[investment]
            result = @portfolio[investment].amount
        else
            result = 0
        end
        return result
    end


    def to_csv(date=Date.today)
        result = "fecha;fondo;#;€;inversión\n"
        @portfolio.each do |investment_str,investment|
            result += investment.to_csv(date)
        end
        return result
    end


    def xirr(date=Date.today)
        cf = Xirr::Cashflow.new
        @portfolio.each do |investment_str,investment|
            investment.transactions.each do |transaction|
                if transaction.date <= date
                    cf << transaction.to_xirrTransaction
                end
            end
            cf << Xirr::Transaction.new(investment.amount(date) * investment.price(date),date:date)
        end
        return cf.xirr.to_f
    end


    def contains(string,array)
        i = 0
        encontrado = false
        while i < array.length and ! encontrado
            if string.include?(array[i])
                encontrado = true
            else
                i = i + 1
            end
        end
        if encontrado
            result = array[i]
        else
            result = ""
        end
        return result
    end

    def portfolio
        return @portfolio
    end

    def value(date=Date.today)
        result = 0
        @portfolio.each do |investment_str,investment|
            result += investment.value(date)
        end
        return result
    end

    def profit(date=Date.today)
        result = 0
        @portfolio.each do |investment_str,investment|
            result += investment.profit(date)
        end
        return result
    end
end
