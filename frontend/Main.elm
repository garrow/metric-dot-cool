module Main exposing (Model, Msg(..), celsiusButton, fahrenheitButton, header, initialModel, main, mainpanel, matrixDisplay, printFull, printNice, scaleButton, temperatureInput, temperatureOutputs, update, valueDisplay, view)

import Browser exposing (Document, document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Round
import Temperature exposing (..)


-- Main

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
                    Result.fromMaybe "Bad Input" (String.toFloat rawInputString)

                safeInput =
                    Result.withDefault (degreesOf model.currentValue) parsedInput

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
    , body =
        [ div []
            [ header
            , mainpanel model
            ]
        ]
    }


header =
    div [ class "heading" ]
        [ h1 [] [ text "Metric.cool" ]
        ]


mainpanel : Model -> Html Msg
mainpanel model =
    div []
        [ temperatureInput model
        , div [ class "scale_selector" ]
            [ celsiusButton model
            , fahrenheitButton model
            ]
        , temperatureOutputs model.currentValue
        , matrixDisplay model
        ]


temperatureOutputs : Temperature -> Html Msg
temperatureOutputs temperature =
    let
        inF =
            toFahrenheit temperature

        inC =
            toCelsius temperature
    in
    div []
        [ p [] [ text <| printFull <| inC ]
        , p [] [ text <| printFull <| inF ]
        ]


fahrenheitButton : Model -> Html Msg
fahrenheitButton model =
    scaleButton Fahrenheit "degrees.fahrenheit" model.currentValue


celsiusButton : Model -> Html Msg
celsiusButton model =
    scaleButton Celsius "degrees.celsius" model.currentValue


scaleButton : Scale -> String -> Temperature -> Html Msg
scaleButton scale label currentValue =
    let
        classes =
            if scaleOf currentValue == scale then
                "button active"
            else
                "button"
    in
    p [ class classes, onClick <| SetInputScale scale ] [ text label ]


temperatureInput : Model -> Html Msg
temperatureInput model =
    input [ type_ "number", class "temp_input", onInput SetInputValue, value model.rawInput ] []


valueDisplay : String -> String -> Html Msg
valueDisplay name inputValue =
    div []
        [ p [] [ text name ]
        , input [ type_ "number", onInput SetInputValue, value inputValue ] []
        ]


matrixDisplay : Model -> Html Msg
matrixDisplay model =
    let
        asC =
            temperature model.numericInput Celsius

        casF =
            toFahrenheit asC

        asF =
            temperature model.numericInput Fahrenheit

        fasC =
            toCelsius asF

        thAttrs =
            [ class "" ]
    in
    div []
        [ table [ class "output_matrix" ]
            [ thead [] []
            , tbody []
                [ tr []
                    [ th thAttrs [ text <| printNice asC ]
                    , td [] [ text <| printNice casF ]
                    ]
                , tr []
                    [ th thAttrs [ text <| printNice asF ]
                    , td [] [ text <| printNice fasC ]
                    ]
                ]
            ]
        ]



--- Util


printNice : Temperature -> String
printNice ( degrees, scale ) =
    let
        symbol =
            String.left 1 <| scaleName scale

        roundedDegrees =
            Round.round 2 degrees
    in
    symbol ++ " " ++ roundedDegrees


printFull : Temperature -> String
printFull ( degrees, scale ) =
    let
        name =
            scaleName scale

        roundedDegrees =
            Round.round 2 degrees
    in
    name ++ " " ++ roundedDegrees
