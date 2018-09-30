module Main exposing (main)

import Browser exposing (Document, document)
import Element exposing (Element, alignRight, centerY, column, el, fill, padding, rgb, rgb255, row, spacing, table, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html as Html
import Round
import Temperature exposing (..)


--import Debugger.Main
-- Main


appName =
    "Metric.cool"


main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = noSubscriptions
        }



-- Nothing for the moment


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags_ =
    ( initialModel, Cmd.none )


type Msg
    = SetRawInputValue String
    | SetInputValue Float
    | SetInputScale Scale


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRawInputValue rawInputString ->
            let
                logged =
                    Debug.log (Debug.toString "RAW: " ++ rawInputString)

                parsedInput =
                    rawInputString
                        |> String.toFloat
                        |> Result.fromMaybe "Bad Input"

                safeInput =
                    parsedInput
                        |> Result.withDefault (degreesOf model.currentValue)

                newValue =
                    temperature safeInput (scaleOf model.currentValue)
            in
            ( { model | currentValue = newValue, rawInput = rawInputString, numericInput = safeInput }
            , Cmd.none
            )

        SetInputValue newFloat ->
            let
                newValue =
                    temperature newFloat (scaleOf model.currentValue)

                newRawInput =
                    newFloat |> String.fromFloat
            in
            ( { model
                | numericInput = newFloat
                , currentValue = newValue
                , rawInput = newRawInput
              }
            , Cmd.none
            )

        SetInputScale scale ->
            let
                logged =
                    Debug.log ("X" ++ Debug.toString scale)

                newValue =
                    ( degreesOf model.currentValue, scale )
            in
            ( { model | currentValue = newValue }, Cmd.none )



-- Model


type alias Model =
    { rawInput : String
    , numericInput : Float
    , currentValue : Temperature
    }


initialModel : Model
initialModel =
    let
        initialInput =
            26
    in
    { rawInput = String.fromInt <| initialInput
    , numericInput = initialInput
    , currentValue = celsius initialInput
    }



-- Subscriptions


noSubscriptions : Model -> Sub Msg
noSubscriptions model =
    Sub.none



-- View


view model =
    viewDocument model


viewDocument : Model -> Document Msg
viewDocument model =
    { title = appName
    , body = [ newView model ]
    }


viewHtml : Model -> Html.Html Msg
viewHtml model =
    newView model


colors =
    { pinky =
        rgb255 234 213 255
    , shineBlue =
        rgb255 169 214 255
    , offWhite =
        rgb255 234 213 255
    , offBlack =
        rgb255 15 15 15
    }


baseStyles =
    [ Background.color colors.offBlack
    , Font.color colors.offWhite
    , Font.size 16
    , Font.family [ Font.typeface "Share Tech Mono", Font.monospace ]
    ]


newView model =
    Element.layout baseStyles
        (mainLayout model)


temperatureButton : Model -> Element Msg
temperatureButton model =
    Input.button
        [ Border.color colors.pinky
        , Border.solid
        , Border.width 1
        , Element.padding 4
        ]
        { label =
            model.currentValue
                |> scaleOf
                |> scaleName
                |> text
        , onPress = Just (SetInputScale Celsius)
        }


scaleSelectors model =
    row [ width fill, spacing 30 ]
        [ temperatureButton model ]


mainLayout model =
    column
        [ Background.color colors.offBlack
        , Font.color colors.pinky
        , Element.padding 10
        , spacing 10
        ]
        [ appHeader
        , scaleSelectors model
        , inputSection model
        , outputsSection model
        ]


appHeader =
    row [ Font.size 24, Font.family [ Font.typeface "Audiowide", Font.sansSerif ] ] [ text appName ]



inputSection : Model -> Element Msg
inputSection model =
    row []
        [ textInput model
        ]


textInput model =
    Input.text
        [ Border.color (rgb255 160 214 255)
        , Font.color colors.offBlack
        ]
        { label = Input.labelAbove [] (text "Input")
        , text = model.rawInput
        , placeholder = Nothing
        , onChange = SetRawInputValue
        }

--
--sliderInput model =
--    Input.slider
--        []
--        { label = Input.labelAbove [] (text "Input #")
--        , min = -300
--        , max = 100000
--        , onChange = SetInputValue
--        , value = degreesOf model.currentValue
--        , step = Nothing
--        , thumb = Input.defaultThumb
--        }


outputsSection model =
    row
        [ Border.color colors.offWhite
        ]
        [ temperaturesTable model
        ]


conversionTable : List ConversionDisplay -> Element Msg
conversionTable conversions =
    table [ spacing 10 ]
        { data = conversions
        , columns =
            [ { header = Element.text "From"
              , width = fill
              , view =
                    \conversion ->
                        Element.text conversion.input
              }
            , { header = Element.text "To"
              , width = fill
              , view =
                    \conversion ->
                        Element.text conversion.output
              }
            ]
        }


type alias ConversionDisplay =
    { input : String
    , output : String
    }


temperaturesTable : Model -> Element Msg
temperaturesTable model =
    model
        |> extractTemperatures
        |> conversionTable


extractTemperatures : Model -> List ConversionDisplay
extractTemperatures model =
    let
        asC =
            temperature model.numericInput Celsius

        casF =
            toFahrenheit asC

        asF =
            temperature model.numericInput Fahrenheit

        fasC =
            toCelsius asF
    in
    [ { input = printNice <| asC, output = printNice casF }
    , { input = printNice <| asF, output = printNice fasC }
    , { input = printFull <| asC, output = printFull casF }
    , { input = printFull <| asF, output = printFull fasC }
    , { input = String.fromFloat (model.numericInput + 100.0), output = String.fromFloat (model.numericInput - 100.0) }
    ]



----- Util


printNice : Temperature -> String
printNice ( degrees, scale ) =
    let
        symbol =
            String.left 1 <| scaleName scale

        roundedDegrees =
            Round.round 2 degrees
    in
    symbol ++ " " ++ roundedDegrees



--
--


printFull : Temperature -> String
printFull ( degrees, scale ) =
    let
        name =
            scaleName scale

        roundedDegrees =
            Round.round 2 degrees
    in
    name ++ " " ++ roundedDegrees
