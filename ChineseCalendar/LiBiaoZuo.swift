//
//  ChineseCalendarView.swift
//  ChineseCalendar
//
//  Created by Junyi Qiu on 2021/6/15.
//

import SwiftUI

struct LiBiaoZuo: View {
    
    
    @ObservedObject var li: LiJianZuo
    
    var body: some View {
        YueBiaoDaTu(li: li, shuShi: false)
    }
}

struct YueBiaoDaTu: View {
    @Environment(\.colorScheme) var colorScheme
    // colorScheme == .dark
    @ObservedObject var li: LiJianZuo
    
    var body: some View {
        VStack {
            NianBiao(zhengtongNianFeng: li.yearName, baochengNianFeng: li.yearSubName, shuShi: shuShi)
            HStack(spacing: 0) {
                ForEach(0..<6) { hangOrdx in
                    VStack(spacing: 0) {
                        ForEach(0..<8) { hangIdx in
                            if (hangOrdx, hangIdx) == (0, 0) {
                                YueFengGe(yueFeng: li.month.monthName)
                            }
                            else if hangOrdx == 0 {
                                QiZhengGe(qiZheng: LiJianZuo.qiZheng[hangIdx-1])
                            }
                            else if hangIdx == 0 {
                                XingZhouGe(xingZhou: LiJianZuo.xingZhou[hangOrdx-1])
                            }
                            else {
                                RiGe(ri: li.riList[(hangOrdx-1)*7+hangIdx-1])
                                    .onTapGesture(count:1, perform: {
                                    li.chooseDay((hangOrdx-1)*7+hangIdx-1)
                                })
                            }
                        }
                    }
                }
            }
                
        }
        .environment(\.layoutDirection, .rightToLeft)
        .padding()
    }
    
    var shuShi: Bool = true

    struct RiGe: View {
        var body: some View {
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                Rectangle().stroke()
                HStack(alignment: .top) {
                    ShuPaiZi(wenZi: ri.name, ziHao: .caption)
                    ShuPaiZi(wenZi: ri.zodiac, ziHao: .caption2)
//                    ForEach(0..<jieLing.count) { idx in
//                        ShuPaiZi(wenZi: jieLing[idx], ziHao: .caption2)
//                            .foregroundColor(Color(UIColor.systemFill))
//                    }
                }
                .padding(5)
            }
        }
        
        var ri: Ri
        var jieLing: [String] = []
    }
}

struct NianBiao: View {
    var body: some View {
        if shuShi {
            HStack(alignment: .top)  {
                ShuPaiZi(wenZi: baochengNianFeng, ziHao: .caption)
                ShuPaiZi(wenZi: zhengtongNianFeng, ziHao: Optional<Font>.none)
                if yueFeng != "" {
                    ShuPaiZi(wenZi: yueFeng, ziHao: Optional<Font>.none)
                        .background(RoundedRectangle(cornerRadius: 2.5).foregroundColor(CalendarRed.scheme(.nippon)))
                        .foregroundColor(.white)
                }
            }
        }
        else {
            VStack {
                Text(String(baochengNianFeng.reversed()))
                    .font(.caption)
//                    .font(Font.custom("TypeLand.com KhangXi Dict", size: 12))
                Text(String(zhengtongNianFeng.reversed()))
//                    .font(Font.custom("TypeLand.com KhangXi Dict", size: 24))
                if yueFeng != "" {
                    ShuPaiZi(wenZi: yueFeng, ziHao: Optional<Font>.none)
                        .background(RoundedRectangle(cornerRadius: 2.5).foregroundColor(CalendarRed.scheme(.nippon)))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    var zhengtongNianFeng: String
    var baochengNianFeng: String
    var yueFeng: String = ""
    var shuShi: Bool = true
}

struct ShuPaiZi: View {
    var body: some View {
        VStack(spacing: -1) {
            ForEach(0 ..< Array(wenZi).count) { idx in
                Text( String( Array( wenZi )[idx] ) )
                    .font(ziHao)
            }
        }
    }
    
    var wenZi: String
    var ziHao: Font?
}

struct YueFengGe: View {
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            Rectangle()
                .foregroundColor(CalendarRed.scheme(.nippon))
            ShuPaiZi(wenZi: yueFeng, ziHao: .caption)
                .padding(5)
        }
    }
    
    var yueFeng: String
}

struct QiZhengGe: View {
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            Rectangle()
            ShuPaiZi(wenZi: qiZheng, ziHao: .caption)
                .foregroundColor(Color(UIColor.systemBackground))
                .padding(5)
        }
    }
    
    var qiZheng: String
}

struct XingZhouGe: View {
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            Rectangle()
            Text(xingZhou)
                .font(.caption)
                .foregroundColor(Color(UIColor.systemBackground))
                .padding(5)
        }
    }
    
    var xingZhou: String
}

struct LiBiaoZuo_Previews: PreviewProvider {
    static var previews: some View {
        LiBiaoZuo(li: LiJianZuo())
    }
}
