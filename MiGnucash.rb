class Transaction_
    def initialize(date,investment,amount,*shares)
        @investment = investment
        @date = date
        @amount = amount
        if shares.length == 1
            @shares = shares[0]
            @price = - @amount / @shares
        end
    end

    def to_csv
        if @shares
            sh = "#{@shares.to_s.gsub(".",",")};#{@price.to_s.gsub(".",",")}"
        else
            sh = ";"
        end
        return "#{@date.strftime("%d/%m/%Y")};#{@investment};#{sh};#{@amount.to_s.gsub(".",",")}"
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
end


class Investment
    def initialize(id,desc,vl)
       @id = id
       @desc = desc
       @vl = vl
       @transactions = []
       @amount = 0
    end

    def << ( transaction )
        @transactions << transaction
        if transaction.equity?
            @amount += transaction.shares
        end
    end

    def amount
        return @amount
    end

    def to_csv
        result = ""
        @transactions.each do |transaction|
            result += transaction.to_csv + "\n"
        end
        return result
    end

    def xirr
        cf = Cashflow.new
        [
            -10000, "1-Jan-08",
              2750, "1-Mar-08",
              4250, "30-Oct-08",
              3250, "15-Feb-09",
              2750, "1-Apr-09"
        ].in_groups_of(2) do |amount, date|
            cf << Transaction.new(amount, date: date.to_date)
        end
    end
end


class Portfolio
    def initialize(spec)
        @portfolio = {}

        # equity
        book = Gnucash.open(spec[:file])
        book.accounts.each do |account|
            investment = contains(account.full_name,spec[:investments].keys)
            if investment != "" && !["EXPENSE","INCOME"].include?(account.type)
                @portfolio[investment] = Investment.new(investment,account.description,spec[:investments][investment][:vl])

                account.transactions.each do |tx|
                    shares = value = 0
                    tx.splits.each do |split|
                        if split[:account].full_name.include?(investment)
                            shares = split[:value].to_f
                        else
                            value = split[:value].to_f
                        end
                    end
                    @portfolio[investment] << Transaction_.new(tx.date,investment,value,shares)
                end
            end
        end

        # dividendos
        book.accounts.each do |account|
            if ["EXPENSE","INCOME"].include?(account.type)
                account.transactions.each do |tx|
                    investment = contains(tx.description,spec[:investments].keys)
                    if investment != ""
                        @portfolio[investment] << Transaction_.new(tx.date,investment,tx.value.to_f)
                    end
                end
            end
        end
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
end
