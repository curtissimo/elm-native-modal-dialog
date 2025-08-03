module Example exposing (suite)

import Expect
import Test exposing (..)


suite : Test
suite =
    describe "This modlue"
        [ test "Is it okay?" <|
            \_ ->
                Expect.equal True True
        ]
