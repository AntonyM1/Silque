//
//  PlaceholderExtension.swift
//  Silque
//
//  Created by Antony Marcelino on 26/05/2025.
//

import SwiftUI

extension View {
    @ViewBuilder
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow { placeholder().allowsHitTesting(false) }
            self
        }
    }
}
