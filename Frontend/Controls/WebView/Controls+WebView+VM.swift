//
//  Controls+WebView+VM.swift
//  Frontend
//
//  Created by script on 12.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import SwiftUI

extension Controls.WebView {

    struct ViewModel {

        class Interface: ObservableObject, Identifiable {

            let id = UUID()

            @Published var url: URL?
            @Published var estimatedProgress: Double = 0

            @Published var canGoBack = false
            @Published var canGoForward = false

            var onLoadURL: ((URL) -> Void)?
            var onGoBackAction: (() -> Void)?
            var onGoForwardAction: (() -> Void)?

            init() {
            }
        }

        // MARK: -

        final class Impl: Interface {

            init(configure: (Interface) -> Void = { _ in }) {

                super.init()

                configure(self)
            }

        } // Impl

    } // ViewModel
}
