//
//  Controls+Button+View.swift
//  Frontend
//
//  Created by script on 10.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import SwiftUI

extension Controls.Button {

    struct View: SwiftUI.View {

        @ObservedObject var viewModel: ViewModel.Interface

        @Environment(\.colorScheme)
        var colorScheme

        private var content: (() -> AnyView)?

        init(

            viewModel: ViewModel.Interface,
            content: (() -> AnyView)? = nil

        ) {

            self.viewModel = viewModel
            self.content = content
        }

        var body: some SwiftUI.View {

            switch viewModel.kind {
            case .plain:

                Button(

                    action: { viewModel.action?() },
                    label: { Text(viewModel.label) }
                )
                .disabled(viewModel.isDisabled)

            case .systemIcon:

                Button(

                    action: { viewModel.action?() },
                    label: { Image(systemName: viewModel.icon) }
                )
                .buttonStyle(.borderless)
                .disabled(viewModel.isDisabled)
            }

        } // body

    } // View

} // Controls.Button

#if DEBUG

struct Controls_Button_Preview_Provider: PreviewProvider {

    static var previews: some SwiftUI.View {

        VStack {

            View(viewModel: staticContext.plainVM)

                .padding()

            View(viewModel: staticContext.systemIconVM)

                .padding()
        }
    }

    private typealias View = Controls.Button.View
    private typealias ViewModel = Controls.Button.ViewModel
    private typealias AssetsColors = Controls.Button.Assets.Color

    private final class Context: ObservableObject {

        let plainVM: ViewModel.Interface
        let systemIconVM: ViewModel.Interface

        init() {

            self.systemIconVM = ViewModel.Impl {

                $0.kind = .systemIcon
                $0.icon = "gobackward.15"
            }
            self.plainVM = ViewModel.Impl {

                $0.kind = .plain
                $0.label = "Plain button"
            }
        }

    } // Context

    private static var staticContext: Context = {

        initializeLogging()

        return .init()
    }()

} // Controls_Button_Preview_Provider

#endif
