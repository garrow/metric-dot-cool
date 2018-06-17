module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


view model =
    div []
        [ header
        , mainpanel
        ]


header =
    div [ class "header" ]
        [ h1 [] [ text "Metric.cool" ]
        ]


mainpanel =
    div []
        [ valueDisplay "degrees.celsius"
        , valueDisplay "degrees.fahrenheit"
        ]

valueDisplay :  String -> Html msg
valueDisplay name  =
    div []
        [ p [] [text name],
            input
            []
            []
        ]

main =
    view "None"
