require 'date'
require 'bigdecimal/newton'
require 'bigdecimal/math'

include Newton

class XIRR
  def initialize(datevalues)
    @datevalues = datevalues
    @zero = BigDecimal::new("0.0")
    @one  = BigDecimal::new("1.0")
    @two  = BigDecimal::new("2.0")
    @ten  = BigDecimal::new("10.0")
    @eps  = BigDecimal::new("1.0e-16")
  end

  def eps; @eps end
  def one; @one end
  def two; @two end
  def ten; @ten end
  def zero; @zero end


  def values(x)
    initial = @datevalues[0][:date]
    xirr = Array.new

    xirr << @datevalues.reduce(0) do |acc, transaction|
      exponent = (transaction[:date] - initial) / BigDecimal::new("365")

      #nth = (@one + x[0]) ** exponent
      nth = BigMath.exp(exponent * BigMath.log(@one + x[0], 15), 15)
      iterant = transaction[:value] / nth

      acc + iterant
    end
    xirr
  end
end

trans = Array.new

# LibreOffice Calc result 0.362709696
trans << { value: BigDecimal.new("-1000"), date: Date.parse("2011-08-08")}
trans << { value: BigDecimal.new("400"),   date: Date.parse("2011-09-13")}
trans << { value: BigDecimal.new("650"),   date: Date.parse("2011-10-18")}


xirrfunc = XIRR.new(trans)
z = [xirrfunc.zero]
nlsolve(xirrfunc, z)
puts "Final: #{(z[0].to_f*100).round(2)}%"
