module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Http
import Json.Decode as D



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }



-- MODEL


type alias LoadingModel =
    ()


type alias ReadyModel =
    Int


type Model
    = LoadingModel LoadingModel
    | ReadyModel ReadyModel


init : () -> ( Model, Cmd Msg )
init _ =
    ( LoadingModel (), getSavedValue (LoadingMsg << GotSavedValue) )



-- UPDATE


type LoadingMsg
    = GotSavedValue (Result Http.Error Int)


type ReadyMsg
    = Increment
    | Decrement
    | Refresh
    | GotRefreshSavedValue (Result Http.Error Int)


type Msg
    = LoadingMsg LoadingMsg
    | ReadyMsg ReadyMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( LoadingMsg loadingMsg, LoadingModel loadingModel ) ->
            let
                ( model_, msg_ ) =
                    updateLoading loadingMsg loadingModel
            in
            ( model_, Cmd.map LoadingMsg msg_ )

        ( ReadyMsg readyMsg, ReadyModel readyModel ) ->
            let
                ( model_, msg_ ) =
                    updateReady readyMsg readyModel
            in
            ( ReadyModel model_, Cmd.map ReadyMsg msg_ )

        _ ->
            ( model, Cmd.none )


updateLoading : LoadingMsg -> LoadingModel -> ( Model, Cmd LoadingMsg )
updateLoading msg _ =
    case msg of
        GotSavedValue (Ok value) ->
            ( ReadyModel value, Cmd.none )

        GotSavedValue (Err _) ->
            ( ReadyModel 0, Cmd.none )


updateReady : ReadyMsg -> ReadyModel -> ( ReadyModel, Cmd ReadyMsg )
updateReady msg value =
    case msg of
        Increment ->
            ( value + 1, Cmd.none )

        Decrement ->
            ( value - 1, Cmd.none )

        Refresh ->
            ( value, getSavedValue GotRefreshSavedValue )

        GotRefreshSavedValue (Ok refeshedValue) ->
            ( refeshedValue, Cmd.none )

        GotRefreshSavedValue (Err _) ->
            ( value, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        LoadingModel loadingModel ->
            viewLoading loadingModel |> Html.map LoadingMsg

        ReadyModel readyModel ->
            viewReady readyModel |> Html.map ReadyMsg


viewLoading : LoadingModel -> Html LoadingMsg
viewLoading _ =
    div [] [ text "Loading..." ]


viewReady : ReadyModel -> Html ReadyMsg
viewReady readyModel =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (String.fromInt readyModel) ]
        , button [ onClick Increment ] [ text "+" ]
        , button [ onClick Refresh ] [ text "Refresh" ]
        ]


getSavedValue : (Result Http.Error Int -> msg) -> Cmd msg
getSavedValue message =
    Http.get
        { url = "http://localhost:9005"
        , expect = Http.expectJson message savedValueDecoder
        }


savedValueDecoder : D.Decoder Int
savedValueDecoder =
    D.field "value" D.int
