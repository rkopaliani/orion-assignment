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

            if let coordinator = viewModel.coordinator {

                return coordinator
            }

            let coordinator = Coordinator(viewModel: viewModel)
            viewModel.coordinator = coordinator
            return coordinator
        }

        func makeNSView(context: Context) -> some NSView {

            context.coordinator.webView
        }

        func updateNSView(_ nsView: NSViewType, context: Context) {
        }

    } // Impl

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {

        let webView = WKWebView()

        init(viewModel: ViewModel.Interface) {

            webView.publisher(for: \.url)

                .receive(on: scheduler)
                .weakAssign(to: \.url, on: viewModel)
                .store(in: &cancellables)

            webView.publisher(for: \.canGoBack)

                .receive(on: scheduler)
                .weakAssign(to: \.canGoBack, on: viewModel)
                .store(in: &cancellables)

            webView.publisher(for: \.canGoForward)

                .receive(on: scheduler)
                .weakAssign(to: \.canGoForward, on: viewModel)
                .store(in: &cancellables)

            webView.publisher(for: \.title)

                .receive(on: scheduler)
                .weakAssign(to: \.title, on: viewModel)
                .store(in: &cancellables)

            super.init()

            viewModel.onGoBackAction = { [webView] in

                webView.goBack()
            }
            viewModel.onGoForwardAction = { [webView] in

                webView.goForward()
            }
            viewModel.onLoadURL = { [webView] url in

                webView.load(.init(url: url))
            }
        }

        // MARK: - Private

        private let scheduler = DispatchQueue.main.asAnyScheduler()
        private var cancellables = Set<AnyCancellable>()
    }

} // Controls.WebView.View
