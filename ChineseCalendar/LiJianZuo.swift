//
//  ChineseCalendar.swift
//  ChineseCalendar
//
//  Created by Junyi Qiu on 2021/6/10.
//

import SwiftUI

class LiJianZuo: ObservableObject {
    @Published private var slip: CalendarSlip
    
    init(date: Date = Date()) {
        self.slip = CalendarSlip(date)
    }
    
    
    // MARK: - Intent
    func chooseDay(_ day: Int) -> Void {
        slip.chooseDay(day)
    }
    
//    func toggleYueBiao(_ yueBiao: Bool) -> Void {
//        self.yueBiao = yueBiao
//    }
    
    // MARK: - Access
    var yearName: String {
        slip.year.dynastyTitle + slip.year.dynastyName + slip.year.eraName + NumConverter.convert(slip.year.eraYearId) + "年"
    }
    
    var yearSubName: String {
        "褒成宣尼" + NumConverter.convert(slip.year.yearId) + "年"
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
    
//    var useYueBiao: Bool {
//        self.yueBiao
//    }
//
//    @Published private var yueBiao: Bool = false
    
    static let xingZhou = ["一", "二", "三", "四", "五", "六"]
    static let qiZheng = ["日曜日", "月曜日", "水曜日", "火曜日", "木曜日", "金曜日", "土曜日"]
}
