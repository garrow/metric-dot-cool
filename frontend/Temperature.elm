module Temperature exposing (Degrees, Scale(..), Temperature, celsius, convert, converterFor, degreesOf, fahrenheit, kelvin, rankine, scaleName, scaleOf, temperature, temperatureT, toCelsius, toFahrenheit, toKelvin, toRankine, toSymbol)

import TemperatureConstants exposing (..)
import Tuple exposing (first, second)


type Scale
    = Celsius
    | Kelvin
    | Fahrenheit
    | Rankine


type alias Degrees =
    Float


type alias Temperature =
    ( Degrees, Scale )

temperature : Degrees -> Scale -> Temperature
temperature =
    \a b -> ( a, b )


scaleOf : Temperature -> Scale
scaleOf =
    Tuple.second


degreesOf : Temperature -> Degrees
degreesOf =
    Tuple.first


celsius : Degrees -> Temperature
celsius d =
    temperature d Celsius


fahrenheit : Degrees -> Temperature
fahrenheit d =
    temperature d Fahrenheit


kelvin : Degrees -> Temperature
kelvin d =
    temperature d Kelvin


rankine : Degrees -> Temperature
rankine d =
    temperature d Rankine


temperatureT : Degrees -> Scale -> Temperature
temperatureT d s =
    ( d, s )


--print : Temperature -> String
--print ( degrees, scale ) =
--    toString scale ++ " " ++ toString degrees


toSymbol : Scale -> String
toSymbol scale =
    case scale of
        Celsius ->
            "℃"

        Kelvin ->
            "K"

        Fahrenheit ->
            "℉"

        Rankine ->
            "°R"


scaleName : Scale -> String
scaleName scale =
    case scale of
        Celsius ->
            "Celsius"

        Kelvin ->
            "Kelvin"

        Fahrenheit ->
            "Fahrenheit"

        Rankine ->
            "Rankine"


converterFor : Scale -> (Temperature -> Temperature)
converterFor scale =
    case scale of
        Celsius ->
            toCelsius

        Kelvin ->
            toKelvin

        Rankine ->
            toRankine

        Fahrenheit ->
            toFahrenheit


convert : Scale -> Temperature -> Temperature
convert scale =
    converterFor scale


toRankine : Temperature -> Temperature
toRankine ( degrees, scale ) =
    case scale of
        Kelvin ->
            rankine 999

        Celsius ->
            rankine 999

        Fahrenheit ->
            rankine 999

        Rankine ->
            rankine degrees


toKelvin : Temperature -> Temperature
toKelvin ( degrees, scale ) =
    case scale of
        Kelvin ->
            kelvin degrees

        Celsius ->
            kelvin <| degrees + kelvinCelsiusDifference

        Fahrenheit ->
            kelvin <| (degrees + kelvinFahrenheitDifference) * fromFahrenheitRational

        Rankine ->
            kelvin <| 999


toCelsius : Temperature -> Temperature
toCelsius ( degrees, scale ) =
    case scale of
        Celsius ->
            celsius degrees

        Fahrenheit ->
            celsius <| (degrees - celsiusFahrenheitDifference) * fromFahrenheitRational

        Kelvin ->
            celsius <| degrees - kelvinCelsiusDifference

        Rankine ->
            celsius <| 999


toFahrenheit : Temperature -> Temperature
toFahrenheit ( degrees, scale ) =
    case scale of
        Fahrenheit ->
            fahrenheit degrees

        Celsius ->
            fahrenheit <| degrees * toFahrenheitRational + celsiusFahrenheitDifference

        Rankine ->
            fahrenheit <| degrees + kelvinFahrenheitDifference

        Kelvin ->
            fahrenheit <| (degrees + kelvinFahrenheitDifference) * fromFahrenheitRational
