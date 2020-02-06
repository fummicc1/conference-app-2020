import ios_combined
import RealmSwift
import RxRealm
import RxSwift

final class BookingSessionProvider {
    func bookSession(_ session: Session) {
        do {
            let realm = try Realm()
            let session = SessionEntity(session: session)
            session.isFavorited = true
            try realm.write {
                realm.add(session)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchBookedSessions(firstSessionStartTime: TimeInterval?) -> Observable<[Session]> {
        // 1582160400000ms is 2/20 10:00 UTC+9
        let firstSessionDefaultStartTime: TimeInterval = 1582160400000
        do {
            let realm = try Realm()
            let result = realm.objects(SessionEntity.self)

            return Observable.collection(from: result).map { (results) -> [Session] in
                results.compactMap { (sessionEntity) -> Session? in
                    return RealmToModelMapper.toModel(sessionEntity: sessionEntity, firstSessionSTime: firstSessionStartTime ?? firstSessionDefaultStartTime)
                }
            }
        } catch {
            return .error(error)
        }
    }

    func resignBookingSession(_ sessionId: String) {
        do {
            let realm = try Realm()
            guard let session = realm.object(ofType: SessionEntity.self, forPrimaryKey: sessionId) else {
                fatalError()
            }
            try realm.write {
                realm.delete(session)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
