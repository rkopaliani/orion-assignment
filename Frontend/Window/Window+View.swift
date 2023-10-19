//
//  Window+View.swift
//  Frontend
//
//  Created by script on 10.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import SwiftUI
import WebKit

import Swinject

extension Window {

    struct View: SwiftUI.View {

        @ObservedObject var viewModel: ViewModel.Interface

        var body: some SwiftUI.View {

            NavigationSplitView {

            } detail: {

                TabView(selection: $viewModel.selectedTabVM) {

                    Tab.View(viewModel: viewModel.selectedTabVM)
                }
                // Padding and clipping hide standard macOS SwiftUI tabview ugliness.
                // Better to replace it with custom tab view implementation.
                .padding(EdgeInsets(top: -30, leading: -2, bottom: -2, trailing: -2))
                .clipShape(Rectangle())
            }
            .navigationTitle("")
            .navigationSubtitle("")
            .toolbar {

                ToolbarView(viewModel: viewModel)
            }
        } // body

        struct ToolbarView: SwiftUI.ToolbarContent {

            @ObservedObject var viewModel: ViewModel.Interface

            var body: some SwiftUI.ToolbarContent {

                ToolbarItemGroup {

                    HStack(spacing: 16) {

                        Divider()

                        Text(

                            viewModel.tabsCountText
                        )
                        .font(.headline)

                        HStack(spacing: 0) {

                            Controls.Button.View(viewModel: viewModel.goBackButton)
                            Controls.Button.View(viewModel: viewModel.goForwardButton)
                        }
                    }

                    Spacer()

                    HStack(spacing: 4) {

                        Controls.Button.View(viewModel: viewModel.shieldButtonVM)
                        Controls.Button.View(viewModel: viewModel.preferencesButtonVM)
                    }

                    Controls.SearchBar.View(

                        viewModel: viewModel.searchBarVM
                    )
                    .cornerRadius(4)
                    .frame(minWidth: 300, idealWidth: 500)

                    Window.TabsView.View(viewModel: viewModel.tabsVM)

                    Spacer()

                    HStack(spacing: 4) {

                        Controls.Button.View(viewModel: viewModel.newPageButtonVM)
                        Controls.Button.View(viewModel: viewModel.overviewButtonVM)
                    }
                }

            } // ToolbarView
        }

    } // View

} // Window

#if DEBUG

struct Window_Preview_Provider: PreviewProvider {

    static var previews: some SwiftUI.View {

        View(viewModel: staticContext.viewModel)
    }

    private typealias View = Window.View
    private typealias Model = Window.Model
    private typealias ViewModel = Window.ViewModel

    private final class Context: ObservableObject {

        let viewModel: ViewModel.Interface

        init(diPair: Container.SyncPair) {

            self.viewModel = diPair.container.resolve(ViewModel.Interface.self)!
        }

    } // Context

    private static var staticContext: Context = {

        initializeLogging()

        let diPair = Container.default
        Model.Factory.register(with: diPair.container)

        let scheduler = DispatchQueue.main.asAnyScheduler()
        ViewModel.Factory.register(

            with: diPair.container,
            scheduler: scheduler
        )

        return .init(diPair: diPair)
    }()

} // Window_Preview_Provider

#endif
