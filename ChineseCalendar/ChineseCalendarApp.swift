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
            ContentView(li: calendar)
        }
    }
    
    let calendar = LiJianZuo(date: {
                                   let formatter = DateFormatter()
                                   formatter.locale = Locale(identifier: "en_US_POSIX")
                                   formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                                   return formatter.date(from:"1950-01-01T00:00:00+0800")!}())
//    let calendar = LiJianZuo()
}
