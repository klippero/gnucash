require "gnucash"

book = Gnucash.open("/Users/santiagoalvarezrojo/Library/CloudStorage/GoogleDrive-santiago@ecliente.com/Mi\ unidad/gnucash/personal.gnucash")

puts "date;amount;description;account"

book.accounts.each do |account|
    account.transactions.each do |tx|
        if tx.description.include?("SCO")
            puts "#{tx.date.strftime("%d/%m/%Y")};#{tx.value.to_s.gsub(".",",")};##{tx.description};#{account.full_name}"
        end
    end
end

act = book.find_account_by_full_name("a1) Activos:3. Empresas:#SCO SocialCo")
balance = Gnucash::Value.zero
act.transactions.each do |txn|
    balance += txn.value
    $stdout.printf("%s  %8s  %8s  %s\n",
                 txn.date,
                 txn.value,
                 balance,
                 txn.description)
end

year = Date.today.year
delta = act.balance_on("#{year}-12-31") - act.balance_on("#{year - 1}-12-31")
puts "You've saved #{delta} this year so far!"
