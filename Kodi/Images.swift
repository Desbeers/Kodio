///
/// Images.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct RemoteKodiImage: View {
    private enum LoadState {
        case loading, success, failure
    }

    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading

        init(url: String) {
            guard let parsedURL = URL(string: url.kodiImageUrl()) else {
                fatalError("Invalid URL: \(url)")
            }
            /// Create a md5 path to the URL in the cache
            let fileCachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                .appendingPathComponent(url.md5(), isDirectory: false)
            /// Try to get it from cache
            do {
                let data = try Data(contentsOf: fileCachePath)
                self.data = data
                self.state = .success
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
                return
            } catch {
                /// Image not in the cache
                URLSession.shared.downloadTask(with: parsedURL) { data, _, _ in
                    if let data = data {
                        do {
                            /// Remove any existing document at file
                            if FileManager.default.fileExists(atPath: fileCachePath.path) {
                                try FileManager.default.removeItem(at: fileCachePath)
                            }
                            /// Copy the tempURL to file
                            try FileManager.default.copyItem(at: data, to: fileCachePath)
                            /// It should be in the cache now
                            let newData = try Data(contentsOf: data)
                            self.data = newData
                            self.state = .success
                            DispatchQueue.main.async {
                                self.objectWillChange.send()
                            }
                            return
                        } catch {
                            self.state = .failure
                            return
                        }
                    }
                }.resume()
            }
        }
    }

    @ObservedObject private var loader: Loader
    var loading: Image
    var failure: Image

    var body: some View {
        selectImage()
            .resizable()
            .if(loader.state == .loading) { $0.frame(width: 20, height: 20) }
    }

    init(url: String, loading: Image = Image(systemName: "sun.max"), failure: Image = Image("DefaultCoverArt")) {
        _loader = ObservedObject(wrappedValue: Loader(url: url))
        self.loading = loading
        self.failure = failure
    }

    private func selectImage() -> Image {
        switch loader.state {
        case .loading:
            return loading
        case .failure:
            return failure
        default:
            if let image = SWIFTImage(data: loader.data) {
                #if os(macOS)
                return Image(nsImage: image)
                #endif
                #if os(iOS)
                return Image(uiImage: image)
                #endif
            } else {
                return failure
            }
        }
    }
}
