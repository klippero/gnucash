require 'date'


def nfv(data, guess)
    today = Date.today()
    nfv = 0

    data.each do |(cf, date)|
        datestring = date.to_s
        formatteddate = Date.parse(datestring).to_date
        t_in_days = (today - formatteddate).numerator / (today - formatteddate).denominator
        nfv = nfv + cf*((1+guess)**t_in_days)
    end
    return nfv
end


def xirr(cashflow, dates)
    # Bisection method finding the rate to zero nfv
    left = -0.99/365
    right = 9.99/365
    epsilon = 1e-8

    while ((right-left).abs > 2*epsilon) do
        midpoint = (right+left)/2
        if (nfv(data, left) * nfv(data, midpoint) > 0)
            left = midpoint
        else
            right = midpoint
        end
    end

    # Irr for daily cashflow (not in percentage format)
    irr = (right+left) / 2
    # Irr for daily cashflow multiplied by 365 to get yearly return
    irr = irr * 365
    # Annualized yield (return) reflecting compounding effect of daily returns
    irr = (1 + irr / 365) ** 365 - 1
    return irr
end


puts xirr([     -450.00    ,-8460.00    ,974.22    ,11063.09    ,-5531.55    ,4330.52    ,1920.66    ,42337.27],[     Date.parse('18-2-2010')    ,Date.parse('8-2-2021')    ,Date.parse('5-8-2020')    ,Date.parse('28-7-2021')    ,Date.parse('13-9-2021')    ,Date.parse('7-2-2023')    ,Date.parse('20-12-2023')    ,Date.parse('9-05-202024')])
