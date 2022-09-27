//
//  PlayerView.swift
//  Kodio iPad
//
//  Created by Nick Berendsen on 15/08/2022.
//

import SwiftUI
import SwiftlyKodiAPI

struct PlayerView: View {
    @Environment(\.presentationMode) var presentationMode
    let video: any KodiItem
    var body: some View {
        KodiPlayerView(video: video)
            .overlay(alignment: .topLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                })
            }
            .edgesIgnoringSafeArea(.all)
    }
}
