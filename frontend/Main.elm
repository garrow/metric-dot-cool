module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Temperature exposing (..)


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
    , currentValue : Temperature
    }


initialModel : Model
initialModel =
    let
        initialInput =
            26
    in
    { rawInput = toString <| initialInput
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
        [ p [] [ text <| print <| inC ]
        , p [] [ text <| print <| inF ]
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
