require "gnucash"


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

# securities = ["#SCO","USA","AS&P","dbM","ECL"]
securities = ["SCO"]

book.accounts.each do |account|
    sec = contains(account.full_name,securities)
    if sec != "" && !["EXPENSE","INCOME"].include?(account.type)
        account.transactions.each do |tx|
            shares = value = 0
            tx.splits.each do |split|
                if split[:account].full_name.include?(sec)
                    shares = split[:value].to_f
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
            sec = contains(tx.description,securities)
            if sec != ""
                puts "#{tx.date.strftime("%d/%m/%Y")};#{sec};;;#{(tx.value.to_f * -1).to_s.gsub(".",",")};#{tx.description};#{account.full_name}"
            end
        end
    end
end
