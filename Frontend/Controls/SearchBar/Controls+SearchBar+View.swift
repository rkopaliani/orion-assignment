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

                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 8, height: 8)
                    .padding(.init(top: 10, leading: 8, bottom: 10, trailing: 0))

                Divider()
                    .padding(.init(top: 4, leading: 0, bottom: 4, trailing: 0))

                TextField(

                    viewModel.title,
                    text: $viewModel.urlText,
                    prompt: Text(viewModel.prompt)
                )
                .textFieldStyle(.plain)
                .font(.callout)
                .onSubmit {

                    viewModel.onCommitAction?()
                }
            }
            .overlay {
                RoundedRectangle(

                    cornerRadius: 6
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
