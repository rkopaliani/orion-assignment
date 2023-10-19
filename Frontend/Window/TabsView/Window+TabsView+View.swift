//
//  Window+TabsView+View.swift
//  Frontend
//
//  Created by Roman Kopaliani on 17.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import SwiftUI

extension Window.TabsView {

    struct View: SwiftUI.View {

        @ObservedObject var viewModel: ViewModel.Interface

        var body: some SwiftUI.View {

            HStack {

                ForEach(viewModel.tabVMs) {

                    Divider()
                        .padding(.init(top: 4, leading: 0, bottom: 4, trailing: 0))

                    Window.TabsView.Tab.View(viewModel: $0)
                }
            }

        } // body

    } // View

} // Window.TabsView

#if DEBUG

struct Window_TabsView_Preview_Provider: PreviewProvider {

    typealias TabViewModel = Window.TabsView.Tab.ViewModel

    static var previews: some SwiftUI.View {

        View(viewModel: staticContext.viewModel)
            .frame(height: 30)
    }

    private typealias View = Window.TabsView.View
    private typealias ViewModel = Window.TabsView.ViewModel

    private final class Context: ObservableObject {

        let viewModel: ViewModel.Interface

        init() {

            self.viewModel = ViewModel.Impl {

                $0.tabVMs = [

                    TabViewModel.Impl {

                        $0.icon = Image(systemName: "apple.logo")
                        $0.title = "Apple"
                    },
                    TabViewModel.Impl {

                        $0.icon = Image(systemName: "applepencil")
                        $0.title = "Pencil Apple"
                    },
                    TabViewModel.Impl {

                        $0.icon = nil
                        $0.title = "Football.ua"
                    },
                ]
            }
        }

    } // Context

    private static var staticContext: Context = {

        initializeLogging()

        return .init()
    }()

} // Controls_Alert_Preview_Provider

#endif
