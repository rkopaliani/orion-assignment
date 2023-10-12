//
//  Root+VM.swift
//  Frontend
//
//  Created by script on 09.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine

extension Root {

    struct ViewModel {

        class Interface: ObservableObject {

            @Published var windowVM: Window.ViewModel.Interface

            init(windowVM: Window.ViewModel.Interface) {
                self.windowVM = windowVM
            }

        } // Interface

    } // ViewModel

} // Root
