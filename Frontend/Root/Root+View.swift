//
//  Root+View.swift
//  Frontend
//
//  Created by script on 09.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import SwiftUI

extension Root {

    struct View: Scene {

        @ObservedObject var viewModel: ViewModel.Interface

        var body: some Scene {

            WindowGroup {
                Window.View(viewModel: viewModel.windowVM)
            }
            .windowStyle(.hiddenTitleBar)

        } // body

    } // View

} // Root
