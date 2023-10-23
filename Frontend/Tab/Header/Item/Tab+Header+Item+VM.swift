//
//  Tab+Header+Item+VM.swift
//  Frontend
//
//  Created by Roman Kopaliani on 18.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import SwiftUI

extension Tab.Header.Item {

    struct ViewModel {

        class Interface: ObservableObject, Identifiable, Hashable, Equatable {

            let id = UUID()

            @Published var icon: Image?
            @Published var title = ""
            @Published var selected = false

            var onAction: (() -> Void) = {}
            var onCloseAction: (() -> Void) = {}

            init() {}

            // MARK: Equatable

            static func == (

                lhs: Tab.Header.Item.ViewModel.Interface,
                rhs: Tab.Header.Item.ViewModel.Interface

            ) -> Bool {

                lhs.id == rhs.id
            }

            // MARK: Hashbale

            func hash(into hasher: inout Hasher) {

                hasher.combine(id)
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

} // Tab.Header.Item
