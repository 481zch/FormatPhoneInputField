# FormatPhoneInputField
Automatically format and split the input number according to the expected pattern, while updating the cursor position.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
import FormatPhoneInputField

/// phoneNumberLength
/// delimiter
/// expected positions
private let phoneInput = FormatPhoneInputTextField(11, " ", [3, 8])

/// 12345678901
print(phoneInput.realPhoneNumber)
/// True / False
print(phoneInput.isFinished)

```

## Requirements
iOS 10.0

## Installation

FormatPhoneInputField is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FormatPhoneInputField'
```

## Author

zangconghui, zangconghui@kanyun.com

## License

FormatPhoneInputField is available under the MIT license. See the LICENSE file for more info.
