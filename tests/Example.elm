module Example exposing (..)

import Expect
import Test exposing (..)


suite : Test
suite =
    describe "This modlue"
        [ test "Is it okay?" <|
            \_ ->
                Expect.equal True True
        ]
