//
//  ChineseCalendar.swift
//  ChineseCalendar
//
//  Created by Junyi Qiu on 2021/6/10.
//

import SwiftUI

class ChineseCalendar: ObservableObject {
    @Published private var slip: CalendarSlip
    
    init(date: Date = Date()) {
        self.slip = CalendarSlip(date)
    }
    
    
    // MARK: - Intent
    func chooseDay(_ day: Int) -> Void {
        slip.chooseDay(day)
    }
    
    
    // MARK: - Access
    var yearName: String {
        String((slip.year.dynastyTitle + slip.year.dynastyName + slip.year.eraName + NumConverter.convert(slip.year.eraYearId) + "年").reversed())
    }
    
    var yearSubName: String {
        String(("褒成宣尼" + NumConverter.convert(slip.year.yearId) + "年").reversed())
    }
    
    var month: MonthData {
        slip.month
    }
    
    var dayInfo: (id: Int, luminId: Int, luminOrd: Int) {
        (slip.day.dayId, slip.day.luminId, slip.day.luminOrd)
    }
    
    var riList: Array<Ri> {
        slip.riList
    }
}
