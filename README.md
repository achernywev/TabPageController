# TabPageController

[![License](https://img.shields.io/cocoapods/l/TabPageController.svg?style=flat)](http://cocoapods.org/pods/TabPageController)
[![Language](https://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)
[![Version](https://img.shields.io/cocoapods/v/TabPageController.svg?style=flat)](http://cocoapods.org/pods/TabPageController)
[![Platform](https://img.shields.io/cocoapods/p/TabPageController.svg?style=flat)](http://cocoapods.org/pods/TabPageController)
[![CocoaPods](https://img.shields.io/cocoapods/dt/TabPageController.svg?style=flat)](http://cocoapods.org/pods/TabPageController)

## Description
<img src="https://raw.githubusercontent.com/wiki/EndouMari/TabPageViewController/images/demo2.gif" width="300" align="right" hspace="20">

TabPageViewController is paging view controller and scroll tab view.

**Screenshot**

Infinity Mode

<img src="https://raw.githubusercontent.com/wiki/EndouMari/TabPageViewController/images/ScreenShot2.png" height="300">


Limited Mode

<img src="https://raw.githubusercontent.com/wiki/EndouMari/TabPageViewController/images/ScreenShot1.png" height="300">

<br clear="right">

## Customization

Use TabPageOption

* fontSize for tab item

`fontSize: CGFloat`

* currentColor for current tab item

`currentColor: UIColor`

* defaultColor for tab item
 
`defaultColor: UIColor`

* tabHeight for tab view

`tabHeight: CGFloat`

* tabMargin for tab item

`tabMargin: CGFloat`

* tabBackgroundColor for tab view

`tabBackgroundColor: UIColor`

* currentBarHeight for current bar view

`currentBarHeight: CGFloat`

* pageBackgoundColor for tab page viewcontroller 

`pageBackgoundColor: UIColor`

* isTranslucent for tab view and navigation bar 

`isTranslucent: Bool`

* hides tabbar on swipe

`hidesTabBarOnSwipe: Bool`

## Usage

`import TabPageViewController` to use TabPageViewController in your file.


### Example 

```swift
let tabPageViewController = TabPageViewController.create()
let vc1 = UIViewController()
let vc2 = UIViewController()

tabPageViewController.tabItems = [(vc1, "First"), (vc2, "Second")]

TabPageOption.currentColor = UIColor.redColor()

```

Infinity Mode 

```swift
let tabPageViewController = TabPageViewController.create()
tabPageViewController.isInfinity = true
```


## Requirements

iOS13+

## Installation

### Using CocoaPods

```ruby
use_frameworks!
pod "TabPageViewController"
```

### Using Carthage

```ruby
github "EndouMari/TabPageViewController"

```
### Manually
Copy all the files in `Pod` directory into your project.

## Author

Aleksandr Chernyshev

## License

TabPageController is available under the MIT license. See the LICENSE file for more info.
