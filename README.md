# AlternativeARKit
**This is the source code for my Medium article on a custom ARKit alternative!**

![][image]

Note that my "Alternative" is by no means a replacement for the highly polished, extremely accurate, outstandingly realistic ARKit. It doesn't come close at all, even, and it is highly limited in terms of use case as well as required preconditions.

However, my "Alternative" is a very fast, efficient, not-memory-hogging program that serves as the backbone of my app.

## Potential Use Cases
Because this custom alternative requires a frequently-updating location provider (for example, Vision giving us the coordinates of detected text every second), this project is highly limited in use case.

The most obvious use case is a Text-Finding app (like my app [Find](https://apps.apple.com/app/find-command-f-for-camera/id1506500202)).

But the code is very simple, and you can definitely adjust it to your needs!
Here's some ideas:

- Live translator like Google Translator
- QR Code overlay (place a rectangle on detected QR Codes)
- Custom anchors (Use CoreML to look for images, then place a rectangle on top of it (like `ARImageTrackingConfiguration` except 10x faster, but however a lot less accurate...)

[image]: https://raw.githubusercontent.com/zjohnzheng/AlternativeARKit/master/images/ARProjection.png "Logo Title Text 2"

## License
```
MIT License

Copyright (c) 2020 A. Zheng

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
