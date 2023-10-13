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

                Text("Sidebar")

            } detail: {

                TabView(selection: $viewModel.selectedIdx) {

                    ForEach(viewModel.tabVMs) { tabViewModel in
                        Tab.View(viewModel: tabViewModel)
                    }
                }
                // Padding and clipping hide standard macOS SwiftUI tabview ugliness.
                // Better to replace it with custom tab view implementation.
                .padding(EdgeInsets(top: -30, leading: -2, bottom: -2, trailing: -2))
                .clipShape(Rectangle())
            }
            .toolbar {

                ToolbarView(viewModel: viewModel)
            }

        } // body

        private struct ToolbarView: SwiftUI.ToolbarContent {

            @ObservedObject var viewModel: ViewModel.Interface

            var body: some SwiftUI.ToolbarContent {

                ToolbarItemGroup {

                    HStack(spacing: 16) {
                        Divider()
                        Text(viewModel.tabsCountText)
                    }

                    Spacer()

                    HStack(spacing: 0) {
                        Controls.Button.View(viewModel: viewModel.goBackButton)
                        Controls.Button.View(viewModel: viewModel.goForwardButton)
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        Controls.Button.View(viewModel: viewModel.shieldButtonVM)
                        Controls.Button.View(viewModel: viewModel.preferencesButtonVM)
                    }

                    HStack(spacing: 20) {
                        /// search view

                        Spacer()
                    }
                    .background(.gray)

                    HStack(spacing: 20) {
                        /// tab view
                        Spacer()
                    }
                    .background(.blue)

                    Spacer()

                    HStack {
                        Controls.Button.View(viewModel: viewModel.newPageButtonVM)
                        Controls.Button.View(viewModel: viewModel.overviewButtonVM)
                    }

                } // body

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
