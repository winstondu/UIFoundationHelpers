//
//  ListRowView.swift
//  Winston
//
//

import SwiftUI
import UIKit

public struct CustomListRowView<Content: View>: View {
    private let hPaddingType: PaddingHorizontalType
    private let vPaddingType: PaddingVerticalType
    private let backgroundStyle: ViewBackgroundStyle
    private let alignment: Alignment
    private let separatorPosition: SeparatorPosition
    private let separatorColor: Color
    @ViewBuilder private let content: Content

    public init(
        hPaddingType: PaddingHorizontalType = .regular,
        vPaddingType: PaddingVerticalType = .regular,
        backgroundStyle: ViewBackgroundStyle = .clear,
        alignment: Alignment = .leading,
        separatorPosition: SeparatorPosition = .none,
        separatorColor: Color = .separatorLight,
        @ViewBuilder content: () -> Content
    ) {
        self.hPaddingType = hPaddingType
        self.vPaddingType = vPaddingType
        self.backgroundStyle = backgroundStyle
        self.alignment = alignment
        self.separatorPosition = separatorPosition
        self.separatorColor = separatorColor
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.horizontal, hPaddingType.value)
            .padding(.vertical, vPaddingType.value)
//            .paddingVertical(vPaddingType.value)
            .overlay(alignment: .top) {
                if separatorPosition == .top || separatorPosition == .both {
                    DividerHSimple(separatorColor).padding(.horizontal, hPaddingType.value)
                }
            }
            .overlay(alignment: .bottom) {
                if separatorPosition == .bottom || separatorPosition == .both {
                    DividerHSimple(separatorColor).padding(.horizontal, hPaddingType.value)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(backgroundStyle.backgroundColor)
            .frame(maxWidth: .infinity, alignment: alignment)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

public struct CustomListRowButton<Content: View>: View {
    private let hPaddingType: PaddingHorizontalType
    private let vPaddingType: PaddingVerticalType
    private let backgroundStyle: ViewBackgroundStyle
    private let separatorPosition: SeparatorPosition
    private let separatorColor: Color
    private let action: () -> Void
    @ViewBuilder var content: Content

    public init(
        hPaddingType: PaddingHorizontalType = .regular,
        vPaddingType: PaddingVerticalType = .regular,
        backgroundStyle: ViewBackgroundStyle = .clear,
        separatorPosition: SeparatorPosition = .none,
        separatorColor: Color = .separatorLight,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.hPaddingType = hPaddingType
        self.vPaddingType = vPaddingType
        self.backgroundStyle = backgroundStyle
        self.separatorPosition = separatorPosition
        self.separatorColor = separatorColor
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Button(action: action, label: {
            content
                .padding(.horizontal, hPaddingType.value)
                .padding(.vertical, vPaddingType.value)
                .frame(maxWidth: .infinity, alignment: .leading)
        })
        .overlay(alignment: .top) {
            if separatorPosition == .top || separatorPosition == .both {
                DividerHSimple(separatorColor).padding(.horizontal, hPaddingType.value)
            }
        }
        .overlay(alignment: .bottom) {
            if separatorPosition == .bottom || separatorPosition == .both {
                DividerHSimple(separatorColor).padding(.horizontal, hPaddingType.value)
            }
        }
        .listRowSeparator(.hidden)
        .buttonStyle(.background(backgroundStyle))
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
    }
}

public enum PaddingHorizontalType {
    case zero
    case ultraSmall
    case small
    case compact
    case regular
    case large
    case ultraLarge
    case fixed(CGFloat)

    public var value: CGFloat {
        switch self {
        case .zero: return 0
        case .ultraSmall: return 4
        case .small: return 8
        case .compact: return 16
        case .regular: return 20
        case .large: return 24
        case .ultraLarge: return 28
        case let .fixed(padding): return padding
        }
    }
}

public enum PaddingVerticalType {
    case zero
    case ultraSmall
    case small
    case compact
    case regular
    case large
    case extra
    case fixed(CGFloat)

    public var value: CGFloat {
        switch self {
        case .zero: return 0
        case .ultraSmall: return 4
        case .small: return 8
        case .compact: return 12
        case .regular: return 16
        case .large: return 18
        case .extra: return 20
        case let .fixed(padding): return padding
        }
    }
}

public extension ButtonStyle where Self == BackgroundColorButtonStyle {
    static func background(_ cellStyle: ViewBackgroundStyle) -> BackgroundColorButtonStyle {
        BackgroundColorButtonStyle(normalColor: cellStyle.backgroundColor, pressedColor: cellStyle.highlightColor)
    }
}

public struct BackgroundColorButtonStyle: ButtonStyle {
    let normalColor: Color
    let pressedColor: Color

    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? pressedColor : normalColor)
            .animation(.linear(duration: 0.2), value: configuration.isPressed)
    }

    static func withColors(normalColor: Color, pressedColor: Color) -> BackgroundColorButtonStyle {
        BackgroundColorButtonStyle(normalColor: normalColor, pressedColor: pressedColor)
    }
}

public struct DividerHSimple: View {
    let color: Color
    let thick: CGFloat

    public init(_ color: Color = Color(uiColor: RGB_255(35, 35, 35)), _ thick: CGFloat = CGFloat.hairline * 2) {
        self.color = color
        self.thick = thick
    }

    public var body: some View {
        Rectangle()
            .frame(maxWidth: .infinity)
            .frame(height: thick)
            .foregroundColor(color)
//            .edgesIgnoringSafeArea(.horizontal)
    }
}

public func RGB_255(_ r: Int, _ g: Int, _ b: Int) -> UIColor {
    UIColor(red: CGFloat(Float(r) / 255.0), green: CGFloat(Float(g) / 255.0), blue: CGFloat(Float(b) / 255.0), alpha: 1)
}

public enum SeparatorPosition {
    case top
    case bottom
    case both
    case none
}

public enum ViewBackgroundStyle {
    case clear
    case single(Color)
    case custom(Color, Color)

    var backgroundColor: Color {
        switch self {
        case .clear: return .fullfillColor
        case let .single(color): return color
        case let .custom(color, _): return color
        }
    }

    var highlightColor: Color {
        switch self {
        case .clear: return .clear
        case let .single(color): return color
        case let .custom(_, color): return color
        }
    }
}

public extension Color {
    static let fullfillColor = Color.appSystemBackground.opacity(0.001)
}

public extension Color {
    static let appSystemBackground = UIColor.systemBackground.color
}

public extension UIColor {
    var color: Color {
        Color(uiColor: self)
    }
}

public extension Color {
    static let separatorLight = Color.dynamicColor(light: RGB_255(240, 240, 240), dark: RGB_255(35, 35, 35))
}

public extension Color {
    static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            case .light, .unspecified:
                return light
            @unknown default:
                return light
            }
        })
    }
}
