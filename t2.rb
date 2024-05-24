include Finance
trans = []
trans << Transaction.new( -10000, date: Time.new(2012,1,1) )
trans << Transaction.new( 11000, date: Time.new(2012,1,7) )
trans << Transaction.new( -20000, date: Time.new(2012,1,1) )
trans << Transaction.new( 21000, date: Time.new(2012,1,20) )
trans << Transaction.new( -15000, date: Time.new(2012,1,5) )
trans << Transaction.new( 14000, date: Time.new(2012,1,18) )

trans.xirr.apr.to_f.round(2)
