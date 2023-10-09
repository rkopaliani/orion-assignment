//
//  Logger+Auxiliary.swift
//  Frontend
//
//  Created by Roman Kopaliani on 08.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import OSLog

extension Logger {

    init(category: String, subsystem: String = Bundle.main.bundleIdentifier!) {
        self.init(subsystem: subsystem, category: category)
    }
}
