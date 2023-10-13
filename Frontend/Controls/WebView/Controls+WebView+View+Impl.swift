//
//  Controls+WebView+View+Impl.swift
//  Frontend
//
//  Created by Roman Kopaliani on 12.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import SwiftUI
import WebKit

extension Controls.WebView.View {

    typealias ViewModel = Controls.WebView.ViewModel

    struct Impl: NSViewRepresentable {

        @ObservedObject var viewModel: ViewModel.Interface

        init(viewModel: ViewModel.Interface) {

            self.viewModel = viewModel
        }

        // MARK: NSViewRepresentable

        func makeCoordinator() -> Coordinator {

            .init(viewModel: viewModel)
        }

        func makeNSView(context: Context) -> some NSView {

            context.coordinator.webView
        }

        func updateNSView(_ nsView: NSViewType, context: Context) {
        }

    } // Impl

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {

        let webView = WKWebView()
        let viewModel: ViewModel.Interface

        init(viewModel: ViewModel.Interface) {
            self.viewModel = viewModel

            webView.publisher(for: \.estimatedProgress)

                .receive(on: scheduler)
                .weakAssign(to: \.estimatedProgress, on: viewModel)
                .store(in: &cancellables)

            webView.publisher(for: \.url)

                .receive(on: scheduler)
                .weakAssign(to: \.url, on: viewModel)
                .store(in: &cancellables)

            webView.load(.init(url: .init(string: "https://apple.com")!))
        }

        // MARK: - Private

        private let scheduler = DispatchQueue.main.asAnyScheduler()
        private var cancellables = Set<AnyCancellable>()
    }
}
