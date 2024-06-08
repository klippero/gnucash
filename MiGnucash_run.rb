require "gnucash"
require_relative "MiGnucash"

spec = {
    :personal => {
        :file => "/Users/santiagoalvarezrojo/Library/CloudStorage/GoogleDrive-santiago@ecliente.com/Mi\ unidad/gnucash/personal.gnucash",
        :investments => {
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
            "#SCO" => {
                :val => 460.1877076
            },
            "ECL"  => {
                :val =>  97.67671096
            },
        }
    },
    :familiar => {
        :file => "/Users/santiagoalvarezrojo/Library/CloudStorage/GoogleDrive-santiago@ecliente.com/Mi\ unidad/gnucash/family.gnucash",
        :investments => {
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


mg = MiGnucash.new(spec[:personal])
