//
//  Combine+Publisher+Auxiliary.swift
//  Frontend
//
//  Created by Roman Kopaliani on 08.10.2023.
//  Copyright © 2023 orion-assigment. All rights reserved.
//

import Combine
import OSLog

extension Publisher where Failure: Error {

    /// Maps error to a specific error type and logs mapping info.
    ///
    func mapUnexpectedError<T: Error>(_ failure: T, logger: Logger) -> AnyPublisher<Output, T> {

        mapError { error in

            guard let error = error as? T else {

                logger.debug("'error'=\(error) is mapped to 'error'=\(failure).")

                return failure
            }

            return error
        }

        .eraseToAnyPublisher()
    }

} // Publisher

extension Publisher where Failure == Never {

    ///  Use this instead of `assign(to:on:)` to prevent `[weak self]` dance.
    ///
    func weakAssign<T: AnyObject>(

        to keyPath: WritableKeyPath<T, Output>,
        on object: T

    ) -> AnyCancellable {

        sink { [weak object] value in

            object?[keyPath: keyPath] = value
        }
    }

} // Publisher

extension Publisher {

    /// `retry` operation with built-in `delay`.
    ///
    /// Allows user to specify `delay` interval for the `retry`.
    ///
    func retry<T: Scheduler>(

        _ retries: Int,
        delay: T.SchedulerTimeType.Stride,
        scheduler: T

    ) -> AnyPublisher<Output, Failure> {

        self.catch { _ in

            Just(())
                .delay(for: delay, scheduler: scheduler)
                .flatMap { _ in self }
                .retry(retries > 0 ? retries - 1 : 0)
        }
        .eraseToAnyPublisher()
    }

    func unwrap<T>() -> AnyPublisher<T, Failure> where Output == T? {

        compactMap { $0 }.eraseToAnyPublisher()
    }

    public func ignoreValueSink(

        receiveCompletion: @escaping ((Subscribers.Completion<Self.Failure>) -> Void)

    ) -> AnyCancellable {

        self.sink(receiveCompletion: receiveCompletion, receiveValue: { _ in })
    }

    public func ignoreCompletionSink(

        logger: Logger,
        receiveValue: @escaping ((Self.Output) -> Void)

    ) -> AnyCancellable {

        sink(receiveCompletion: { completion in

            switch completion {

            case .finished:

                logger.debug("Publisher finished successfully.")

            case .failure(let error):

                logger.error("Publisher finished with an error. Error=\(error.localizedDescription)")
            }

        }, receiveValue: receiveValue)
    }

    public func flattenMap<T>(

        transform: @escaping (Output.Element) -> T

    ) -> AnyPublisher<[T], Self.Failure> where Output: Sequence {

        map { elements in

            elements.map { transform($0) }
        }
        .eraseToAnyPublisher()
    }

    public func flattenCompactMap<T>(

        transform: @escaping (Output.Element) -> T?

    ) -> AnyPublisher<[T], Self.Failure> where Output: Sequence {

        map { elements in

            elements.compactMap { transform($0) }
        }
        .eraseToAnyPublisher()
    }

    public func validate(_ predicate: NSPredicate) -> AnyPublisher<Bool, Self.Failure> where Output == String {

        map {

            !$0.isEmpty && predicate.evaluate(with: $0)
        }
        .eraseToAnyPublisher()
    }

} // Publisher
