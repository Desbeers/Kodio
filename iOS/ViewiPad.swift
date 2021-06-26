//
//  ViewiPad.swift
//  Kodio (iOS)
//
//  Created by Nick Berendsen on 04/06/2021.
//

import SwiftUI

struct ViewiPad: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// Show or hide log
    @AppStorage("ShowLog") var showLog: Bool = false
    var body: some View {
        NavigationView {
            ViewSidebar()
                //.navigationTitle("Kodio")
                .navigationTitle(kodi.player.navigationTitle + " | " + kodi.player.navigationSubtitle)
                .navigationBarTitleDisplayMode(.inline)
            ViewAlbums()
            ViewDetails()
        }
        //        GeometryReader { geometry in
        //            ZStack {
        //                VStack(spacing: 0) {
        //                    HStack(spacing: 0) {
        //
        //                        ViewSidebar()
        //                            .padding(.top)
        //                            .background(Color("iOSsidebarBackground"))
        //                            .frame(width: geometry.size.width * 0.25)
        //                        VStack(spacing: 0) {
        //                            HeaderView()
        //                            HStack(spacing: 0) {
        //                                ViewAlbums()
        //                                    .frame(width: geometry.size.width * 0.35)
        //                                VStack(spacing: 0) {
        //                                    ViewKodiStatus()
        //                                    ViewDetails()
        //                                }
        //                            }
        //                            if showLog {
        //                                ViewLog()
        //                            }
        //                        }
        //
        //                    }
        //                }
        //                VStack {
        //                    Spacer()
        //                    FooterView()
        //                }
        //            }
        //
        //        }
    }
}
