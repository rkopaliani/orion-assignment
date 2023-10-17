//
//  Controls+WebView+View.swift
//  Frontend
//
//  Created by script on 12.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import SwiftUI

extension Controls.WebView {

    struct View: SwiftUI.View {

        let viewModel: ViewModel.Interface

        init(viewModel: ViewModel.Interface) {

            self.viewModel = viewModel
        }

        var body: some SwiftUI.View {

            Impl(viewModel: viewModel)
            // we have to `id` `Impl` to recreate it proper
                .id(viewModel.id)
        }
    }
}
