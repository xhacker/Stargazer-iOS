# TagListView

[![Travis CI](https://travis-ci.org/xhacker/TagListView.svg)](https://travis-ci.org/xhacker/TagListView)
[![Version](https://img.shields.io/cocoapods/v/TagListView.svg?style=flat)](http://cocoadocs.org/docsets/TagListView/)
[![License](https://img.shields.io/cocoapods/l/TagListView.svg?style=flat)](https://github.com/xhacker/TagListView/blob/master/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

Simple and highly customizable iOS tag list view, in Swift.

Supports Storyboard, Auto Layout, and @IBDesignable.

<img alt="Screenshot" src="Screenshots/Screenshot.png" width="310">

## Usage

The most convinient way is to use Storyboard, where you can set the attributes right in the Interface Builder. With [@IBDesignable](http://nshipster.com/ibinspectable-ibdesignable/), you can see the preview in real time.

<img alt="Interface Builder" src="Screenshots/InterfaceBuilder.png" width="566">

You can add tag to the tag list view, or set custom font and alignment through code:

```swift
tagListView.textFont = UIFont.systemFontOfSize(24)
tagListView.alignment = .Center // possible values are .Left, .Center, and .Right

tagListView.addTag("TagListView")

tagListView.removeTag("meow") // all tags with title “meow” will be removed
tagListView.removeAllTags()
```

You can implement `TagListViewDelegate` to receive tag pressed event:

```swift
// ...
{
    // ...
    tagListView.delegate = self
    // ...
}

func tagPressed(title: String, tagView: TagView, sender: TagListView) {
    println("Tag pressed: \(title), \(sender)")
}
```

You can also customize a particular tag, or set tap handler for it by manipulating the `TagView` object returned by `addTag(_:)`:

```swift
let tagView = tagListView.addTag("blue")
tagView.tagBackgroundColor = UIColor.blueColor()
tagView.onTap = { tagView in
    println("Don’t tap me!")
}
```

Be aware that if you update a property (e.g. `tagBackgroundColor`) for a `TagListView`, all the inner `TagView`s will be updated.

## Installation

Use [CocoaPods](https://github.com/CocoaPods/CocoaPods):

```ruby
pod 'TagListView', '~> 1.0'
```

Or [Carthage](https://github.com/Carthage/Carthage):

```ruby
github "xhacker/TagListView" ~> 1.0
```

Or drag **TagListView** folder into your project.

### Swift 1.2?

Use [0.2](https://github.com/xhacker/TagListView/releases/tag/0.2), which is compatible with Swift 1.2.

## Contribution

Pull requests are welcome! If you want to do something big, please open an issue to let me know first.

## License

MIT
