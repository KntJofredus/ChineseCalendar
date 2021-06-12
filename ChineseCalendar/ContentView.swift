//
//  ContentView.swift
//  ChineseCalendar
//
//  Created by Junyi Qiu on 2021/6/9.
//

import SwiftUI

//struct LabeliCon {
//    static let on: Bool = true
//}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    // colorScheme == .dark
    
    @ObservedObject var calendar: ChineseCalendar
    
    var body: some View {
        VStack(alignment: .trailing, spacing: nil) {
            YearBar(yearName: calendar.yearName, yearSubName: calendar.yearSubName)
            MonthView(calendar: calendar)
                .environment(\.layoutDirection, .rightToLeft)
        }
        .padding()
    }
}


struct MonthView: View {
    @ObservedObject var calendar: ChineseCalendar

    var body: some View {
        HStack {
            ForEach(1..<7) { hangOrd in
                VStack {
                    ForEach(1..<9) { hangId in
                        if hangOrd == 1 && hangId == 1 {
                            ZStack{
                                Circle().foregroundColor(CalendarRed.scheme(.nippon))
                                HuoZi(contents: [ Array(calendar.month.monthName) ])
                                    .foregroundColor(.white)
                            }
                        }
                        else if hangOrd == 1 || hangId == 1 {
                            if hangOrd == 7 && !calendar.riList[35].inMonth {
                                LabelGrid(texts: MonthView.getLabel(hangOrd: hangOrd, hangId: hangId, usePlugin: calendar.riList.count == 36)).hidden()
                            }
                            else {
                                LabelGrid(texts: MonthView.getLabel(hangOrd: hangOrd, hangId: hangId, usePlugin: calendar.riList.count == 36))
                            }
                        }
                        else {
                            if (hangOrd == 6 && hangId == 2 && calendar.riList.count == 36) {
                                RiGrid2(calendar: calendar,
                                        ri: calendar.riList[ (hangOrd-2)*7+hangId-2 ],
                                        ri2: calendar.riList[ 35 ])
                            }
                            else {
                                if hangOrd == 7 && !calendar.riList[35].inMonth {
                                    RiGrid(ri: calendar.riList[ (hangOrd-2)*7+hangId-2 ])
                                        .onTapGesture(count:1, perform: {
                                            calendar.chooseDay((hangOrd-2)*7+hangId-2)
                                        }).hidden()
                                }
                                else {
                                    RiGrid(ri: calendar.riList[ (hangOrd-2)*7+hangId-2 ])
                                        .onTapGesture(count:1, perform: {
                                            calendar.chooseDay((hangOrd-2)*7+hangId-2)
                                        })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    static func getLabel(hangOrd ord: Int, hangId id: Int, usePlugin: Bool = false) -> [[Character]] {
        if ord == 1 {
            return [Array( qiZheng[id - 2] )]
        }
        else if id == 1 {
            if usePlugin && ord == 6 {
                return [Array( "五" ), Array( "│" ),  Array( "六" )]
            }
            else {
                return [Array( xingZhou[ord - 2] )]
            }
        }
        return []
    }
    
    enum colorScheme {
        case background
        case foreground
        case highlight
    }
    
    static let xingZhou = ["一", "二", "三", "四", "五", "六"]
    static let qiZheng = ["日曜日", "月曜日", "水曜日", "火曜日", "木曜日", "金曜日", "土曜日"]
}

struct LabelGrid: View {
    var body: some View {
        ZStack{
            Circle()
            HuoZi(contents: texts, isHorizontal: true).foregroundColor(Color(UIColor.systemBackground))
        }
    }
    
    
    var texts: [[Character]]
}

struct RiGrid: View {
    var body: some View {
        return ZStack{
            if ri.isChoosen {
                Circle().foregroundColor(CalendarRed.scheme(.Soviet))
                HuoZi(contents: ri.subNames).foregroundColor(.white)
            }
            else if ri.isToday {
                Circle().stroke()
                    .foregroundColor(CalendarRed.scheme(.China))
                    .background(Circle().foregroundColor(.white))
                HuoZi(contents: ri.subNames).foregroundColor(.black)
            }
            else {
                Circle().stroke()
                HuoZi(contents: ri.subNames)
            }
        }
    }
    
    var ri: Ri
}

struct RiGrid2: View {
    @ObservedObject var calendar: ChineseCalendar
    
    var body: some View {
        
        ZStack {

            ZStack {
            if ri.isChoosen {
                Circle().trim(from: 0.25, to: 0.75).rotation(.radians(.pi)).foregroundColor(CalendarRed.scheme(.Soviet))
                Circle().trim(from: 0.25, to: 0.75).rotation(.radians(.pi)).stroke().fill(CalendarRed.scheme(.Soviet))
                HStack(spacing: 2) {
                    HuoZi(spacing: 0, contents: ri.subNames).foregroundColor(.white)
                    HuoZi(spacing: 0, contents: ri2.subNames).foregroundColor(.white).hidden()
                }
            }
            else if ri.isToday {
                Circle().trim(from: 0.25, to: 0.75).rotation(.radians(.pi)).fill()
                    .foregroundColor(.white)
                Circle().trim(from: 0.25, to: 0.75).rotation(.radians(.pi)).stroke()
                    .foregroundColor(CalendarRed.scheme(.China))
//                    .background(Circle().foregroundColor(.white))
                HStack(spacing: 2) {
                    HuoZi(spacing: 0, contents: ri.subNames).foregroundColor(.black)
                    HuoZi(spacing: 0, contents: ri2.subNames).foregroundColor(.black).hidden()
                }
            }
            else {
                Circle().trim(from: 0.25, to: 0.75).rotation(.radians(.pi)).stroke()
                HStack(spacing: 2) {
                    HuoZi(spacing: 0, contents: ri.subNames)
                    HuoZi(spacing: 0, contents: ri2.subNames).hidden()
                }
            }
            }
            .onTapGesture(perform: {
                calendar.chooseDay(28)
            })
            
            ZStack {
            if ri2.isChoosen {
                Circle().trim(from: 0.25, to: 0.75).foregroundColor(CalendarRed.scheme(.Soviet))
                Circle().trim(from: 0.25, to: 0.75).stroke().fill(CalendarRed.scheme(.Soviet))
                HStack(spacing: 2) {
                    HuoZi(spacing: 0, contents: ri.subNames).foregroundColor(.white).hidden()
                    HuoZi(spacing: 0, contents: ri2.subNames).foregroundColor(.white)
                }
            }
            else if ri2.isToday {
                Circle().trim(from: 0.25, to: 0.75).fill()
                    .foregroundColor(.white)
                Circle().trim(from: 0.25, to: 0.75).stroke().foregroundColor(CalendarRed.scheme(.China))
                HStack(spacing: 2) {
                    HuoZi(spacing: 0, contents: ri.subNames).foregroundColor(.black).hidden()
                    HuoZi(spacing: 0, contents: ri2.subNames).foregroundColor(.black)
                }
            }
            else {
                Circle().trim(from: 0.25, to: 0.75).stroke()
                HStack(spacing: 2) {
                    HuoZi(spacing: 0, contents: ri.subNames).hidden()
                    HuoZi(spacing: 0, contents: ri2.subNames)
                }
            }
            }
            .onTapGesture(perform: {
                calendar.chooseDay(35)
            })
            
            GeometryReader { geometry in
                Rectangle().stroke().size(width: 0, height: geometry.size.width)
                    .position(x: 0.1, y: geometry.size.height - geometry.size.width/2)
                    .foregroundColor({
                        if ri.isChoosen || ri2.isChoosen {
                            return CalendarRed.scheme(.Soviet)
                        }
                        else if ri.isToday || ri2.isToday {
                            return CalendarRed.scheme(.China)
                        }
                        else {
                            return .primary
                        }
                    }())
            }
        }
    }
    
    
    var ri: Ri
    var ri2: Ri
}

struct HuoZi: View {
    var body: some View {
        HStack(spacing: spacing) {
            if !isHorizontal {
                VStack {
                    ForEach(0..<contents[0].count) { j in
                        Text(String(contents[0][j]))
                            .font(.caption).fontWeight(.bold)
                    }
                }
                VStack(spacing: 2) {
                    ForEach(1..<contents.count) { i in
                        VStack(spacing: 0) {
                            ForEach(0..<contents[i].count) { j in
                                Text(String(contents[i][j]))
                                    .font(.system(size: 8))
                            }
                        }
                    }
                }
            }
            else {
                ForEach(0..<contents.count) { i in
                    VStack(spacing: 0) {
                        ForEach(0..<contents[i].count) { j in
                            Text(String(contents[i][j]))
                                .font(.caption).fontWeight(.bold)
                        }
                    }
                }
            }
        }
    }
    
    var spacing: CGFloat = 2
    var contents: [[Character]] = []
    var isHorizontal: Bool = false
}

struct YearBar: View {
    var body: some View {
        VStack(alignment: .trailing, spacing: nil) {
            Text(yearSubName).font(.caption)
            Text(yearName)
        }
    }
    
    var yearName: String
    var yearSubName: String
}

enum RedType {
    case China
    case cina
    case mix
    case Soviet
    case nippon
}

struct CalendarRed {
    static func scheme(_ of: RedType) -> Color {
        switch of {
        case .China   : return Color(red: 238/256.0, green: 28/256.0, blue: 37/256.0)
        case .cina    : return Color(red: 222/256.0, green: 41/256.0, blue: 16/256.0)
        case .mix     : return Color(red: 191/256.0, green:  0/256.0, blue:  8/256.0)
        case .Soviet  : return Color(red: 205/256.0, green:  0/256.0, blue:  0/256.0)
        case .nippon  : return Color(red: 176/256.0, green:  0/256.0, blue: 15/256.0)
        }
    }
}













struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        
        
        ContentView(calendar: ChineseCalendar(date: {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return formatter.date(from:"1950-03-16T00:00:00+0800")!}() ))
            .preferredColorScheme(.dark)
    }
    
//    static let formatter = DateFormatter()
}
