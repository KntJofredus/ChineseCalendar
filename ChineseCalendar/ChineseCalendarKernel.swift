//
//  ChineseCalendarKernel.swift
//  ChineseCalendar
//
//  Created by Junyi Qiu on 2021/6/9.
//

import Foundation

struct CalendarSlip {
    var anchorDate: Date
    
    var day: DayData
    var month: MonthData
    var year: YearData
    
    init(_ date: Date = Date()) {
        anchorDate = CalendarSlip.cinaCalendar.startOfDay(for: date)
        print("\(anchorDate)")
        year = YearData(date: anchorDate)
        month = MonthData(year: year, date: anchorDate)
        day = DayData(month: month, date: anchorDate)
    
        year.generateEra(month: month)
        yueList = CalendarSlip.generateYueList(year: year, month: month)
        riList = CalendarSlip.generateRiList(month: month, day: day)
        choosenIdx = day.dayId + month.initialLumin - 2
        currentIdx = day.dayId + month.initialLumin - 2
    }
    
    var nianList: Array<Nian> = []
    var yueList: Array<Yue> = []
    var riList: Array<Ri> = []
    var choosenIdx: Int = 0
    var currentIdx: Int = 0
    
    mutating func chooseDay(_ idxInList: Int) {
        self.riList[choosenIdx].isChoosen = false
        self.choosenIdx = idxInList
        self.riList[choosenIdx].isChoosen = true
    }
    
    static func generateYueList(year: YearData, month: MonthData) -> Array<Yue> {
        var zodiacId = 1
        var yueList = Array<Yue>()
        for idx in ( 0 ..< 12 ) {
            let name = Cina.YueName[ idx ]
            let zodiac = ZodiacConvert.convert(zodiacId) + "月"
            yueList.append(Yue(id: idx,
                               name: name,
                               zodiac: zodiac,
                               subNames:[ Array(name), Array(zodiac) ],
                               isLeap: false,
                               isBig: year.numOfDaysList[idx] == 30))
            if let nDays = year.leapMonthsList[idx] {
                zodiacId += 1
                let zodiac = ZodiacConvert.convert(zodiacId) + "月"
                yueList.append(Yue(id: idx+12,
                                   name: "閏"+name,
                                   zodiac: zodiac,
                                   subNames:[ Array(name), Array(zodiac) ],
                                   isLeap: true,
                                   isBig: nDays == 30))
            }
            zodiacId += 1
        }
        
        return yueList
    }
    
    static func getPrevNian(year: YearData) -> Nian? {
        return nil
    }
    
    static func getNextNian(year: YearData) -> Nian? {
        return nil
    }
    
    static func getPrevYue(year: YearData, month: MonthData) -> Yue? {
        return nil
    }
    
    static func getNextYue(year: YearData, month: MonthData) -> Yue? {
        return nil
    }
    
    static func generateRiList(month: MonthData, day: DayData) -> Array<Ri> {
        var riList = Array<Ri>()
        for idx in ( 0 ..< (7*5+1) ) {
            let dayIdx = idx + 1 - month.initialLumin
            let inMonth = (dayIdx >=  0 && dayIdx < month.numDays)
            
            let name = inMonth ? Cina.RiName[ dayIdx ] : ""
            let zodiac = ZodiacConvert.convert(dayIdx+1)
            var subtitles: Array<Array<Character>> = [ Array(name), Array(zodiac) ]
            if let festival = month.lunarFests[dayIdx + 1] {
                subtitles.append(Array( festival ))
            }
            if let festival = month.lunarFests[dayIdx - month.numDays] {
                subtitles.append(Array( festival ))
            }
            riList.append(Ri(id: idx,
                             name: name,
                             zodiac: zodiac,
                             subNames: subtitles,
                             inMonth: inMonth,
                             isToday: dayIdx + 1 == day.dayId,
                             isChoosen: dayIdx + 1 == day.dayId))
        }
        
        return riList
    }

    static let currentDate: Date = Date()
    static let cinaCalendar: Calendar = Calendar(identifier: .chinese)
    static let conCalendar: Calendar = Calendar(identifier: .iso8601)
}

struct Nian: Identifiable {
    var id: Int
    var name: String
    var zodiac: String
}

struct Yue: Identifiable {
    var id: Int
    
    var name: String
    var zodiac: String
    var subNames: Array<Array<Character>> = []
    
    var isLeap: Bool
    var isBig: Bool = true
}

struct Ri: Identifiable {
    var id: Int
    
    var name: String
    var zodiac: String
    var subNames: Array<Array<Character>> = []
    
    var inMonth: Bool
    var isToday: Bool
    var isChoosen: Bool
}

struct DayData {
    var dayId: Int
    var zodiacId: Int
    
    var luminId: Int
    var luminOrd: Int
    
    init(year: YearData? = nil, month: MonthData, date: Date) {
        dayId = CalendarSlip.cinaCalendar.component(.day, from: date)
        
        zodiacId = 1
        
        luminId = CalendarSlip.cinaCalendar.component(.weekday, from: date)
        luminOrd = CalendarSlip.cinaCalendar.component(.weekOfMonth, from: date)
    }
}

struct MonthData {
    var monthId: Int
    
    var monthName: String
    
    var initialLumin: Int
    
    var numDays: Int
    
    var isLeap: Bool
    
    var solarTerms: [Int: String] = [:]
    
    var lunarFests: [Int: String] = [:]
    
    init(year: YearData, date: Date) {
        monthId = CalendarSlip.cinaCalendar.component(.month, from: date)
        
        initialLumin = MonthData.initialLuminOf(date: date)
        
        isLeap = MonthData.isLeapFor(year: year, monthId: monthId, date: date)
//        if isLeap {
//            numDays = year.leapMonthsList[monthId]!
//            if monthId == 12 {
//                lunarFests = Cina.LunarFestival[monthId-1]
//            }
//        }
        numDays = (isLeap) ?  year.leapMonthsList[monthId]! : year.numOfDaysList[monthId-1]
        if monthId != 12 {
            lunarFests = Cina.LunarFestival[monthId-1]
        }
        else {
            if !year.leapMonthsList.keys.contains(monthId) {
                lunarFests = Cina.LunarFestival[monthId-1]
            }
            else if isLeap {
                lunarFests = Cina.LunarFestival[monthId-1]
            }
        }
        
        monthName = (isLeap ? "閏" : "") + Cina.YueName[monthId-1]
    }
    
    static func initialLuminOf(date: Date) -> Int {
        let dayId: Int = CalendarSlip.cinaCalendar.component(.day, from: date)
        let weekDay: Int = CalendarSlip.cinaCalendar.component(.weekday, from: date)
        
        return Integer.mod(b: weekDay - dayId + 1, n: 7)
    }
    
    static func isLeapFor(year: YearData, monthId: Int, date: Date) -> Bool {
        if let _ = year.leapMonthsList[monthId] {
            let dayId = CalendarSlip.cinaCalendar.component(.day, from: date)
            let ciHuiRi = CalendarSlip.cinaCalendar.date(bySetting: .day, value: (dayId < 29) ? 29 : dayId, of: date)!
            let nextSuDay = CalendarSlip.cinaCalendar.date(bySetting: .day, value: 1, of: ciHuiRi)!
            let nextMonthId = CalendarSlip.cinaCalendar.component(.month, from: nextSuDay)
            if nextMonthId != monthId {
                return true
            }
        }
        return false
    }
    
    static var dayZodiacAnchor: Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from:"1949-10-01T00:00:00+0800")!
    }
}

struct YearData {
    var yearId: Int
    
    var zodiacId: Int
    var zodiacName: String
    
    var dynastyTitle: String = ""
    var dynastyName: String = "華"
    
    var eraName: String = "人民共和"
    var eraYearId: Int = 1
    
    var secondaryYearNamesList: Array<String> = Array<String>()
    var numOfDaysList: Array<Int> = Array<Int>()
    
    var leapMonthsList: [Int: Int] = [:]
    
    init(date: Date) {
        yearId = CalendarSlip.conCalendar.component(.year, from: date)
//        zodiacId = (yearId - 4) % 60 + 1
        zodiacId = CalendarSlip.cinaCalendar.component(.year, from: date)
        zodiacName = ZodiacConvert.convert(zodiacId)
        
//        dynastyTitle = ""
//        dynastyName = "華"
//        eraName = "人民共和"
//        eraYearId = yearId - 1949 + 1
        
        (numOfDaysList, leapMonthsList) = YearData.monthInfoOf(yearId: yearId, date: date)
    }
    
    mutating func generateEra(month: MonthData) {
        let (firstYear, firstMonth, isfMLeap, _) = Cina.Dynasty[0]
        if (( yearId < firstYear ) ||
            ( yearId == firstYear && month.monthId < firstMonth) ||
            ( yearId == firstYear && month.monthId == firstMonth && !month.isLeap && isfMLeap )) {
            dynastyName = Cina.Dynasty[0].dynasty
            eraName = "前"
            eraYearId = firstYear - yearId + 1
            
            return
        }
        var (dYear, dMonth, isdMLeap, dynasty): (Int, Int, Bool, String)
        for idx in (0 ..< Cina.Dynasty.count) {
            (dYear, dMonth, isdMLeap, dynasty) = Cina.Dynasty[idx]
            if !(   yearId < dYear ||
                    (yearId == dYear && month.monthId < dMonth) ||
                    (yearId == dYear && month.monthId == dMonth && !month.isLeap && isdMLeap )) {
                dynastyName = dynasty
                var (eYear, eMonth, iseMLeap, era): (Int, Int, Bool, String)
                for jdx in (0 ..< Cina.EraName[dynastyName]!.count) {
                    (eYear, eMonth, iseMLeap, era) = Cina.EraName[dynastyName]![jdx]
                    var (tYear, tMonth, istMLeap) = (eYear, eMonth, iseMLeap)
                    if (tMonth < 0) {
                        (tYear, tMonth) = (tYear-1, -tMonth)
                    }
                    if !(   yearId < tYear ||
                            (yearId == tYear && month.monthId < tMonth) ||
                            (yearId == tYear && month.monthId == tMonth && !month.isLeap && istMLeap )) {
                        eraName = era
                        eraYearId = yearId - eYear + 1
                        if (( eMonth < 0)                                                     &&
                            ( ( month.monthId > tMonth )                                 ||
                              ( month.monthId == tMonth && (month.isLeap || !istMLeap) )    )    ) {
                            eraYearId += 1
                        }
                    }
                }
                
                return
            }
        }
//        dynastyName = Cina.Dynasty[0].dynasty
    }
    
    static func getYuanRi(yearId: Int, date: Date) -> Date {
        var dateComponents = DateComponents()
        dateComponents.month = 12
//        dateComponents.day = 1
        var firstDate = CalendarSlip.cinaCalendar.nextDate(after: date, matching: dateComponents, matchingPolicy: .nextTime, direction: .backward)!
//        dateComponents = DateComponents()
        dateComponents.month = 1
        dateComponents.day = 1
        firstDate = CalendarSlip.cinaCalendar.nextDate(after: firstDate, matching: dateComponents, matchingPolicy: .nextTime, direction: .forward)!
        if leapJanYearsList.contains(yearId) {
            dateComponents.day = 15
            let pprvDate = CalendarSlip.cinaCalendar.nextDate(after: firstDate, matching: dateComponents, matchingPolicy: .nextTime, direction: .backward)!
            let pprvMonth = CalendarSlip.cinaCalendar.component(.year, from: pprvDate)
            if pprvMonth == 1 {
                dateComponents.day = 1
                firstDate = CalendarSlip.cinaCalendar.nextDate(after: pprvDate, matching: dateComponents, matchingPolicy: .nextTime, direction: .backward)!
            }
        }
        return firstDate
    }
    
    static func monthInfoOf(yearId: Int, date: Date) -> (Array<Int>, [Int: Int]) {
        var numOfDaysList: Array<Int> = []
        var leapMonthsList: [Int: Int] = [:]
        
        var firstDate = YearData.getYuanRi(yearId: yearId, date: CalendarSlip.cinaCalendar.startOfDay(for: date))
        var monthId: Int = 1
        for _ in 0..<12 {
            firstDate = firstDate.advanced(by: 29 * 86400)
            var nextMonthId = CalendarSlip.cinaCalendar.component(.month, from: firstDate)
            let nextDayId = CalendarSlip.cinaCalendar.component(.day, from: firstDate)
            if nextDayId == 1 {
                numOfDaysList.append(29)
            }
            else if nextDayId == 30{
                numOfDaysList.append(30)
                firstDate = firstDate.advanced(by: 1 * 86400)
                nextMonthId = CalendarSlip.cinaCalendar.component(.month, from: firstDate)
            }
            else {
                exit(1)
            }
            if nextMonthId == monthId || YearData.leapMonthDict[yearId] == monthId {
                firstDate = firstDate.advanced(by: 29 * 86400)
                let nextDayId = CalendarSlip.cinaCalendar.component(.day, from: firstDate)
                if nextDayId == 1 {
                    leapMonthsList[monthId] = 29
                }
                else if nextDayId == 30{
                    leapMonthsList[monthId] = 30
                    firstDate = firstDate.advanced(by: 1 * 86400)
                }
            }
            monthId += 1
            // check dayId == 1
        }
        
        return (numOfDaysList, leapMonthsList)
    }
    
    static let leapMonthDict: Dictionary<Int, Int> = [1949:7, 1952:5, 1955:3, 1957:8, 1960:6, 1963:4, 1966:3, 1968:7,
                                                      1971:5, 1974:4, 1976:8, 1979:6, 1982:4, 1984:10, 1987:6,
                                                      1990:5, 1993:3, 1995:8, 1998:5, 2001:4, 2004:2, 2006:7,
                                                      2009:5, 2012:4, 2014:9, 2017:6, 2020:4, 2023:2, 2025:6,
                                                      2028:5, 2031:3, 2033:11, 2036:6, 2039:5, 2042:2, 2044:7,
                                                      2047:5, 2050:3]
    static let leapJanYearsList: Set<Int> = [8, 27, 103, 141, 160, 179, 217, 331, 369, 388, 426, 600, 657, 687, 706, 763, 782, 801, 820, 839, 1048, 1116, 1173, 1268, 1306, 1317, 1355, 1420, 1488, 1507, 1545, 1640, 2262, 2357, 2520, 2539, 2634, 4103, 4828, 4923, 5868, 6088, 6183, 6240, 6278, 6460, 6555, 6612, 6650, 6832, 6984, 7022, 7041, 7166, 7242, 7424, 7519, 7538, 7614, 7633, 7796, 7891, 7910, 7986, 8005, 8206, 8377, 8388, 8578, 8760, 8798, 8855, 8874, 8950, 8969, 9132, 9170, 9208, 9227, 9322, 9341, 9390, 9523, 9542, 9580, 9599, 9610, 9618, 9705, 9713, 9724, 9762, 9800, 9838, 9914, 9933, 9982]
}

struct Cina {
    static let Dynasty: Array<(year: Int, month: Int, isleap: Bool, dynasty: String)> = [
        (1911, 11, false, "華")
    ]
    
    static let EraName: Dictionary<String, Array<(Int, Int, Bool, String)>> = [
        "華": [(1912, -11, false, "民國"),
                (1949, 8, false, "人民共和")
        ]
        
    ]
    
    static let YueName: Array<String> = [
        "正月", "二月", "三月", "四月", "五月", "六月",
        "七月", "八月", "九月", "十月", "冬月", "臘月",
        "閏正月", "閏二月", "閏三月", "閏四月", "閏五月", "閏六月",
        "閏七月", "閏八月", "閏九月", "閏十月", "閏冬月", "閏臘月"
    ]
    static let RiName = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                          "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                          "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
    static let SolarFestival: Array<String> = []
    static let LunarFestival: Array<Dictionary<Int, String>> = [
        // 正月
        [1:"元旦", 7:"人節", 15:"上元", -1:"初晦"],
        // 二月
        [1:"中和", 15:"花朝"],
        // 三月
        [3:"上巳"],
        // 四月
        [:],
        // 五月
        [5:"端午"],
        // 六月
        [:],
        // 七月
        [7:"七夕", 15:"中元"],
        // 八月
        [10:"開國", 15:"中秋", 27:"孔誕"],
        // 九月
        [9:"重陽"],
        // 十月
        [1:"寒衣", 15:"下元"],
        // 冬月
        [11:"冬祭"],
        // 臘月
        [8:"臘八",  -1:"除夕"],
    ]
}

struct NumConverter {
    static func convert(_ number: Int) -> String {
        var CinaNum: String
        
        var num: Int = number
        if num < 0 {
            num = -num
        }
        if num == 1 {
            return "元"
        }
        if number <= 10 {
            CinaNum = digitList[number]
        }
        else if number <= 100 {
            if number == 100 {
                CinaNum = "一百"
            }
            else {
                CinaNum =  "十"
                if number / 10 != 1 {
                    CinaNum = digitList[num/10] + CinaNum
                }
                if number % 10 != 0 {
                    CinaNum =  CinaNum + digitList[num%10]
                }
            }
        }
        else {
            CinaNum = ""
            while num > 0 {
                CinaNum = digitList[num % 10] + CinaNum
                num /= 10
            }
        }
        
        return CinaNum
    }
    
    static func translate(_ number: Int) -> String {
        var CinaNum: String = ""
        var num: Int = number
        if num < 0 {
            num = -num
        }
        
        if number <= 10 {
            CinaNum = digitList[number]
        }
        else if number <= 100000 {
            var digit = num % 10
            if digit != 0{
                CinaNum = digitList[num % 10]
            }
            num /= 10
            
            
            var hasZero: Bool
            var level: Int = 0
            while num > 0 {
                hasZero = digit == 0
                
                digit = num % 10
                if digit == 0 {
                    if !hasZero {
                        CinaNum = "〇" + CinaNum
                    }
                }
                else {
                    CinaNum = expList[level] + CinaNum
                    if digit != 1 || level != 0 {
                        CinaNum = digitList[digit] + CinaNum
                    }
                }
                num /= 10
                level += 1
            }
        }
        
        if number < 0 {
            CinaNum = "前"
            num = -number
        }
        return CinaNum
    }
    
    static let digitList: Array<String> = ["〇", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
    static let expList: Array<String> = ["十", "百", "千", "萬"]
}

struct ZodiacConvert {
    static func convert(_ number: Int) -> String {
        return UpZodiac[Integer.mod(b:(number-1), n:10)] + DownZodiac[Integer.mod(b:(number-1), n:12)]
    }
    
    static let UpZodiac: Array<String> = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    static let DownZodiac: Array<String> = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
}


struct Integer {
    static func mod(b: Int, n: Int) -> Int {
        if (n == 0 || n == 1) {
            return 0
        }

        let (a, m) = (n > 0) ? (b, n) : (-b, -n)
        if (a >= 0) {
            return a % m
        }
        else {
            return m - ((-a) % m)
        }
    }
}
