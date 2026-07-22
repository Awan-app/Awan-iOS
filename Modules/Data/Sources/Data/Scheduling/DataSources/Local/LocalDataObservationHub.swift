import Combine

final class LocalDataObservationHub: @unchecked Sendable {
    private let subject = PassthroughSubject<Void, Never>()

    func publisher() -> AnyPublisher<Void, Never> {
        subject.eraseToAnyPublisher()
    }

    func send() {
        subject.send(())
    }
}
