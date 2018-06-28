module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Temperature exposing (..)
import Round


-- Main


main =
    Html.beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }


type Msg
    = SetInputValue String
    | SetInputScale Scale


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetInputValue rawInputString ->
            let
                parsedValue =
                    Result.withDefault (degreesOf model.currentValue) (String.toFloat rawInputString)

                newValue =
                    temperature parsedValue (scaleOf model.currentValue)
            in
            { model | currentValue = newValue, rawInput = rawInputString }

        SetInputScale scale ->
            let
                newValue =
                    ( degreesOf model.currentValue, scale )
            in
            { model | currentValue = newValue }



-- Update


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
    { rawInput = toString <| initialInput
    , numericInput = initialInput
    , currentValue = celsius initialInput
    }



-- View


view : Model -> Html Msg
view model =
    div []
        [ header
        , mainpanel model
        ]


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
