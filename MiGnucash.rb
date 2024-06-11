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
        },
    }

    def initialize(name)
       @name = name
       @transactions = []
    end

    def << ( transaction )
        @transactions << transaction
    end

    def to_csv
        result = ""
        @transactions.each do |transaction|
            result += transaction.to_csv(@name) + "\n"
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
        return cf.xirr.to_f
    end

    def price(date=Date.today)
#        if Price.haskey?(@name) && Price[@name].haskey?(date)
            return Price[@name][date]
#        else
#            return 0
#        end
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

    def report_txt(date=Date.today)
        "#{value(date).round(2)}€ (#{amount(date).round(2)} #{@name} x #{price(date).round(2)}€) #{(xirr(date) * 100).round(2) }% #{profit(date).round(2)}€"
    end

    def transactions
        return @transactions
    end
end


class Portfolio
    def initialize(filename)
        @portfolio = {}

        # equity
        book = Gnucash.open(filename)
        book.accounts.each do |account|
            if ["MUTUAL","STOCK"].include?(account.type)
                @portfolio[account.name] = Investment.new(account.name)
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
        result = ""
        @portfolio.each do |investment_str,investment|
            result << investment.report_txt(date) << "\n"
        end
        result << "#{value(date).round(2)} #{(xirr(date) * 100).round(2) }% #{profit(date).round(2)}"
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


    def to_csv
        result = "fecha;fondo;#;€;inversión\n"
        @portfolio.each do |investment_str,investment|
            result += investment.to_csv
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
