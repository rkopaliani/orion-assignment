//
//  Windows+TabsView+Tab+View.swift
//  Frontend
//
//  Created by Roman Kopaliani on 18.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import SwiftUI

extension Window.TabsView.Tab {

    struct View: SwiftUI.View {

        @ObservedObject var viewModel: ViewModel.Interface

        @State private var isHovered = false
        @State private var isHoveredOverIcon = false

        var body: some SwiftUI.View {

            HStack {

                ZStack {

                    if viewModel.icon != nil && !isHoveredOverIcon {

                        viewModel.icon!
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                            .transition(.opacity)

                    } else {

                        Button { viewModel.onCloseAction?() } label: {

                            Image(systemName: "xmark.square.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 12, height: 12)
                                .transition(.opacity)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onHover { isHoveredOverIcon = $0 }

                Text(viewModel.title)
                    .font(.caption2)
                    .fontWeight(.light)
            }
            .padding(.init(top: 8, leading: 8, bottom: 8, trailing: 8))
            .background(content: {

                if isHovered {

                    AnyView(
                        RoundedRectangle(
                            cornerRadius: 6,
                            style: .continuous
                        )
                        .fill(.selection)
                    )

                } else {

                    AnyView(EmptyView())
                }
            })
            .onHover { isHovered = $0 }

        } // body

    } // View

} // Window.TabsView.Tab

#if DEBUG

struct Window_TabsView_Tab_Preview_Provider: PreviewProvider {

    static var previews: some SwiftUI.View {

        View(viewModel: staticContext.viewModel)
    }

    private typealias View = Window.TabsView.Tab.View
    private typealias ViewModel = Window.TabsView.Tab.ViewModel

    private final class Context: ObservableObject {

        let viewModel: ViewModel.Interface

        init() {

            self.viewModel = ViewModel.Impl {

                $0.title = "Facebook"
                $0.icon = Image(systemName: "apple.logo")
            }
        }

    } // Context

    private static var staticContext: Context = {

        initializeLogging()

        return .init()
    }()

} // Controls_Alert_Preview_Provider

#endif
