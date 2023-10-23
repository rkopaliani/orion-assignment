//
//  Tab+Content+View.swift
//  Frontend
//
//  Created by script on 12.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import SwiftUI

import Swinject

extension Tab.Content {

    struct View: SwiftUI.View {

        @ObservedObject var viewModel: ViewModel.Interface

        var body: some SwiftUI.View {

            ZStack {

                Controls.WebView.View(viewModel: viewModel.webViewVM)

                if viewModel.webViewVM.url == nil {

                    LinearGradient(

                        colors: [Color(nsColor: .systemGray), Color(nsColor: .systemBlue)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Text("Empty Tab")

                        .font(.largeTitle)
                        .foregroundColor(Color(nsColor: .textColor))
                }
            }

        } // body

    } // View

} // Tab

#if DEBUG

struct Tab_Content_Preview_Provider: PreviewProvider {

    typealias Model = Tab.Content.Model

    static var previews: some SwiftUI.View {

        View(viewModel: staticContext.viewModel)
    }

    private typealias View = Tab.Content.View
    private typealias ViewModel = Tab.Content.ViewModel

    private final class Context: ObservableObject {

        let viewModel: ViewModel.Interface

        init(diPair: Container.SyncPair) {

            self.viewModel = diPair.container.resolve(ViewModel.Interface.self)!
        }

    } // Context

    private static var staticContext: Context = {

        initializeLogging()

        let diPair = Container.default
        let scheduler = DispatchQueue.main.asAnyScheduler()

        Model.Factory.register(with: diPair.container)
        ViewModel.Factory.register(
            with: diPair.container,
            scheduler: scheduler
        )

        return .init(diPair: diPair)
    }()

} // Tab_Preview_Provider

#endif
