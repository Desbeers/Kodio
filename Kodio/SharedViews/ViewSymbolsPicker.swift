//
//  ViewSymbolsPicker.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// A View to select an SF symbol
struct ViewSymbolsPicker: View {
    /// Show this View or not
    @Binding var isPresented: Bool
    /// The selected icon
    @Binding var icon: String
    /// The category of SF symbols to show
    let category: String
    /// The View
    var body: some View {
        if isPresented {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 20) {
                    ForEach(symbols[category]!, id: \.hash) { icon in
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
    /// All the SF symbols in use for Kodio
    let symbols: [String: [String]] = ["RadioStations":
                                        ["a.square.fill",
                                         "b.square.fill",
                                         "c.square.fill",
                                         "d.square.fill",
                                         "e.square.fill",
                                         "f.square.fill",
                                         "g.square.fill",
                                         "h.square.fill",
                                         "i.square.fill",
                                         "j.square.fill",
                                         "k.square.fill",
                                         "l.square.fill",
                                         "m.square.fill",
                                         "n.square.fill",
                                         "o.square.fill",
                                         "p.square.fill",
                                         "q.square.fill",
                                         "r.square.fill",
                                         "s.square.fill",
                                         "t.square.fill",
                                         "u.square.fill",
                                         "v.square.fill",
                                         "w.square.fill",
                                         "x.square.fill",
                                         "y.square.fill",
                                         "z.square.fill",
                                         "1.square.fill",
                                         "2.square.fill",
                                         "3.square.fill",
                                         "4.square.fill",
                                         "5.square.fill",
                                         "6.square.fill",
                                         "7.square.fill",
                                         "8.square.fill",
                                         "9.square.fill"
                                        ]
    ]
}
