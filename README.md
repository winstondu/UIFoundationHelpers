# WinstonUIFoundation

Reusable SwiftUI and UIKit foundations for iOS applications. The package includes visual components, view modifiers, UIKit extensions, and cursor-based pagination tools.

## Requirements

- Swift 6.3 or later
- iOS 26 or later

## Installation

Add the package to your project with Swift Package Manager:

```swift
dependencies: [
    .package(
        url: "https://github.com/winstondu/UIFoundationHelpers",
        branch: "main"
    ),
]
```

Then add the `WinstonUIFoundation` product to your target dependencies:

```swift
.target(
    name: "YourTarget",
    dependencies: ["WinstonUIFoundation"]
)
```

## Usage

```swift
import SwiftUI
import WinstonUIFoundation

struct BackgroundView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            DotPatternView(
                dotRadius: 1.5,
                spacing: 28,
                jitter: 10,
                opacity: 0.25
            )
        }
    }
}
```

## Included components

- Toasts, confirmation flows, list rows, gradients, and looping video
- Variable blur, liquid-glass helpers, bounce effects, and reveal rendering
- Color, image, date, geometry, inset, and UIKit extensions
- Cursor-based pagination with pull-to-refresh and load-more support
- Configurable pagination indicators, empty states, and error states

The package has no external dependencies.
