//
//  Tab+VM.swift
//  Frontend
//
//  Created by script on 12.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import Foundation

extension Tab {

    struct ViewModel {

        class Interface: ObservableObject, Identifiable, Equatable, Hashable {

            let id = UUID()

            @Published var url: URL?
            @Published var canGoBack = false
            @Published var canGoForward = false

            let webViewVM: Controls.WebView.ViewModel.Interface

            init(webViewVM: Controls.WebView.ViewModel.Interface) {

                self.webViewVM = webViewVM
            }

            func loadUrl(_ url: URL) {

                webViewVM.onLoadURL?(url)
            }

            func goBack() {

                webViewVM.onGoBackAction?()
            }

            func goForward() {

                webViewVM.onGoForwardAction?()
            }

            // MARK: Equatable

            static func == (lhs: Tab.ViewModel.Interface, rhs: Tab.ViewModel.Interface) -> Bool {

                lhs.id == rhs.id
            }

            // MARK: Hashable

            func hash(into hasher: inout Hasher) {

                hasher.combine(id)
            }

        } // Interface

    } // ViewModel

} // Tab
