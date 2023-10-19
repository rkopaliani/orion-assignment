//
//  Tab+Content+VM.swift
//  Frontend
//
//  Created by script on 12.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import Foundation

extension Tab.Content {

    struct ViewModel {

        class Interface: ObservableObject, Identifiable, Equatable, Hashable {

            let id = UUID()

            @Published var title: String?

            @Published var canGoBack = false
            @Published var canGoForward = false

            var onGoBack: (() -> Void) = {}
            var onGoForward: (() -> Void) = {}
            var onLoadUrl: ((URL) -> Void) = { _ in }

            let webViewVM: Controls.WebView.ViewModel.Interface

            init(webViewVM: Controls.WebView.ViewModel.Interface) {

                self.webViewVM = webViewVM
            }

            // MARK: Equatable

            static func == (lhs: Tab.Content.ViewModel.Interface, rhs: Tab.Content.ViewModel.Interface) -> Bool {

                lhs.id == rhs.id
            }

            // MARK: Hashable

            func hash(into hasher: inout Hasher) {

                hasher.combine(id)
            }

        } // Interface

    } // ViewModel

} // Tab
