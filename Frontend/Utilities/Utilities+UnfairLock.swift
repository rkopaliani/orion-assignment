//
//  Utilities+UnfairLock.swift
//  Frontend
//
//  Created by Roman Kopaliani on 08.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Darwin

extension Utilities {

    final class UnfairLock {

        init() {

            let lockPointer = UnsafeMutablePointer<os_unfair_lock_s>.allocate(capacity: 1)
            lockPointer.initialize(to: os_unfair_lock())

            self.lockPointer = lockPointer
        }

        func lock() {

            os_unfair_lock_lock(self.lockPointer)
        }

        func tryLock() -> Bool {

            os_unfair_lock_trylock(self.lockPointer)
        }

        func unlock() {

            os_unfair_lock_unlock(self.lockPointer)
        }

        deinit {

            lockPointer.deinitialize(count: 1)
            lockPointer.deallocate()
        }

        // MARK: - Privates

        private let lockPointer: UnsafeMutablePointer<os_unfair_lock_s>

    } // UnfairLock

} // Utilities
