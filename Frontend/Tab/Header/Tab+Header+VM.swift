//
//  Tab+Header+VM.swift
//  Frontend
//
//  Created by Roman Kopaliani on 17.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine

extension Tab.Header {

    struct ViewModel {

        class Interface: ObservableObject {

            @Published var tabVMs: [Tab.Header.Item.ViewModel.Interface] = []

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

} // Tab.Header
