# Changelog [![Elm package](https://img.shields.io/elm-package/v/curtissimo/elm-native-modal-dialog.svg)](https://package.elm-lang.org/packages/curtissimo/elm-native-modal-dialog/latest/)

All notable changes to
[the `curtissimo/elm-native-modal-dialog` elm package](http://package.elm-lang.org/packages/curtissimo/elm-native-modal-dialog/latest)
will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.1.0/)
and this project adheres to
[Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## 3.0.0

### Added

- An `init` function to initialize the dialog state
- Configuration functions
  - `showDialog`
  - `withCancelHandler`
  - `withClassList`
  - `withCloseHandler`

### Changed

- Now only handlers of interest are registered on the `<dialog>` element

### Removed

- Access to the `DialogState` attributes

## 2.0.0

### Added

- `classList` as part of the options for creating a dialog

## 1.0.0

### Added

- `Curtissimo.NativeDialog` package
- Documentation for the `Curtissimo.NativeDialog` package
- Examples for the `Curtissimo.NativeDialog` package
- This CHANGELOG
