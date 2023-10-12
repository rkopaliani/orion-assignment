//
//  Tab+View.swift
//  Frontend
//
//  Created by script on 12.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import SwiftUI

import Swinject

extension Tab {

    struct View: SwiftUI.View {

        @ObservedObject var viewModel: ViewModel.Interface

        var body: some SwiftUI.View {

            VStack {

            } // VStack

        } // body

    } // View

} // Tab

#if DEBUG

struct Tab_Preview_Provider: PreviewProvider {

    static var previews: some SwiftUI.View {

        View(viewModel: staticContext.viewModel)
    }

    private typealias View = Tab.View
    private typealias ViewModel = Tab.ViewModel

    private final class Context: ObservableObject {

        let viewModel: ViewModel.Interface

        init(diPair: Container.SyncPair) {

            self.viewModel = diPair.container.resolve(ViewModel.Interface.self)!
        }

    } // Context

    private static var staticContext: Context = {

        initializeLogging()

        let diPair = Container.default

        ViewModel.Factory.register(

            with: diPair.container,
            scheduler: DispatchQueue.main.asAnyScheduler()
        )

        return .init(diPair: diPair)
    }()

} // Tab_Preview_Provider

#endif
