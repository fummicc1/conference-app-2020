import ios_combined
import RealmSwift
import RxCocoa
import RxSwift

final class SessionViewModel {
    private let disposeBag = DisposeBag()

    // input
    private let toggleEmbeddedViewRelay = PublishRelay<Void>()
    private let sessionsFetchFromApiRelay: BehaviorRelay<[Session]>
    private let sessionsFetchFromLocalRelay: BehaviorRelay<[Session]>

    func toggleEmbeddedView() {
        toggleEmbeddedViewRelay.accept(())
    }

    // output
    let isFocusedOnEmbeddedView: Driver<Bool>
    let sessions: Driver<[Session]>

    // dependencies
    private let bookingSessionProvider: BookingSessionProvider

    init() {
        sessionsFetchFromApiRelay = .init(value: [])
        sessionsFetchFromLocalRelay = .init(value: [])
        bookingSessionProvider = .init()
        let isFocusedOnEmbeddedViewRelay = BehaviorRelay<Bool>(value: true)
        isFocusedOnEmbeddedView = isFocusedOnEmbeddedViewRelay.asDriver()

        sessions = Driver.combineLatest(
            sessionsFetchFromApiRelay.asDriver(),
            sessionsFetchFromLocalRelay.asDriver()
        ) { remote, local in
            let filteredSameSession = remote.filter { (session: Session) in
                !local.contains(where: { (localSession: Session) in session.id.id == localSession.id.id })
            }
            return (filteredSameSession + local).sorted { (pre: Session, next: Session) in
                return pre.startTime == next.startTime ? pre.room.name.en <= next.room.name.en : pre.startTime < next.startTime
            }
        }
        let dataProvider = SessionDataProvider()
        dataProvider
            .fetchSessions()
            .asObservable()
            .catchErrorJustReturn([])
            .bind(to: sessionsFetchFromApiRelay)
            .disposed(by: disposeBag)

        toggleEmbeddedViewRelay.asObservable()
            .withLatestFrom(isFocusedOnEmbeddedViewRelay)
            .map { !$0 }
            .bind(to: isFocusedOnEmbeddedViewRelay)
            .disposed(by: disposeBag)

        sessionsFetchFromApiRelay
            .asObservable()
            .map { $0.first?.startTime }
            .flatMap(bookingSessionProvider.fetchBookedSessions)
            .bind(to: sessionsFetchFromLocalRelay)
            .disposed(by: disposeBag)
    }

    func bookSession(_ session: Session) {
        bookingSessionProvider.bookSession(session)
    }

    func resignBookingSession(_ session: Session) {
        bookingSessionProvider.resignBookingSession(session.id.id)
    }
}
