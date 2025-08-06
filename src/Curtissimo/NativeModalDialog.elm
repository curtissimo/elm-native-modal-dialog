-- SPDX-License-Identifier: BSD-3-Clause
-- Copyright (c) 2025 curtissimo, llc. All Rights Reserved.


module Curtissimo.NativeModalDialog exposing
    ( init, showDialog, withCancelHandler, withClassList, withCloseHandler
    , view
    , DialogCancelHandler, allowDefault
    , DialogState
    )

{-| This module provides the Elm bindings to render
and work with a native HTML 5 <dialog> element.

It uses the custom `elm-dialog-proxy` Web component to
bridge between setting attributes and properties to the
native dialog.

    import Curtissimo.NativeDialog as Dialog

    view : Model -> Browser.Document Msg
    view model =
        let
            dialogOptions =
                Dialog.init { id = "my-dialog" }
                    |> Dialog.showDialog model.showDialog
                    |> Dialog.withCancelHandler
                        (Dialog.allowDefault DialogCanceled)
                    |> Dialog.withClassList
                        [ ( "dialog", True ) ]
                    |> Dialog.withCloseHandler DialogClosed
        in
        Html.main_ []
            [ Dialog.view dialogOptions
                [ Html.form
                    [ Html.Events.onSubmit HideDialog ]
                    [ Html.div []
                        [ Html.header []
                            [ Html.p [] [ Html.text "My Dialog" ] ]
                        , Html.section []
                            [ Html.p []
                                [ Html.text "This is a <dialog> element!" ]
                            , Html.p []
                                [ Html.text "You can hit the "
                                , Html.kbd [] [ Html.text "Esc" ]
                                , Html.text " key to cancel it"
                                ]
                            ]
                        , Html.div [}
                            [ Html.div []
                                [ Html.button []
                                    [ Html.text "Submit" ]
                                , Html.button
                                    [ Attrs.attribute "formmethod" "dialog"]
                                    [ Html.text "Close" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]


## Configuring

@docs init, showDialog, withCancelHandler, withClassList, withCloseHandler


## Rendering

@docs view


## Options

@docs DialogCancelHandler, allowDefault


## Opaque types

@docs DialogState

-}

import Html exposing (Html)
import Html.Attributes as Attrs exposing (classList)
import Html.Events
import Json.Decode
import Json.Encode


type alias CustomHandler msg =
    { message : msg
    , stopPropagation : Bool
    , preventDefault : Bool
    }


{-| Specify the `msg` and a flag to indicate if the
cancel event should be prevented from occurring.

  - `message` is the value you want to pass to the page's
    `update` function.
  - `preventDefault` will prevent the dialog from closing
    if set to `True`.

-}
type alias DialogCancelHandler msg =
    { message : msg
    , preventDefault : Bool
    }


{-| The state needed by the native dialog to properly render.
-}
type DialogState msg
    = DialogState
        { id : String
        , cancel : Maybe (Json.Decode.Decoder (DialogCancelHandler msg))
        , classList : List ( String, Bool )
        , close : Maybe msg
        , showDialog : Bool
        }


{-| If you never will prevent the default behavior of the **cancel** event
of the dialog, you can use this convenience function.
-}
allowDefault : msg -> Json.Decode.Decoder (DialogCancelHandler msg)
allowDefault msg =
    Json.Decode.succeed
        { message = msg
        , preventDefault = False
        }


cancelHandlerToCustomHandler : DialogCancelHandler msg -> CustomHandler msg
cancelHandlerToCustomHandler { message, preventDefault } =
    { message = message
    , preventDefault = preventDefault
    , stopPropagation = False
    }


{-| Initialize the dialog state with the HTML id to use for the dialog.
-}
init : { id : String } -> DialogState msg
init { id } =
    DialogState
        { id = id
        , cancel = Nothing
        , classList = []
        , close = Nothing
        , showDialog = False
        }


maybeToList : Maybe a -> List a
maybeToList maybe =
    case maybe of
        Nothing ->
            []

        Just a ->
            [ a ]


{-| Set the flag in the dialog state to show or hide the dialog.
-}
showDialog : Bool -> DialogState msg -> DialogState msg
showDialog show (DialogState state) =
    DialogState { state | showDialog = show }


{-| Set the `Json.Decode.Decoder` to use when the dialog is canceled
with the `Esc` key. This provides you a way to stop propagation on the
event.

**Note**: This only fires when the dialog is dismissed using the `Esc` key

-}
withCancelHandler : Json.Decode.Decoder (DialogCancelHandler msg) -> DialogState msg -> DialogState msg
withCancelHandler handler (DialogState state) =
    DialogState { state | cancel = Just handler }


{-| Set the class list that will be applied to the <dialog> element.
-}
withClassList : List ( String, Bool ) -> DialogState msg -> DialogState msg
withClassList classList (DialogState state) =
    DialogState { state | classList = classList }


{-| Set the message you want to have fired when the dialog is closed.
-}
withCloseHandler : msg -> DialogState msg -> DialogState msg
withCloseHandler handler (DialogState state) =
    DialogState { state | close = Just handler }


{-| Render the <dialog> element and the proxy handler needed to control the
dialog.

**Note**: Make sure you have included the `elm-dialog-proxy.js` in your page
or as part of your build.

-}
view : DialogState msg -> List (Html msg) -> Html msg
view (DialogState options) children =
    let
        closeDecoder =
            options.close
                |> maybeToList
                |> List.map
                    (\x ->
                        Json.Decode.succeed
                            { message = x
                            , stopPropagation = False
                            , preventDefault = False
                            }
                    )
                |> List.map (Html.Events.custom "close")

        cancelDecoder =
            options.cancel
                |> maybeToList
                |> List.map (Json.Decode.map cancelHandlerToCustomHandler)
                |> List.map (Html.Events.custom "cancel")

        dialogAttrs =
            [ Attrs.for options.id
            , Attrs.property "open" (Json.Encode.bool options.showDialog)
            ]
                ++ closeDecoder
                ++ cancelDecoder
    in
    Html.div []
        [ Html.node "elm-dialog-proxy"
            dialogAttrs
            []
        , Html.node "dialog"
            [ Attrs.id options.id
            , Attrs.classList options.classList
            ]
            children
        ]
