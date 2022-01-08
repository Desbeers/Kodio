//
//  ViewSymbolsPicker.swift
//  Kodio
//
//  Created by Nick Berendsen on 08/01/2022.
//

import SwiftUI

/// A View to select an SF symbol
struct ViewSymbolsPicker: View {
    /// Show this View or not
    @Binding var isPresented: Bool
    /// The selected icon
    @Binding var icon: String
    /// The category of SF symbols to show
    let category: SymbolsCategory
    /// The View
    var body: some View {
        if isPresented {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 20) {
                    ForEach(symbols[category.rawValue]!, id: \.hash) { icon in
                        Image(systemName: icon)
                            .font(.system(size: 25))
                            .foregroundColor(self.icon == icon ? Color.accentColor : Color.primary)
                            .onTapGesture {
                                withAnimation {
                                    self.icon = icon
                                    isPresented = false
                                }
                            }
                    }
                    .padding(.top, 5)
                }
            }
            /// Show two rown of SF icons
            .frame(height: 100)
        }
    }
}
