require "gnucash"
require 'date'


sec2include = ["#SCO","USA","AS&P","dbM","ECL"]
# sec2include = ["USA"]


securities = {
    "#SCO" => { :val => 460.1877076 },
    "ECL"  => { :val =>  97.67671096 },
    "dbM"  => { :val =>  12.01 },
    "USA"  => { :val =>  53.29 },
    "AS&P" => { :val => 417.94 }
}


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

book = Gnucash.open("/Users/santiagoalvarezrojo/Library/CloudStorage/GoogleDrive-santiago@ecliente.com/Mi\ unidad/gnucash/personal.gnucash")

puts "fecha;fondo;#;€;inversión"

book.accounts.each do |account|
    sec = contains(account.full_name,sec2include)
    if sec != "" && !["EXPENSE","INCOME"].include?(account.type)
        securities[sec][:amount] = 0
        account.transactions.each do |tx|
            shares = value = 0
            tx.splits.each do |split|
                if split[:account].full_name.include?(sec)
                    shares = split[:value].to_f
                    securities[sec][:amount] += shares
                else
                    value = split[:value].to_f
                end
            end
            price = - value / shares
            puts "#{tx.date.strftime("%d/%m/%Y")};#{sec};#{shares.to_s.gsub(".",",")};#{price.to_s.gsub(".",",")};#{value.to_s.gsub(".",",")}"
        end
    end
end

book.accounts.each do |account|
    if ["EXPENSE","INCOME"].include?(account.type)
        account.transactions.each do |tx|
            sec = contains(tx.description,sec2include)
            if sec != ""
                puts "#{tx.date.strftime("%d/%m/%Y")};#{sec};;;#{(tx.value.to_f * -1).to_s.gsub(".",",")};#{tx.description};#{account.full_name}"
            end
        end
    end
end

sec2include.each do |sec|
    shares = securities[sec][:amount]
    vl = securities[sec][:val]
    total = shares * vl
    puts "#{Date.today.strftime("%d/%m/%Y")};#{sec};#{shares.to_s.gsub(".",",")};#{vl.to_s.gsub(".",",")};#{total.to_s.gsub(".",",")}"
end
