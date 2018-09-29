module Main exposing (main)

import Browser exposing (Document, document)
import Element exposing (Element, alignRight, centerY, column, el, fill, padding, rgb, rgb255, row, spacing, table, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Round
import Temperature exposing (..)


-- Main


pinky =
    rgb255 234 213 255


shineBlue =
    rgb255 169 214 255


offWhite =
    rgb255 234 213 255


offBlack =
    rgb255 15 15 15


baseStyles =
    [ Background.color offBlack
    , Font.color offWhite
    , Font.size 16
    , Font.family [ Font.typeface "Share Tech Mono", Font.monospace ]
    ]


newView model =
    Element.layout baseStyles
        (mainLayout model)


temperatureButton : Model -> Element Msg
temperatureButton model =
    el []
        (model.currentValue
            |> scaleOf
            |> scaleName
            |> text
        )


scaleSelectors model =
    row [ width fill, spacing 30 ]
        [ temperatureButton model ]


mainLayout model =
    column
        [ Background.color offBlack
        , Font.color pinky
        , Element.padding 10
        ]
        [ scaleSelectors model
        , inputSection model
        , outputsSection model
        ]



--inputSection : Model -> Element


inputSection model =
    row []
        [ Input.text [ Border.color (rgb255 160 214 255), Font.color offBlack ]
            { label = Input.labelAbove [] (text "")
            , text = model.rawInput
            , placeholder = Nothing
            , onChange = SetInputValue
            }
        ]



--    input [ type_ "number", class "temp_input", onInput SetInputValue, value model.rawInput
--


outputsSection model =
    row [ Border.color offWhite, Element.padding 10 ] [ conversionTable model ]


conversionTable model =
    table []
        { data = modelTemps model
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


modelTemps : Model -> List ConversionDisplay
modelTemps model =
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
    ]


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
    = SetInputValue String
    | SetInputScale Scale


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetInputValue rawInputString ->
            let
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

        SetInputScale scale ->
            let
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


view : Model -> Document Msg
view model =
    { title = "Metric.cool"
    , body = [ newView model ]
    }



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
--printFull : Temperature -> String
--printFull ( degrees, scale ) =
--    let
--        name =
--            scaleName scale
--
--        roundedDegrees =
--            Round.round 2 degrees
--    in
--    name ++ " " ++ roundedDegrees
