# AlternativeARKit
**This is the source code for my Medium article on a custom ARKit alternative!**

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
