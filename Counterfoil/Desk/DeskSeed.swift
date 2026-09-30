import Foundation

/// Role: Desk. Simulator demo only, once behind ctf.demo.v1. Device never writes this. First frame is a live Cooling ticket, never Blank.
enum DeskSeed {
    private static func fixed(_ value: String) -> UUID {
        UUID(uuidString: value) ?? UUID()
    }

    static func desk(now: Date = Date(), calendar: Calendar = .current) -> Desk {
        let day = DeskDay.key(now, calendar: calendar)
        let bagID = fixed("aaaaaaaa-0001-4000-8000-000000000001")
        let lampID = fixed("aaaaaaaa-0001-4000-8000-000000000002")
        let noteID = fixed("aaaaaaaa-0001-4000-8000-000000000003")
        let cableID = fixed("aaaaaaaa-0001-4000-8000-000000000004")
        let chairID = fixed("aaaaaaaa-0001-4000-8000-000000000005")
        let kettleID = fixed("aaaaaaaa-0001-4000-8000-000000000006")
        let trayID = fixed("aaaaaaaa-0001-4000-8000-000000000007")

        let bagHours = RailHours.hours(price: 80, monthlyLimit: 400, priority: 1, necessity: 40, discretion: 30)
        let lampHours = RailHours.hours(price: 200, monthlyLimit: 400, priority: 1.2, necessity: 20, discretion: 10)
        let noteHours = RailHours.hours(price: 18, monthlyLimit: 400, priority: 1, necessity: 70, discretion: 20)
        let cableHours = RailHours.hours(price: 24, monthlyLimit: 400, priority: 1, necessity: 50, discretion: 40)

        let bag = WillCall(
            id: bagID,
            name: "Field bag",
            price: 80,
            priority: 1,
            necessity: 40,
            discretion: 30,
            retailCode: "848000111111",
            hold: .cooling,
            ticket: ClaimCheck(computedHours: bagHours, stampedAt: now, stampedDayKey: day),
            fate: nil,
            filedAt: now.addingTimeInterval(-86_400),
            filedDayKey: DeskDay.key(now.addingTimeInterval(-86_400), calendar: calendar)
        )
        let lamp = WillCall(
            id: lampID,
            name: "Desk lamp",
            price: 200,
            priority: 1.2,
            necessity: 20,
            discretion: 10,
            retailCode: "848000222222",
            hold: .cooling,
            ticket: ClaimCheck(computedHours: lampHours, stampedAt: now, stampedDayKey: day),
            fate: nil,
            filedAt: now.addingTimeInterval(-172_800),
            filedDayKey: DeskDay.key(now.addingTimeInterval(-172_800), calendar: calendar)
        )
        let note = WillCall(
            id: noteID,
            name: "Notebook",
            price: 18,
            priority: 1,
            necessity: 70,
            discretion: 20,
            retailCode: "848000333333",
            hold: .released,
            ticket: ClaimCheck(
                computedHours: noteHours,
                stampedAt: now.addingTimeInterval(-400_000),
                stampedDayKey: DeskDay.key(now.addingTimeInterval(-400_000), calendar: calendar)
            ),
            fate: .bought,
            filedAt: now.addingTimeInterval(-500_000),
            filedDayKey: DeskDay.key(now.addingTimeInterval(-500_000), calendar: calendar)
        )
        let cable = WillCall(
            id: cableID,
            name: "Cable",
            price: 24,
            priority: 1,
            necessity: 50,
            discretion: 40,
            retailCode: "848000444444",
            hold: .released,
            ticket: ClaimCheck(
                computedHours: cableHours,
                stampedAt: now.addingTimeInterval(-250_000),
                stampedDayKey: DeskDay.key(now.addingTimeInterval(-250_000), calendar: calendar)
            ),
            fate: .cut,
            filedAt: now.addingTimeInterval(-300_000),
            filedDayKey: DeskDay.key(now.addingTimeInterval(-300_000), calendar: calendar)
        )
        let chair = WillCall(
            id: chairID,
            name: "Chair",
            price: 140,
            priority: 1.1,
            necessity: 30,
            discretion: 25,
            retailCode: nil,
            hold: .blank,
            ticket: nil,
            fate: nil,
            filedAt: now.addingTimeInterval(-7_200),
            filedDayKey: day
        )
        let kettle = WillCall(
            id: kettleID,
            name: "Kettle",
            price: 55,
            priority: 1,
            necessity: 60,
            discretion: 15,
            retailCode: "848000555555",
            hold: .blank,
            ticket: nil,
            fate: nil,
            filedAt: now.addingTimeInterval(-3_600),
            filedDayKey: day
        )
        let tray = WillCall(
            id: trayID,
            name: "Tray",
            price: 32,
            priority: 1,
            necessity: 45,
            discretion: 35,
            retailCode: nil,
            hold: .blank,
            ticket: nil,
            fate: nil,
            filedAt: now,
            filedDayKey: day
        )

        let cover = CoverMark(
            id: fixed("bbbbbbbb-0001-4000-8000-000000000001"),
            releasedWantID: noteID,
            sacrificedWantID: cableID,
            coveredHours: cableHours,
            dayKey: DeskDay.key(now.addingTimeInterval(-90_000), calendar: calendar),
            markedAt: now.addingTimeInterval(-90_000)
        )

        return Desk(
            schemaVersion: Desk.currentSchema,
            onboardingComplete: true,
            wants: [bag, lamp, note, cable, chair, kettle, tray],
            coverMarks: [cover],
            shortMarks: [],
            rules: DeskRule(monthlyImpulseLimit: 400),
            faceID: bagID
        )
    }
}
