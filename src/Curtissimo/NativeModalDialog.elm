-- SPDX-License-Identifier: BSD-3-Clause
-- Copyright (c) 2025 curtissimo, llc. All Rights Reserved.


module Curtissimo.NativeModalDialog exposing
    ( view
    , DialogCancelHandler, DialogView, allowDefault
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
                { id = "my-dialog"
                , cancel = Dialog.allowDefault DialogCanceled
                , close = DialogClosed
                , showDialog = model.showDialog
                }
        in
        { title = "Example modal dialog"
        , body =
            [ Html.button [ Html.Events.onClick ShowDialog ]
                [ Html.text "Show the dialog" ]
            , Dialog.view dialogOptions
                [ Html.h1 [] [ Html.text "My Dialog" ]
                , Html.div []
                    [ Html.button
                        [ Html.Events.onClick HideDialog ]
                        [ Html.text "Close" ]
                    ]
                ]
            ]
        }


# Rendering

@docs view


# Options

@docs DialogCancelHandler, DialogView, allowDefault

-}

import Html exposing (Html)
import Html.Attributes as Attrs
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


{-| The options needed by the native dialog to properly
render.

  - `id` is the value that will be used as the <dialog> element's
    `id` property.
  - `cancel` provides a handler for the **cancel** event which can
    prevent the default behavior of the dialog and keep it open.
  - `close` provides a handler for the **close** event.
  - `showDialog` will show the modal dialog if `True`.

-}
type alias DialogView msg =
    { id : String
    , cancel : Json.Decode.Decoder (DialogCancelHandler msg)
    , close : msg
    , showDialog : Bool
    }


cancelHandlerToCustomHandler : DialogCancelHandler msg -> CustomHandler msg
cancelHandlerToCustomHandler { message, preventDefault } =
    { message = message
    , preventDefault = preventDefault
    , stopPropagation = False
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


{-| Render the <dialog> element and the proxy handler needed to control the
dialog.

**Note**: Make sure you have included the `elm-dialog-proxy.js` in your page
or as part of your build.

-}
view : DialogView msg -> List (Html msg) -> Html msg
view options children =
    let
        closeDecoder =
            Json.Decode.succeed
                { message = options.close
                , stopPropagation = False
                , preventDefault = False
                }

        cancelDecoder =
            options.cancel
                |> Json.Decode.map cancelHandlerToCustomHandler

        dialogAttrs =
            [ Html.Events.custom "close" closeDecoder
            , Html.Events.custom "cancel" cancelDecoder
            , Attrs.for options.id
            , Attrs.property "open" (Json.Encode.bool options.showDialog)
            ]
    in
    Html.div []
        [ Html.node "elm-dialog-proxy"
            dialogAttrs
            []
        , Html.node "dialog"
            [ Attrs.id options.id ]
            children
        ]
