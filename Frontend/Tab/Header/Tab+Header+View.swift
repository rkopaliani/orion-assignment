//
//  Tab+Header+View.swift
//  Frontend
//
//  Created by Roman Kopaliani on 17.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import SwiftUI

extension Tab.Header {

    struct View: SwiftUI.View {

        @ObservedObject var viewModel: ViewModel.Interface

        var body: some SwiftUI.View {

            HStack {

                ForEach(viewModel.tabVMs) {

                    Divider()
                        .padding(.init(top: 4, leading: 0, bottom: 4, trailing: 0))

                    Tab.Header.Item.View(viewModel: $0)
                        .frame(maxWidth: 200)
                }
            }

        } // body

    } // View

} // Tab.Header

#if DEBUG

struct Tab_Header_Preview_Provider: PreviewProvider {

    static var previews: some SwiftUI.View {

        View(viewModel: staticContext.viewModel)
            .frame(height: 30)
    }

    private typealias View = Tab.Header.View
    private typealias ViewModel = Tab.Header.ViewModel
    private typealias Item = Tab.Header.Item.ViewModel

    private final class Context: ObservableObject {

        let viewModel: ViewModel.Interface

        init() {

            self.viewModel = ViewModel.Impl {

                $0.tabVMs = [

                    Item.Impl {

                        $0.icon = Image(systemName: "apple.logo")
                        $0.title = "Apple"
                    },
                    Item.Impl {

                        $0.icon = Image(systemName: "applepencil")
                        $0.title = "Pencil Apple"
                    },
                    Item.Impl {

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

} // Tab_Header_Preview_Provider

#endif
