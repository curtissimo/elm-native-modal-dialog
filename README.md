`elm-native-modal-dialog` [![Build Status](https://github.com/curtissimo/elm-native-modal-dialog/workflows/CI/badge.svg)](https://github.com/curtissimo/elm-native-modal-dialog/actions?query=branch%3Amain)

Are you tired of using **janky** modal dialogs from UI packages like Bootstrap and Zurb Foundation?

Why not just use the HTML 5 `<dialog>` element? It's built into the browser, correctly handles
the modal aspect of dialog-ness, and has a style-able backdrop using the `::backdrop` 
pseudo-element.

## "What about ports?"

"What about ports," you ask.

I like the declarative nature of this over the use of ports.

This package has no ports. It uses a custom Web component to forward and report events for the
native `<dialog>` element so you don't need to worry about ports.

## Using `Curtissimo.NativeModalDialog`

This is two steps: include the Web component, then use the Elm package.

### Install the Web component

For you application, load the JavaScript file found at `./js/elm-dialog-proxy.js`. It is Vanilla
JavaScript, so you can just copy the file to your project and either include it from a `<script>`
tag or through a JavaScript build process.

### Using the Elm package

You'll need something to let your Elm code know when to show the element.

    type alias Model =
        { showDialog : Bool }

Then, you'll want a message to show the dialog and one to notify the page when the dialog has been
closed.

    type Msg
        = DialogClosed
        | ShowDialog

Your `update` function responds to those events and sets `model.showDialog` accordingly.

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        case msg of
            DialogClosed ->
                ( { model | showDialog = False }
                , Cmd.none
                )

            ShowDialog ->
                ( { model | showDialog = True }
                , Cmd.none
                )


Once you have that, you're ready to set up your view.

    view : Model -> Html Msg
    view model =
        let
            dialogOptions =
                { id = "my-dialog"
                , cancel = Dialog.allowDefault DialogClosed
                , close = DialogClosed
                , showDialog = model.showDialog
                }
        in
        Html.main_ []
            [ Dialog.view dialogOptions
                [ Html.form [ Html.Events.onSubmit DoSomething ]
                    [ Html.header []
                        [ Html.h1 [] [ Html.text "My Dialog" ] ]
                    , Html.section []
                        [ Html.p [] 
                            [ Html.text "This is in a <dialog>!" ]
                        , Html.p []
                            [ Html.text "You can hit the "
                            , Html.kbd [] [ Html.text "Esc" ]
                            , Html.text " key to cancel it"
                            ]
                        ]
                    , Html.div []
                        [ Html.button []
                            [ Html.text "Submit" ]
                        , Html.button
                            [ Attrs.attribute "formmethod" "dialog" ]
                            [ Html.text "Close" ]
                        ]
                    ]
                ]
            ]
