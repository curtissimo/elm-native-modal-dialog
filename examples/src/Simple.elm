module Simple exposing (main)

import Browser
import Curtissimo.NativeModalDialog as Dialog
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { showDialog : Bool
    , whatHappened : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { showDialog = False
      , whatHappened = ""
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = DialogCanceled
    | DialogClosed
    | ShowDialog
    | HideDialog


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DialogCanceled ->
            ( { model | whatHappened = "Dialog canceled", showDialog = False }
            , Cmd.none
            )

        DialogClosed ->
            ( { model | whatHappened = "Dialog closed", showDialog = False }
            , Cmd.none
            )

        ShowDialog ->
            ( { model | whatHappened = "Dialog shown", showDialog = True }
            , Cmd.none
            )

        HideDialog ->
            ( { model | whatHappened = "Dialog hidden", showDialog = False }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    let
        dialogOptions =
            { id = "my-dialog"
            , cancel = Dialog.allowDefault DialogCanceled
            , classList = []
            , close = DialogClosed
            , showDialog = model.showDialog
            }
    in
    Html.main_ []
        [ Html.div [ Attrs.class "section" ]
            [ Html.div [ Attrs.class "container content" ]
                [ Html.h1 [] [ Html.code [] [ Html.text "curtissimo/elm-native-modal-dialog" ] ]
                , Html.p [] [ Html.text "Click the button to show the native modal dialog." ]
                , Html.button [ Html.Events.onClick ShowDialog, Attrs.class "button is-primary" ]
                    [ Html.text "Show the dialog" ]
                , Html.div [] [ Html.text ("Event: " ++ model.whatHappened) ]
                ]
            ]
        , Dialog.view dialogOptions
            [ Html.form [ Html.Events.onSubmit HideDialog, Attrs.class "modal", Attrs.style "display" "block", Attrs.style "position" "static" ]
                [ Html.div [ Attrs.class "modal-card" ]
                    [ Html.header [ Attrs.class "modal-card-head" ]
                        [ Html.p [ Attrs.class "modal-card-title" ] [ Html.text "My Dialog" ]
                        , Html.button [ Attrs.class "delete", Attrs.attribute "formmethod" "dialog" ] []
                        ]
                    , Html.section [ Attrs.class "modal-card-body" ]
                        [ Html.p [] [ Html.text "This is a <dialog> element!" ]
                        , Html.p []
                            [ Html.text "You can hit the "
                            , Html.kbd [] [ Html.text "Esc" ]
                            , Html.text " key to cancel it"
                            ]
                        ]
                    , Html.div [ Attrs.class "modal-card-foot" ]
                        [ Html.div [ Attrs.class "buttons" ]
                            [ Html.button
                                [ Attrs.class "button is-success" ]
                                [ Html.text "Submit" ]
                            , Html.button
                                [ Attrs.attribute "formmethod" "dialog", Attrs.class "button" ]
                                [ Html.text "Close" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
