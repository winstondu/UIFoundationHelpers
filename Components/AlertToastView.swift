
import SwiftUI
import UIKit

// MARK: - Public API (renamed)

public enum PopPlacement {
    case head
    case mid
    case foot
}

public enum PopPalette {
    case auto
    case invert
}

public enum PopTactile {
    case good
    case caution
    case bad
    case quiet

    @MainActor
    func pulse() {
        let generator = UINotificationFeedbackGenerator()
        switch self {
        case .good:
            generator.notificationOccurred(.success)
        case .caution:
            generator.notificationOccurred(.warning)
        case .bad:
            generator.notificationOccurred(.error)
        case .quiet:
            break
        }
    }
}

// MARK: - Default content (keeps your previous header/detail look)

public struct PopDefaultContent: View {
    var header: String?
    var detail: String?
    var showsChevron: Bool

    public init(header: String?, detail: String?, showsChevron: Bool) {
        self.header = header
        self.detail = detail
        self.showsChevron = showsChevron
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let header {
                HStack(spacing: 6) {
                    Text(header)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)

                    if showsChevron {
                        Image(systemName: "chevron.right")
                            .imageScale(.small)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let detail {
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

public struct PopSurface<Content: View>: View {
    let palette: PopPalette
    let onTap: (() -> Void)?
    @ViewBuilder let content: () -> Content

    @Environment(\.colorScheme) private var scheme

    public init(palette: PopPalette = .auto,
                onTap: (() -> Void)? = nil,
                @ViewBuilder content: @escaping () -> Content)
    {
        self.palette = palette
        self.onTap = onTap
        self.content = content
    }

    public var body: some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .environment(\.colorScheme, resolvedScheme)
            .onTapGesture { onTap?() }
    }

    private var resolvedScheme: ColorScheme {
        switch palette {
        case .auto:
            return scheme
        case .invert:
            return scheme == .dark ? .light : .dark
        }
    }

    private var backgroundColor: Color {
        Color(hex: 0x222222)
    }
}

// MARK: - Presentation Hub

@MainActor
public enum PopToast {
    // Tunables
    static let appearDisappear: TimeInterval = 0.22
    static let popScale: CGFloat = 0.82
    static let horizontalMax: CGFloat = 400
    static let edgeTopPadding: CGFloat = 0
    static let edgeBottomPadding: CGFloat = 72

    // State
    static var activeView: UIView?

    // MARK: A) New: Generic entry point that accepts ANY SwiftUI view

    @discardableResult
    public static func show<Content: View>(
        tactile: PopTactile? = nil,
        at placement: PopPlacement = .head,
        palette: PopPalette = .invert,
        visibleFor duration: TimeInterval = 5,
        onTap: (() -> Void)? = nil,
        onFinish: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> Bool {
        DispatchQueue.main.async {
            removeActiveIfNeeded()
            guard let window = keyWindow() else { return }

            // Build hosting with user-provided content wrapped in PopSurface chrome
            let (container, host) = buildHost(
                palette: palette,
                onTap: nil, // will be reassigned after container exists
                content: { AnyView(content()) }
            )

            // Reassign rootView to capture container for dismissal inside onTap
            host.rootView = AnyView(
                PopSurface(palette: palette, onTap: { [weak container] in
                    onTap?()
                    guard let container else { return }
                    fadeOutAndRemove(container) { onFinish?() }
                }, content: content)
            )

            window.addSubview(container)
            activeView = container

            // Layout
            let frame = layoutFrame(for: container, in: window, placement: placement)
            container.frame = frame
            container.alpha = 0
            container.transform = CGAffineTransform(scaleX: popScale, y: popScale)

            // Haptic
            tactile?.pulse()

            // Animate in
            animateIn(container)

            // Auto-dismiss
            if duration > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    fadeOutAndRemove(container) { onFinish?() }
                }
            }

            // Keep strong ref to hosting controller
            objc_setAssociatedObject(container, &Associated.hostKey, host, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return true
    }

    // MARK: B) Convenience: Keep your old header/detail API (now built on top of A)

    @discardableResult
    public static func show(
        _ header: String?,
        detail: String? = nil,
        tactile: PopTactile? = nil,
        at placement: PopPlacement = .head,
        palette: PopPalette = .invert,
        visibleFor duration: TimeInterval = 3,
        onTap: (() -> Void)? = nil,
        onFinish: (() -> Void)? = nil
    ) -> Bool {
        show(
            tactile: tactile,
            at: placement,
            palette: palette,
            visibleFor: duration,
            onTap: onTap,
            onFinish: onFinish
        ) {
            PopDefaultContent(header: header, detail: detail, showsChevron: onTap != nil)
        }
    }

    // MARK: - Private helpers

    @MainActor
    private enum Associated {
        static var hostKey = "PopToast.host"
    }

    private static func keyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    // Type-erased host so we can host any content
    private static func buildHost(
        palette: PopPalette,
        onTap: (() -> Void)?,
        content: @escaping () -> AnyView
    ) -> (UIView, UIHostingController<AnyView>) {
        let wrapped = AnyView(PopSurface(palette: palette, onTap: onTap) {
            content()
        })
        let host = UIHostingController(rootView: wrapped)
        host.view.backgroundColor = .clear
        let container = host.view!
        return (container, host)
    }

    private static func layoutFrame(for view: UIView, in window: UIWindow, placement: PopPlacement) -> CGRect {
        let sidePadding: CGFloat = 16 // exact window margin
        let left: CGFloat = sidePadding
        let right: CGFloat = sidePadding
        let availableWidth = max(0, window.bounds.width - left - right)

        // height for that fixed width
        let target = CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height)
        let size = view.systemLayoutSizeFitting(
            target,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        var frame = CGRect(x: left, y: 0, width: availableWidth, height: size.height)

        switch placement {
        case .head:
            frame.origin.y = PopToast.edgeTopPadding // window.safeAreaInsets.top +
        case .mid:
            frame.origin.y = (window.bounds.height - size.height) / 2
        case .foot:
            frame.origin.y = window.bounds.height - window.safeAreaInsets.bottom - size.height - PopToast.edgeBottomPadding
        }

        return frame
    }

    private static func animateIn(_ view: UIView) {
        let animator = UIViewPropertyAnimator(duration: PopToast.appearDisappear, curve: .easeOut) {
            view.alpha = 1
            view.transform = .identity
        }
        animator.startAnimation()
    }

    private static func fadeOutAndRemove(_ view: UIView, completion: (() -> Void)? = nil) {
        let animator = UIViewPropertyAnimator(duration: PopToast.appearDisappear, curve: .easeIn) {
            view.alpha = 0
            view.transform = CGAffineTransform(scaleX: PopToast.popScale, y: PopToast.popScale)
        }
        animator.addCompletion { _ in
            view.removeFromSuperview()
            if PopToast.activeView === view {
                PopToast.activeView = nil
            }
            completion?()
        }
        animator.startAnimation()
    }

    private static func removeActiveIfNeeded() {
        guard let v = PopToast.activeView else { return }
        v.removeFromSuperview()
        PopToast.activeView = nil
    }
}
