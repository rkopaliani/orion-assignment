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

    public struct ViewModel {

        public class Interface: ObservableObject {

            /// The action to perform when the user triggers the button.
            ///
            public var action: (() -> Void)?

            /// Optional button tag.
            ///
            public var tag: Int?

            /// Optional accessibility identifier of the button.
            ///
            public var accessibilityId: String?

            /// Kind of the button.
            ///
            public var kind: Kind = .plain

            /// Holds label of a button.
            ///
            @Published public var label = ""

            /// Holds button's icon name.
            ///
            @Published public var icon = ""

            /// Allows to disable this button.
            ///
            @Published public var isDisabled = false

            /// Indicates selection state of the button.
            ///
            @Published public var isSelected = false

            init() {
            }

        } // Interface

        // MARK: -

        public final class Impl: Interface {

            public init(configure: (Interface) -> Void = { _ in }) {

                super.init()

                configure(self)
            }

        } // Impl

    } // ViewModel

} // Controls.Button
