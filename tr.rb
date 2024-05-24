require "gnucash"

book = Gnucash.open("/Users/santiagoalvarezrojo/Library/CloudStorage/GoogleDrive-santiago@ecliente.com/Mi\ unidad/gnucash/personal.gnucash")

puts "fecha;fondo;#;€;inversión"

book.accounts.each do |account|
    if account.full_name.include?("#SCO")
        account.transactions.each do |tx|
            shares = value = 0
            tx.splits.each do |split|
                if split[:account].full_name.include?("SCO")
                    shares = split[:value].to_f
                else
                    value = split[:value].to_f
                end
            end
            price = - value / shares
            puts "#{tx.date.strftime("%d/%m/%Y")};SCO;#{shares.to_s.gsub(".",",")};#{price.to_s.gsub(".",",")};#{value.to_s.gsub(".",",")}"
        end
    end
end



book.accounts.each do |account|
    if ["EXPENSE","INCOME"].include?(account.type)
        account.transactions.each do |tx|
            if tx.description.include?("SCO")
                puts "#{tx.date.strftime("%d/%m/%Y")};#{tx.value.to_s.gsub(".",",")};#{tx.description};#{account.full_name};#{account.type}"
            end
        end
    end
end
