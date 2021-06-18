//
//  ContentView.swift
//  ChineseCalendar
//
//  Created by Junyi Qiu on 2021/6/9.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    // colorScheme == .dark
    
    @ObservedObject var li: LiJianZuo
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            VStack(alignment: .center, spacing: nil) {

                NianBiao(zhengtongNianFeng: li.yearName, baochengNianFeng: li.yearSubName, yueFeng: "", shuShi: false)
                    .padding(5)
                YueBiaoXiaoTu(li: li)
                    .environment(\.layoutDirection, .rightToLeft)
                    .background(Rectangle().colorInvert())
            }
        }
    }
}

struct YueBiaoXiaoTu: View {
    @ObservedObject var li: LiJianZuo

    var body: some View {
        ZStack {
            HStack { ForEach(0..<6) { hangOrdx in
                VStack { ForEach(-1..<8) { hangIdx in
                    if hangOrdx == 0 && hangIdx > 0{
                        QiZhengDian(zi: YueBiaoXiaoTu.qiZheng[ hangIdx - 1 ])
                    }
                    else {
                        Circle().hidden()
                    }
                } }
            } }
            .padding()
            HStack { ForEach(0..<6) { hangOrdx in
                VStack { ForEach(-1..<8) { hangIdx in
                    if hangOrdx == 0 && hangIdx == -1 {
                        YueDian(yueFeng: li.month.monthName)
                    }
                    else if hangIdx == 0 {
                        XingZhouDian(zi: NumConverter.convert(li.month.suRiXingZhou + hangOrdx)+"週")//.hidden()
                    }
                    else if hangIdx > 0 {
                        ZStack {
                            RiDian(ri: li.riList[ hangOrdx*7+hangIdx-1 ])
                                .onTapGesture(count:1, perform: {
                                    li.chooseDay(hangOrdx*7+hangIdx-1)
                                })
//                            if li.riList[ hangOrdx*7+hangIdx-1 ].name == "初一" {
//                                YueBiao(yueFeng: li.month.monthName).hidden()
//                            }
                        }
                    }
                    else {
                        Circle().hidden()
                    }
                } }
            } }
            .padding()
        }
    }
    
    static let xingZhou = ["一", "二", "三", "四", "五", "六"]
    static let qiZheng = ["日", "月", "水", "火", "木", "金", "土"]
}

struct YueDian: View {
    var body: some View {
        ZStack {
            Circle().foregroundColor(CalendarRed.scheme(.nippon))
            ShuPaiZi(wenZi: yueFeng, ziHao: .caption)
        }
    }
    
    var yueFeng: String
}

struct YueBiao: View {
    var body: some View {
        GeometryReader { g in
            ShuPaiZi(wenZi: yueFeng, ziHao: .caption)
                .padding(2)
                .background(RoundedRectangle(cornerRadius: 2.5)
                                .foregroundColor(CalendarRed.scheme(.nippon)))
                .font(.caption)
                .position(x: 0, y: g.size.height/2 - g.size.width/2)
//                .position(x: g.size.width/2, y: g.size.height/2 - g.size.width * 0.75)
                
        }
    }
    
    var yueFeng: String
}
struct QiZhengDian: View {
    var body: some View {
        GeometryReader { g in
            Circle().hidden()
                .background( ZStack {
                    RoundedRectangle(cornerRadius: 2.5)
                        .frame(width: g.size.width*0.333, height: g.size.width*0.333, alignment: .topLeading)
                        .position(x: 0, y: 0)
                        
                    Text(zi)
                        .font(.caption)
                        .colorInvert()
                        .position(x: 0, y: 0)
                } )
        }
    }
    
    var zi: String
}


struct XingZhouDian: View {
    var body: some View {
        ZStack{
            Circle()
            ShuPaiZi(wenZi: zi, ziHao: .caption2)
                .colorInvert()
        }
    }
    
    
    var zi: String
}

struct RiDian: View {
    var body: some View {
        ZStack{
            if ri.isToday {
                Circle().foregroundColor(CalendarRed.scheme(.Soviet))
                HuoZi(contents: ri.subNames).foregroundColor(.white)
            }
            else if ri.isChoosen {
                Circle().stroke()
                    .foregroundColor(CalendarRed.scheme(.China))
                    .background(Circle())
                HuoZi(contents: ri.subNames).colorInvert()
            }
            else {
                Circle().stroke()
                HuoZi(contents: ri.subNames)
            }
        }
    }
//    {
//        ZStack{
//            if ri.isChoosen {
//                Circle().foregroundColor(CalendarRed.scheme(.Soviet))
//                HStack {
//                    ShuPaiZi(wenZi: ri.name, ziHao: .caption)
//                        .foregroundColor(.white)
//                    ShuPaiZi(wenZi: ri.zodiac, ziHao: .caption2)
//                        .foregroundColor(.white)
//                }
//            }
//            else if ri.isToday {
//                Circle().stroke()
//                    .foregroundColor(CalendarRed.scheme(.China))
//                    .background(Circle().foregroundColor(.white))
//                HStack {
//                    ShuPaiZi(wenZi: ri.name, ziHao: .caption)
//                        .foregroundColor(.black)
//                    ShuPaiZi(wenZi: ri.zodiac, ziHao: .caption2)
//                        .foregroundColor(.black)
//                }
//            }
//            else {
//                Circle().stroke()
//                HStack {
//                    ShuPaiZi(wenZi: ri.name, ziHao: .caption)
//                    ShuPaiZi(wenZi: ri.zodiac, ziHao: .caption2)
//                }
//            }
//        }
//    }
    
    var ri: Ri
}

struct HuoZi: View {
    var body: some View {
        GeometryReader { g in
            HStack(spacing: spacing) {
                VStack {
                    ForEach(0..<contents[0].count) { j in
                        Text(String(contents[0][j]))
                            .font(.system(size:(g.size.width < g.size.height ? g.size.width * 0.2 : g.size.height * 0.2)))
                            .fontWeight(.bold)
                    }
                }
                VStack(spacing: 2) {
                    ForEach(1..<contents.count) { i in
                        VStack(spacing: 0) {
                            ForEach(0..<contents[i].count) { j in
                                Text(String(contents[i][j]))
                                    .font(.system(size:(g.size.width < g.size.height ? g.size.width * 0.15 : g.size.height * 0.15)))
                            }
                        }
                    }
                }
            }
            .position(x: g.size.width/2, y: g.size.height/2)
        }
    }

    var spacing: CGFloat = 2
    var contents: [[Character]] = []
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
        ContentView(li: LiJianZuo())
            .preferredColorScheme(.dark)
        
//        ContentView(calendar: LiJianZuo(date: {
//            let formatter = DateFormatter()
//            formatter.locale = Locale(identifier: "en_US_POSIX")
//            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//            return formatter.date(from:"1900-01-01T00:00:00+0800")!}() ))
//            .preferredColorScheme(.dark)
            
    }
}
