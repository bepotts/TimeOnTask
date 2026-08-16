//
//  TimeOnTaskTests.swift
//  TimeOnTaskTests
//
//  Created by Brandon Potts on 8/16/26.
//

import Testing
@testable import TimeOnTask

@MainActor
struct TimeOnTaskTests {

    @Test func defaultsToTwentyFiveMinutes() {
        // Fresh timer engine used to verify default startup state.
        let engine = TimerEngine()
        #expect(engine.formattedRemaining == "25:00")
        #expect(engine.duration == .minutes(25))
    }

    @Test func presetChangesRemainingWhileIdle() {
        // Fresh timer engine used to verify presets update idle remaining time.
        let engine = TimerEngine()
        engine.selectPreset(.minutes(45))
        #expect(engine.formattedRemaining == "45:00")
    }

    @Test func presetIsIgnoredOnceRunning() {
        // Fresh timer engine used to verify running timers ignore preset changes.
        let engine = TimerEngine()
        engine.start()
        engine.selectPreset(.minutes(60))
        #expect(engine.duration == .minutes(25))
    }

    @Test func stopResetsToChosenDuration() {
        // Fresh timer engine used to verify stop returns to the selected duration.
        let engine = TimerEngine()
        engine.selectPreset(.minutes(15))
        engine.start()
        engine.stop()
        #expect(engine.phase == .idle)
        #expect(engine.formattedRemaining == "15:00")
    }
}
