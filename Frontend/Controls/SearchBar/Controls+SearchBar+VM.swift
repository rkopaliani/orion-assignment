//
//  Controls+SearchBar+VM.swift
//  Frontend
//
//  Created by script on 13.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import SwiftUI

extension Controls.SearchBar {

    struct ViewModel {

        class Interface: ObservableObject {

            @Published var title: String = ""
            @Published var prompt: String = ""
            @Published var urlText: String = ""

            var onCommitAction: (() -> Void)?
        }

        // MARK: -

        final class Impl: Interface {

            init(configure: (Interface) -> Void = { _ in }) {

                super.init()

                configure(self)
            }

        } // Impl

    } // ViewModel

} // Controls.SearchBar
