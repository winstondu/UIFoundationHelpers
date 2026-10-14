import SwiftUI

@available(iOS 18, *)
private struct SwipeRightActionModifier<Label: View>: ViewModifier {
    let onReply: () -> Void
    @ViewBuilder let label: Label

    @State var enabled: Bool
    @State private var offset: CGFloat = 0
    @State private var hasTriggered = false

    private let threshold: CGFloat = 50

    func body(content: Content) -> some View {
        if enabled {
            content
                .offset(x: offset)
                .background(alignment: .leading) {
                    label
                        .scaleEffect(min(offset / threshold, 1.0))
                        .opacity(offset > 10 ? 1 : 0)
                        .frame(width: 30)
                        .offset(x: max(offset - 40, -10))
                }
                .gesture(
                    SwipeGesture(
                        onChanged: { recognizer in
                            let h = recognizer.translation(in: recognizer.view).x
                            guard h > 0 else {
                                offset = 0
                                return
                            }

                            if h > threshold {
                                offset = threshold + (h - threshold) * 0.3
                            } else {
                                offset = h
                            }

                            if offset >= threshold, !hasTriggered {
                                hasTriggered = true
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            }
                        },
                        onEnded: { recognizer in
                            let xTranslation = recognizer.translation(in: recognizer.view).x
                            if xTranslation >= threshold {
                                onReply()
                            }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                offset = 0
                            }
                            hasTriggered = false
                        }
                    )
                )
        } else {
            content
        }

    }
}

@available(iOS 18, *)
private struct SwipeGesture: UIGestureRecognizerRepresentable {
    let onChanged: (UIPanGestureRecognizer) -> Void
    let onEnded: (UIPanGestureRecognizer) -> Void

    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let recognizer = UIPanGestureRecognizer()
        recognizer.delegate = context.coordinator
        return recognizer
    }

    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        switch recognizer.state {
        case .began, .changed:
            onChanged(recognizer)
        case .ended, .cancelled:
            onEnded(recognizer)
        default:
            break
        }
    }

    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {}

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            other.view is UIScrollView
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return false }
            let velocity = pan.velocity(in: pan.view)
            return velocity.x > 0 && abs(velocity.x) > abs(velocity.y)
        }
    }
}

extension View {
    @available(iOS 18, *)
    public func swipeRightAction(
        enabled: Bool = true,
        @ViewBuilder label: @escaping () -> some View = {
            EmptyView()
        },
        action: @escaping () -> Void
    ) -> some View {
        modifier(SwipeRightActionModifier(onReply: action, label: label, enabled: enabled))
    }
}
