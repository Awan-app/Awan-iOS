@preconcurrency import Combine

public enum AsyncValuePublisher {
    public static func make<Output: Sendable>(
        _ operation: @escaping @Sendable () async throws -> Output
    ) -> AnyPublisher<Output, Error> {
        Deferred {
            Future { promise in
                let promise = PromiseBox(promise)
                Task {
                    do {
                        promise.resolve(.success(try await operation()))
                    } catch {
                        promise.resolve(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

private final class PromiseBox<Output>: @unchecked Sendable {
    private let promise: Future<Output, Error>.Promise

    init(_ promise: @escaping Future<Output, Error>.Promise) {
        self.promise = promise
    }

    func resolve(_ result: Result<Output, Error>) {
        promise(result)
    }
}
