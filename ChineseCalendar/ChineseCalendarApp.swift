//
//  ChineseCalendarApp.swift
//  ChineseCalendar
//
//  Created by Junyi Qiu on 2021/6/9.
//

import SwiftUI

@main
struct ChineseCalendarApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(calendar: calendar)
        }
    }
    
    let calendar = ChineseCalendar(date: {
                                   let formatter = DateFormatter()
                                   formatter.locale = Locale(identifier: "en_US_POSIX")
                                   formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                                   return formatter.date(from:"1950-04-16T00:00:00+0800")!}())
}
