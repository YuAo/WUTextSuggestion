#WUTextSuggestion

A text suggestion toolkit for iOS.

![ScreenShot](Screenshots/screenshot.png)

##What can it do?

`WUTextSuggestion` is still early in development, it supports **@ (at)** and ** # (hashtag, twitter style)** suggestions for `UITextView` currently.

`WUTextSuggestion` aims to be a full featured text suggestion toolkit for iOS. 

It can easily be integrate it in your project with only couple lines of code.

It allows you to load text suggestions asynchronously from a remote server.

It is fully customizable. You can design your own text suggestion display controller to work with it.

##What's included?

`WUTextSuggestion` is consists of two parts.

####WUTextSuggestionController

`WUTextSuggestionController` provides the text searching and checking function. It tells you when and how you should give your user text suggestions.

####WUTextSuggestionDisplayController

`WUTextSuggestionDisplayController`, a text suggestion display controller based on `UIMenuController`. It asks it's `dataSource` for the text suggestions, and display it beautifully on the screen.

##Usage

##Roadmap

##Requirements

- Automatic Reference Counting (ARC)
- iOS 5.0+
- Xcode 4.5+

##Contributing

If you find a bug and know exactly how to fix it, please open a pull request.

If you can't make the change yourself, please open an issue after making sure that one isn't already logged.

##License

The MIT license, as aways.