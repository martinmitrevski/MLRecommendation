//
//  Modifiers.swift
//  MLRecommendation
//
//  Created by Martin Mitrevski on 10.7.21.
//

import SwiftUI

struct DefaultPadding: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
    }
    
}
