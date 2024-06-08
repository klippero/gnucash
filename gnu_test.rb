require "gnucash"


spec = {
    :personal => {
        :file => "/Users/santiagoalvarezrojo/Library/CloudStorage/GoogleDrive-santiago@ecliente.com/Mi\ unidad/gnucash/personal.gnucash",
        :securities => {
            "USA"  => {
                :val =>  53.420365
            },
            "dbW" => {
                :isin => 'ES0125746000',
                :val => 0
            },
            "dbM"  => {
                :isin => 'ES0145553006',
                :val =>  12.09
            },
            "indexa"  => {
                :isin => 'indexa',
                :val =>  0
            },
            "ING 2030" => {
                :val => 16.932014
            },
            "AS&P" => {
                :isin => 'LU0996179007',
                :val => 417.94
            },
            "#SCO" => { :val => 460.1877076 },
            "ECL"  => { :val =>  97.67671096 },
        }
    },
    :familiar => {
        :file => "/Users/santiagoalvarezrojo/Library/CloudStorage/GoogleDrive-santiago@ecliente.com/Mi\ unidad/gnucash/family.gnucash",
        :securities => {
            "MSCI" => {
                :isin => 'LU0996182563',
                :val => 312.62
            },
            "ASP" => {
                :isin => 'LU0996179007',
                :val => 422.30
            },
            "VSP" => {
                :isin => 'IE0032620787',
                :val => 57.83
            },
        }
    }
}


class Transaction
    def initialize(sec,date,amount,*shares)
        @security = sec
        @date = fecha
        @amount = amount
        if shares.length == 1
            @shares = shares[0]
        end
    end

    def to_s
        return "#{@date.strftime("%d/%m/%Y")};#{@sec};#{@shares.to_s.gsub(".",",")};#{price.to_s.gsub(".",",")};#{value.to_s.gsub(".",",")}"
    end
end


class MiGnucash
    def initialize(spec)
        book = Gnucash.open(spec[:file])
        a = 1
    end
end


mic = MiGnucash.new(spec[:personal])
puts 1
