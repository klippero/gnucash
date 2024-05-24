require "gnucash"

book = Gnucash.open("personal.gnucash")

book.accounts.each do |account|
    puts "#{account.full_name}: #{account.final_balance}"
end

act = book.find_account_by_full_name("b2) Gastos:VA70")
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
