//
//  FrontendApp.swift
//  Frontend
//
//  Created by Roman Kopaliani on 08.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import SwiftUI
import Swinject

@main
struct FrontendApp: App {

    init() {
        registerDependencies()
    }

    var body: some Scene {
        let viewModel = Container.default.resolver.resolve(Root.ViewModel.Interface.self)!
        Root.View(viewModel: viewModel)
    }
}

func registerDependencies() {
    let defaultSyncPair = Container.default
    let mainScheduler = DispatchQueue.main.asAnyScheduler()
    Root.Model.Factory.register(with: defaultSyncPair.container)
    Root.ViewModel.Factory.register(with: defaultSyncPair.container, scheduler: mainScheduler)
}
