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

        init(viewModel: ViewModel.Interface) {

            webView.publisher(for: \.estimatedProgress)

                .receive(on: scheduler)
                .weakAssign(to: \.estimatedProgress, on: viewModel)
                .store(in: &cancellables)

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

            super.init()

            viewModel.onGoBackAction = { [weak self] in

                self?.webView.goBack()
            }
            viewModel.onGoForwardAction = { [weak self] in

                self?.webView.goForward()
            }
            viewModel.onLoadURL = { [weak self] url in

                self?.webView.load(.init(url: url))
            }
        }

        // MARK: - Private

        private let scheduler = DispatchQueue.main.asAnyScheduler()
        private var cancellables = Set<AnyCancellable>()
    }
}