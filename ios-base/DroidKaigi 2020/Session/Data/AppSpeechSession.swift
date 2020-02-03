import ios_combined
import RealmSwift

// MARK: - initialized with SpeechSession of api-model.

final class AppSpeechSession: Object {
    @objc dynamic var id: AppSessionId?
    @objc dynamic var dayNumber: Int32 = 0
    @objc dynamic var startTime: TimeInterval = 0
    @objc dynamic var endTime: TimeInterval = 0
    @objc dynamic var title: AppLocaledString?
    @objc dynamic var desc: String = ""
    @objc dynamic var room: AppRoom?
    @objc dynamic var rawLang: String = ""
    @objc dynamic var category: AppCategory?
    @objc dynamic var intendedAudience: String?
    @objc dynamic var videoUrl: String?
    @objc dynamic var slideUrl: String?
    @objc dynamic var isInterpretationTarget: Bool = false
    @objc dynamic var timeInMinutes: Int32 = 0
    @objc dynamic var isFavorited: Bool = false
    @objc dynamic var startDayText: String = ""
    @objc dynamic var startTimeText: String = ""
    @objc dynamic var timeRoomText: String = ""
    let speakers: List<AppSpeaker>
    @objc dynamic var message: AppLocaledString?

    var lang: Lang {
        get {
            if rawLang == "ja" {
                return .ja
            } else {
                return .en
            }
        }
        set {
            rawLang = newValue.text.getByLang(lang: newValue)
        }
    }

    init(session: SpeechSession) {
        id = .init(sessionId: session.id)
        dayNumber = session.dayNumber
        startTime = session.startTime
        endTime = session.endTime
        title = .init(localedString: session.title)
        desc = session.desc
        room = .init(room: session.room)
        category = .init(category: session.category)
        intendedAudience = session.intendedAudience
        videoUrl = session.videoUrl
        slideUrl = session.slideUrl
        isInterpretationTarget = session.isInterpretationTarget
        timeInMinutes = session.timeInMinutes
        isFavorited = session.isFavorited
        startDayText = session.startDayText
        startTimeText = session.startTimeText
        timeRoomText = session.timeRoomText
        if let message = session.message {
            self.message = .init(localedString: message)
        }
        let speakers = List<AppSpeaker>()
        speakers.append(objectsIn: session.speakers.map { AppSpeaker(speaker: $0) })
        self.speakers = speakers
        super.init()
        lang = session.lang
    }

    required init() {
        speakers = List()
        super.init()
    }
}