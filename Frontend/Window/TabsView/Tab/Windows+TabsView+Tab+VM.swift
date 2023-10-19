//
//  Windows+TabsView+Tab+VM.swift
//  Frontend
//
//  Created by Roman Kopaliani on 18.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import SwiftUI

extension Window.TabsView.Tab {

    struct ViewModel {

        class Interface: ObservableObject, Identifiable {

            let id = UUID()

            @Published var icon: Image?

            @Published var title: String = ""

            var onCloseAction: (() -> Void)?

            init() {}

        } // Interface

        // MARK: -

        final class Impl: Interface {

            init(configure: (Interface) -> Void = { _ in }) {

                super.init()

                configure(self)
            }

        } // Impl

    } // ViewModel

} // Window.TabsView.Tab
