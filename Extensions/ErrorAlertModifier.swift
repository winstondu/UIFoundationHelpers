//
//  ErrorAlertModifier.swift
//  Winston
//
//

import SwiftUI

public extension View {

    func errorAlert(
        errorMessage: Binding<String?>,
        title: String = "Error",
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(ErrorAlertModifier(
            errorMessage: errorMessage,
            title: title,
            onDismiss: onDismiss
        ))
    }
}

private struct ErrorAlertModifier: ViewModifier {
    @Binding var errorMessage: String?
    let title: String
    let onDismiss: (() -> Void)?
    @State private var showingAlert = false

    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $showingAlert, actions: {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                    onDismiss?()
                }
            }, message: {
                if let message = errorMessage {
                    Text(message)
                }
            })
            .onChange(of: errorMessage) {
                if errorMessage != nil {
                    showingAlert = true
                }
            }
    }
}
