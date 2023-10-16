//
//  Controls+SearchBar+View.swift
//  Frontend
//
//  Created by script on 13.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import SwiftUI

extension Controls.SearchBar {

    struct View: SwiftUI.View {

        @ObservedObject var viewModel: ViewModel.Interface

        var body: some SwiftUI.View {

            HStack {

                Controls.Button.View(

                    viewModel: viewModel.profilesButtonVM
                )

                Divider()
                TextField(

                    viewModel.title,
                    text: $viewModel.urlText,
                    prompt: Text(viewModel.prompt)
                )
                .textFieldStyle(.plain)
                .onSubmit {

                    viewModel.onCommitAction?()
                }
            }
            .padding(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
            .overlay {
                RoundedRectangle(

                    cornerRadius: 4
                )
                .strokeBorder(.separator)
            }

        } // body

    } // View

} // Controls.SearchBar

#if DEBUG

struct Controls_Search_Bar_Preview_Provider: PreviewProvider {

    static var previews: some SwiftUI.View {

        View(viewModel: staticContext.viewModel)

            .frame(height: 36)
    }

    private typealias View = Controls.SearchBar.View
    private typealias ViewModel = Controls.SearchBar.ViewModel

    private final class Context: ObservableObject {

        let viewModel: ViewModel.Interface

        init() {

            self.viewModel = ViewModel.Impl {

                $0.title = "Search or enter website name"
                $0.urlText = "https://www.apple.com"
            }
        }

    } // Context

    private static var staticContext: Context = {

        initializeLogging()

        return .init()
    }()

} // Controls_Alert_Preview_Provider

#endif
