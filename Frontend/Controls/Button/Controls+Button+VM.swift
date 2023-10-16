//
//  Controls+Button+VM.swift
//  Frontend
//
//  Created by script on 10.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import SwiftUI

extension Controls.Button {

    struct ViewModel {

        class Interface: ObservableObject {

            /// The action to perform when the user triggers the button.
            ///
            var action: (() -> Void)?

            /// Optional button tag.
            ///
            var tag: Int?

            /// Optional accessibility identifier of the button.
            ///
            var accessibilityId: String?

            /// Kind of the button.
            ///
            var kind: Kind = .plain

            /// Holds label of a button.
            ///
            @Published var label = ""

            /// Holds button's icon name.
            ///
            @Published var icon = ""

            /// Allows to disable this button.
            ///
            @Published var isDisabled = false

            /// Indicates selection state of the button.
            ///
            @Published var isSelected = false

            init() {
            }

        } // Interface

        // MARK: -

        final class Impl: Interface {

            init(configure: (Interface) -> Void = { _ in }) {

                super.init()

                configure(self)
            }

        } // Impl

    } // ViewModel

} // Controls.Button
